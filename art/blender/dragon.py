"""A pear-shaped, friendly 1.8-high dragon with small rose wings and a curled tail."""
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from model_lib import *


def tail():
    # Sculpted cross-sections follow a rising curl; no chain of separate spheres.
    centres=[((0,.29,.34),.27),((.08,.61,.23),.23),((.28,.90,.18),.17),
             ((.54,1.04,.27),.12),((.71,1.04,.44),.075),((.73,.99,.62),.012)]
    n=8; verts=[]
    for i,(point,radius) in enumerate(centres):
        before=Vector(centres[max(0,i-1)][0])
        after=Vector(centres[min(len(centres)-1,i+1)][0])
        tangent=(after-before).normalized()
        u=tangent.cross(Vector((1,0,0))).normalized(); v=tangent.cross(u).normalized()
        for j in range(n):
            a=2*math.pi*j/n
            verts.append(tuple(Vector(point)+radius*(u*math.cos(a)+v*math.sin(a))))
    faces=[tuple(reversed(range(n)))]
    for i in range(len(centres)-1):
        for j in range(n):
            a=i*n+j; b=i*n+(j+1)%n
            faces.append((a,b,b+n,a+n))
    faces.append(tuple((len(centres)-1)*n+j for j in range(n)))
    mesh('tail',verts,faces,SAGE)


def wing(side):
    # A thick, scalloped membrane with one central ridge; flat on both faces.
    outline=[(.31,.24,.93),(.59,.27,1.30),(.99,.29,1.49),
             (.91,.29,1.12),(1.03,.30,.94),(.77,.25,.99),
             (.70,.22,.76),(.52,.20,.86)]
    outline=[(side*x,y,z) for x,y,z in outline]
    k=len(outline)
    verts=outline+[(x,y+.055,z) for x,y,z in outline]
    verts += [(side*.64,.18,1.08),(side*.64,.34,1.08)]
    faces=[]
    for i in range(k):
        j=(i+1)%k
        faces += [(2*k,i,j),(2*k+1,k+j,k+i),(i,k+i,k+j,j)]
    mesh('wing_'+str(side),verts,faces,ROSE)
    rod('wing_ridge_'+str(side),(side*.32,.19,.94),(side*.98,.255,1.47),.026,SAGE,6)


def build():
    reset('dragon')
    lathe('body',[(.24,.10),(.43,.22),(.49,.52),(.43,.85,-.015),
                  (.30,1.13,-.045),(.19,1.25,-.045)],SAGE,14)
    tail()
    ellipsoid('belly',(0,-.352,.58),(.315,.145,.40),CREAM,12,6)
    ellipsoid('head',(0,-.085,1.31),(.425,.355,.35),SAGE,14,7)
    ellipsoid('muzzle',(0,-.38,1.20),(.33,.225,.20),CREAM,12,6)
    for side in (-1,1):
        ellipsoid('foot_'+str(side),(side*.30,-.11,.12),(.22,.29,.12),SAGE,10,5)
        ellipsoid('arm_'+str(side),(side*.40,-.18,.68),(.14,.16,.235),SAGE,10,5)
        ellipsoid('eye_'+str(side),(side*.17,-.385,1.42),(.051,.035,.068),INK,8,4)
        ellipsoid('eye_glint_'+str(side),(side*.16,-.417,1.444),(.013,.009,.016),CREAM,6,4)
        ellipsoid('nostril_'+str(side),(side*.13,-.582,1.24),(.028,.012,.020),INK,8,4)
        ellipsoid('cheek_'+str(side),(side*.325,-.35,1.265),(.055,.016,.043),ROSE,8,4)
        lathe('horn_'+str(side),[(.093,0),(.065,.105),(.010,.20)],GOLD,8,
              (side*.26,-.015,1.60))
        wing(side)
    join('smile',[
        rod('smile_l',(-.115,-.565,1.125),(0,-.596,1.098),.014,INK,6),
        rod('smile_r',(0,-.596,1.098),(.115,-.565,1.125),.014,INK,6),
    ])
    for i,(y,z,r) in enumerate(((.30,1.12,.11),(.41,.91,.105),(.48,.67,.09))):
        lathe(f'back_spike_{i+1}',[(r,0),(.008,.17)],ROSE,5,(0,y,z))
    export('dragon')


if __name__=='__main__':
    build()
