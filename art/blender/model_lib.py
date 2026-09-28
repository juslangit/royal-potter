"""Shared low-poly construction, exact palette, and verified GLB export helpers.
Coordinates are Blender Z-up / -Y front; glTF converts them to Y-up / +Z front.
"""
import bpy
import bmesh
import json
import math
import struct
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'art/models'
PALETTE = {
    "Potter's Ink": '2A2420', 'Wet Terracotta': 'AD5C37',
    'Cream Plaster': 'F0D6AE', 'Warm Oak': '9F683B',
    'Courtyard Sage': '959B68', 'Storybook Sky': '7BA2DA',
    'Kiln Gold': 'F2B345', 'Royal Rose': 'B2675D',
    'Body': '959B68', 'Skin': 'F0D6AE',
}
INK, CLAY, CREAM, OAK, SAGE, SKY, GOLD, ROSE = list(PALETTE)[:8]

def linear(v):
    v /= 255
    return v / 12.92 if v <= .04045 else ((v + .055) / 1.055) ** 2.4

def mat(name):
    m = bpy.data.materials.get(name)
    if m: return m
    m = bpy.data.materials.new(name)
    h = PALETTE[name]
    rgba = (*[linear(int(h[i:i+2], 16)) for i in (0, 2, 4)], 1)
    m.diffuse_color = rgba
    m.use_nodes = True
    bsdf = m.node_tree.nodes.get('Principled BSDF')
    bsdf.inputs['Base Color'].default_value = rgba
    bsdf.inputs['Roughness'].default_value = .78
    return m

def reset(name):
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)
    for m in list(bpy.data.materials): bpy.data.materials.remove(m)
    bpy.context.scene['asset'] = name
    bpy.context.scene.unit_settings.system = 'NONE'

def finish_obj(o, name, colour, smooth=False):
    o.name = name
    o.data.name = name + '_mesh'
    o.data.materials.append(mat(colour))
    for p in o.data.polygons: p.use_smooth = smooth
    return o

def mesh(name, verts, faces, colour, smooth=False):
    m = bpy.data.meshes.new(name + '_mesh')
    m.from_pydata(verts, [], faces)
    m.update()
    # Recalculate consistently outward, including hollow vessel cross-sections.
    bm = bmesh.new(); bm.from_mesh(m)
    bmesh.ops.recalc_face_normals(bm, faces=list(bm.faces))
    bm.to_mesh(m); bm.free()
    o = bpy.data.objects.new(name, m)
    bpy.context.collection.objects.link(o)
    return finish_obj(o, name, colour, smooth)

def box(name, pos, size, colour, bevel=0):
    bpy.ops.mesh.primitive_cube_add(size=1, location=pos)
    o = bpy.context.object; o.scale = size
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    finish_obj(o, name, colour)
    if bevel:
        mod = o.modifiers.new('Soft hand-cut corners', 'BEVEL')
        mod.width = bevel; mod.segments = 1
    return o

def lathe(name, profile, colour, n=16, pos=(0,0,0), smooth=False, cap=True):
    # Profile entries: radius, height, optional Y offset for hand-shaped silhouettes.
    verts = [(r[0]*math.cos(2*math.pi*j/n)+pos[0],
              r[0]*math.sin(2*math.pi*j/n)+pos[1]+(r[2] if len(r)>2 else 0),
              r[1]+pos[2]) for r in profile for j in range(n)]
    faces=[]
    for k in range(len(profile)-1):
        for j in range(n):
            a=k*n+j; b=k*n+(j+1)%n
            faces.append((a,b,b+n,a+n))
    if cap:
        faces += [tuple(reversed(range(n))), tuple((len(profile)-1)*n+j for j in range(n))]
    return mesh(name,verts,faces,colour,smooth)

def disc(name, pos, radius, height, colour, n=16):
    return lathe(name, [(radius,0),(radius,height)], colour, n, pos)

def ellipsoid(name,pos,scale,colour,n=12,rings=6):
    # Broad faceted sculpt surface rather than high-resolution UV primitives.
    profile=[(max(.001, math.sin(math.pi*i/rings)), -math.cos(math.pi*i/rings)) for i in range(rings+1)]
    o=lathe(name,profile,colour,n)
    for v in o.data.vertices:
        v.co.x=v.co.x*scale[0]+pos[0]
        v.co.y=v.co.y*scale[1]+pos[1]
        v.co.z=v.co.z*scale[2]+pos[2]
    return o

def rod(name,a,b,radius,colour,n=8):
    delta=Vector(b)-Vector(a)
    o=disc(name,(0,0,0),radius,delta.length,colour,n)
    o.location=a; o.rotation_euler=delta.to_track_quat('Z','Y').to_euler()
    return o

def join(name, objects):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objects: o.select_set(True)
    bpy.context.view_layer.objects.active=objects[0]
    bpy.ops.object.join()
    o=bpy.context.object; o.name=name; o.data.name=name+'_mesh'
    return o

def empty(name,pos):
    o=bpy.data.objects.new(name,None); bpy.context.collection.objects.link(o)
    o.location=pos; o.empty_display_size=.15
    return o

def arch_shape(name,x,y,bottom,radius,spring,depth,colour,n=10):
    # Filled arched slab, extruded in Y; bottom and spring are absolute Z.
    outline=[(-radius,bottom),(radius,bottom)]
    outline += [(radius*math.cos(math.pi*i/n),spring+radius*math.sin(math.pi*i/n)) for i in range(n+1)]
    vs=[(x+a,y+d,z) for d in (-depth/2,depth/2) for a,z in outline]
    k=len(outline)
    fs=[tuple(reversed(range(k))),tuple(range(k,2*k))]
    fs += [(i,(i+1)%k,(i+1)%k+k,i+k) for i in range(k)]
    return mesh(name,vs,fs,colour)

def arch_frame(name,x,y,bottom,radius,spring,thick,depth,colour,n=9):
    parts=[]
    for side in (-1,1):
        parts.append(box(name+'_jamb',(x+side*(radius+thick/2),y,(bottom+spring)/2),(thick,depth,spring-bottom),colour))
    for i in range(n):
        a=math.pi*i/n+.012; b=math.pi*(i+1)/n-.012
        vs=[(x+r*math.cos(t),y+d,spring+r*math.sin(t)) for d in (-depth/2,depth/2) for r,t in [(radius,a),(radius+thick,a),(radius+thick,b),(radius,b)]]
        parts.append(mesh(name+'_voussoir',vs,[(0,3,2,1),(4,5,6,7),(0,1,5,4),(1,2,6,5),(2,3,7,6),(3,0,4,7)],colour))
    return join(name,parts)

def bowl(name,pos,radius,colour):
    return lathe(name,[(radius*.48,0),(radius*.56,.035),(radius*.88,.12),(radius,.23),(radius,.26),(radius*.84,.26),(radius*.72,.13),(.04,.09)],colour,12,pos,True)

def wall(name,a,b,height=.48):
    a,b=Vector(a),Vector(b); d=b-a; length=d.length
    centre=(a+b)/2
    angle=math.atan2(d.y,d.x)
    p=box(name+'_curtain',(centre.x,centre.y,height/2),(length,.24,height),CREAM)
    p.rotation_euler.z=angle
    parts=[p]
    for i in range(max(2,round(length/.56))):
        t=(i+.5)/max(2,round(length/.56)); v=a+d*t
        o=box(name+'_merlon',(v.x,v.y,height+.115),(.28,.29,.23),CREAM)
        o.rotation_euler.z=angle; parts.append(o)
    return join(name,parts)

def export(name,root_base=(0,0,0)):
    # Bake modifiers, origins and transforms before exporting. Keep props separate.
    objects=list(bpy.context.scene.objects)
    for o in objects:
        if o.type=='MESH':
            bpy.context.view_layer.objects.active=o
            o.select_set(True)
            for mod in list(o.modifiers): bpy.ops.object.modifier_apply(modifier=mod.name)
            o.select_set(False)
    root=empty(name,root_base)
    for o in objects:
        matrix=o.matrix_world.copy(); o.parent=root; o.matrix_world=matrix
    root['front']='Blender -Y / glTF +Z'
    root['palette']='art/concept/palette.md'
    OUT.mkdir(parents=True,exist_ok=True)
    path=OUT/(name+'.glb')
    bpy.ops.export_scene.gltf(filepath=str(path),export_format='GLB',export_yup=True,
        export_apply=True,export_texcoords=False,export_normals=True,
        export_materials='EXPORT',export_cameras=False,export_lights=False,
        export_animations=False,export_extras=True)
    raw=path.read_bytes()
    magic,version,total=struct.unpack_from('<4sII',raw)
    assert magic==b'glTF' and version==2 and total==len(raw)
    size,kind=struct.unpack_from('<II',raw,12)
    doc=json.loads(raw[20:20+size])
    assert not doc.get('textures') and not doc.get('images')
    counts={}
    for node in doc['nodes']:
        if 'mesh' in node:
            counts[node['name']]=sum(doc['accessors'][p['indices']]['count']//3 for p in doc['meshes'][node['mesh']]['primitives'])
    tris=sum(counts.values())
    assert 0<tris<3000, (name,tris)
    report={'file':path.name,'triangles':tris,'bytes':len(raw),'objects':counts,
            'empties':[n['name'] for n in doc['nodes'] if 'mesh' not in n],
            'materials':[m['name'] for m in doc['materials']]}
    (OUT/(name+'.stats.json')).write_text(json.dumps(report,indent=2)+'\n')
    print('VERIFIED_EXPORT '+json.dumps(report))
