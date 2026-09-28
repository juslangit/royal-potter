"""Write the model inventory from verified export reports. Does not import Blender."""
import json
from pathlib import Path

OUT=Path(__file__).resolve().parents[2]/'art/models'
ASSETS={
    'wheel': 'wheel_head, wheel_axle, wheel_body, splash_tray, body_stave_*, body_band_*',
    'courtyard': 'floor_grout, cobbled_floor, back_wall_left, back_wall_right, kiln_*, bench_*, glaze_bowl_1/2, tool_pot, wooden_tool_1/2/3, kiln_door_mount (empty)',
    'castle_base': 'courtyard_plinth, wall_*, wooden_gate, gate_arch, gate_plank_*, gate_handle_*, socket_disc_1…7, socket_1…7 (empties)',
    'visitor': 'body, head, foot_*, arm_nub_*, eye_*, smile, prop_crown, prop_tiara, prop_helmet, prop_wizard_hat, prop_chef_hat, prop_guard_cap, prop_spear',
    'dragon': 'body, tail, belly, head, muzzle, foot_*, arm_*, eye_*, eye_glint_*, nostril_*, cheek_*, horn_*, wing_*, wing_ridge_*, smile, back_spike_1/2/3',
    'kiln_door': 'door_leaf, door_hinge (empty)',
}


def write_readme():
    lines=[
        '---', 'updated: 2026-09-28', '---', '', '# Kiln & Keep — model inventory', '',
        'The scripts were delivered without running Blender. A **pending** row means no',
        'verified GLB is available. Counts below are filled from the actual exported GLB',
        'by each model script, never estimated. Visual review in Blender/Godot is still required.', '',
        '| Intended file | Verified triangles | Status |',
        '|---|---:|---|',
    ]
    reports={}
    for name in ASSETS:
        stats=OUT/(name+'.stats.json')
        if stats.exists() and (OUT/(name+'.glb')).exists():
            reports[name]=json.loads(stats.read_text())
            lines.append(f"| `{name}.glb` | {reports[name]['triangles']:,} | Export verified |")
        else:
            lines.append(f'| `{name}.glb` | — | Pending Blender run |')
    lines += ['', '## Build', '', 'Run outside the sandbox, from the project root:', '',
              '```sh', 'bash art/blender/build_all.sh', '```', '',
              'Override `BLENDER_BIN` if needed. Each script also works alone:', '',
              '```sh', '/Applications/Blender.app/Contents/MacOS/Blender -b --factory-startup --python-exit-code 1 --python art/blender/wheel.py',
              '```', '',
              'The build stops on any Python error. Every export checks a strict <3,000',
              'triangle budget, GLB structure, exact palette base colours, absence of textures,',
              'and required socket/prop names. It writes a `.stats.json` beside the model',
              'and refreshes this inventory. All seven visitor props count toward its budget.', '',
              '## Placement and runtime conventions', '',
              '- Scripts use Blender Z-up and −Y front; default glTF conversion gives Y-up and **+Z front**. The brief names −Z as well as Blender −Y; these are different directions. Rotate a character root 180° around Godot Y if the game expects −Z-facing characters.',
              '- Asset root empties are named after the file, positioned at (0, 0, 0). No cameras, lights, textures, or animation clips are exported. Rounded pottery alone uses smooth shading.',
              '- The wheel is the deliberate origin exception: its head top is Y=0, radius .95, head thickness .14; the wooden body reaches Y=−1.10. Raise it 1.10 above a ground plane, or lower the backdrop to match a wheel fixed at zero.',
              '- Courtyard footprint is 12×12 with floor top around .09. The kiln is on the left, bench on the right. A 6.6-wide opening remains between the rear wall sections for the growing castle.',
              '- Castle plinth footprint is 6.15×3.15. Socket discs have radius .60; the seven empty markers are at their top, Y=.16, ready for base-origin towers. Taller slots are in the back row.',
              '- Visitor body is 1.40 high without hats. `Body` and `Skin` are intentional palette-name exceptions for runtime recolouring (sage and cream defaults). Props are distinct mesh nodes, already positioned on the visitor. Hide every `prop_*` on import, then show the chosen hat and optionally the spear. `default_hidden` extras document the intent; standard glTF does not encode visibility.',
              '- Dragon stands 1.80 high at the horn tips; front is the face/muzzle, with the tail behind. All body parts use the shared palette, with sage body and rose wings.',
              '- Place the kiln door root at the courtyard’s `kiln_door_mount` empty. Rotate its `door_hinge` child about local Y in Godot (local Z in Blender), approximately −105° to open. The leaf geometry begins .13 above the mounting origin to meet the hearth. No door is baked into the courtyard.',
              '- Palette hex colours are converted from sRGB to linear before assigning Principled Base Color; glTF stores linear colour factors. `Body`/`Skin` aside, material names exactly match `art/concept/palette.md`.', '',
              '## Objects', '']
    for name,planned in ASSETS.items():
        lines += [f'### {name}.glb', '']
        if name in reports:
            report=reports[name]
            lines += ['| Mesh object | Triangles |', '|---|---:|']
            for obj,count in report['objects'].items():
                lines.append(f'| `{obj}` | {count} |')
            lines += ['', 'Empty nodes: '+', '.join(f'`{s}`' for s in report['empties'])+'.', '',
                      'Materials: '+', '.join(f'`{s}`' for s in report['materials'])+'.', '']
        else:
            lines += ['Planned names (wildcards denote numbered parts): '+planned+'.',
                      'Exact exported names and per-object counts will appear after building.', '']
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'README.md').write_text('\n'.join(lines)+'\n')


if __name__=='__main__':
    write_readme()
