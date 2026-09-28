---
updated: 2026-09-28
---

# Kiln & Keep — model inventory

The scripts were delivered without running Blender. A **pending** row means no
verified GLB is available. Counts below are filled from the actual exported GLB
by each model script, never estimated. Visual review in Blender/Godot is still required.

| Intended file | Verified triangles | Status |
|---|---:|---|
| `wheel.glb` | 948 | Export verified |
| `courtyard.glb` | 2,556 | Export verified |
| `castle_base.glb` | 1,296 | Export verified |
| `visitor.glb` | 1,880 | Export verified |
| `dragon.glb` | 1,624 | Export verified |
| `kiln_door.glb` | 156 | Export verified |

## Build

Run outside the sandbox, from the project root:

```sh
bash art/blender/build_all.sh
```

Override `BLENDER_BIN` if needed. Each script also works alone:

```sh
/Applications/Blender.app/Contents/MacOS/Blender -b --factory-startup --python-exit-code 1 --python art/blender/wheel.py
```

The build stops on any Python error. Every export checks a strict <3,000
triangle budget, GLB structure, exact palette base colours, absence of textures,
and required socket/prop names. It writes a `.stats.json` beside the model
and refreshes this inventory. All seven visitor props count toward its budget.

## Placement and runtime conventions

- Scripts use Blender Z-up and −Y front; default glTF conversion gives Y-up and **+Z front**. The brief names −Z as well as Blender −Y; these are different directions. Rotate a character root 180° around Godot Y if the game expects −Z-facing characters.
- Asset root empties are named after the file, positioned at (0, 0, 0). No cameras, lights, textures, or animation clips are exported. Rounded pottery alone uses smooth shading.
- The wheel is the deliberate origin exception: its head top is Y=0, radius .95, head thickness .14; the wooden body reaches Y=−1.10. Raise it 1.10 above a ground plane, or lower the backdrop to match a wheel fixed at zero.
- Courtyard footprint is 12×12 with floor top around .09. The kiln is on the left, bench on the right. A 6.6-wide opening remains between the rear wall sections for the growing castle.
- Castle plinth footprint is 6.15×3.15. Socket discs have radius .60; the seven empty markers are at their top, Y=.16, ready for base-origin towers. Taller slots are in the back row.
- Visitor body is 1.40 high without hats. `Body` and `Skin` are intentional palette-name exceptions for runtime recolouring (sage and cream defaults). Props are distinct mesh nodes, already positioned on the visitor. Hide every `prop_*` on import, then show the chosen hat and optionally the spear. `default_hidden` extras document the intent; standard glTF does not encode visibility.
- Dragon stands 1.80 high at the horn tips; front is the face/muzzle, with the tail behind. All body parts use the shared palette, with sage body and rose wings.
- Place the kiln door root at the courtyard’s `kiln_door_mount` empty. Rotate its `door_hinge` child about local Y in Godot (local Z in Blender), approximately −105° to open. The leaf geometry begins .13 above the mounting origin to meet the hearth. No door is baked into the courtyard.
- Palette hex colours are converted from sRGB to linear before assigning Principled Base Color; glTF stores linear colour factors. `Body`/`Skin` aside, material names exactly match `art/concept/palette.md`.

## Objects

### wheel.glb

| Mesh object | Triangles |
|---|---:|
| `body_band_0.61` | 32 |
| `body_band_1.015` | 32 |
| `body_stave_01` | 12 |
| `body_stave_02` | 12 |
| `body_stave_03` | 12 |
| `body_stave_04` | 12 |
| `body_stave_05` | 12 |
| `body_stave_06` | 12 |
| `body_stave_07` | 12 |
| `body_stave_08` | 12 |
| `body_stave_09` | 12 |
| `body_stave_10` | 12 |
| `body_stave_11` | 12 |
| `body_stave_12` | 12 |
| `splash_tray` | 384 |
| `wheel_axle` | 44 |
| `wheel_body` | 124 |
| `wheel_head` | 188 |

Empty nodes: `wheel`.

Materials: `Potter's Ink`, `Warm Oak`, `Cream Plaster`.

### courtyard.glb

| Mesh object | Triangles |
|---|---:|
| `back_wall_left` | 72 |
| `back_wall_right` | 72 |
| `bench_leg_0.97_0.36` | 12 |
| `bench_leg_0.97_-0.36` | 12 |
| `bench_leg_-0.97_0.36` | 12 |
| `bench_leg_-0.97_-0.36` | 12 |
| `bench_lower_shelf` | 12 |
| `bench_top` | 44 |
| `cobbled_floor` | 1176 |
| `floor_grout` | 12 |
| `glaze_bowl_1` | 188 |
| `glaze_bowl_2` | 188 |
| `kiln_back` | 48 |
| `kiln_chimney` | 12 |
| `kiln_chimney_cap` | 12 |
| `kiln_chimney_soot` | 12 |
| `kiln_dark_interior` | 48 |
| `kiln_front_arch` | 132 |
| `kiln_hearth` | 12 |
| `kiln_log_1` | 20 |
| `kiln_log_2` | 20 |
| `kiln_log_3` | 20 |
| `kiln_vault` | 144 |
| `kiln_warm_interior` | 40 |
| `tool_pot` | 164 |
| `wooden_tool_1` | 20 |
| `wooden_tool_2` | 20 |
| `wooden_tool_3` | 20 |

Empty nodes: `kiln_door_mount`, `courtyard`.

Materials: `Cream Plaster`, `Warm Oak`, `Wet Terracotta`, `Courtyard Sage`, `Royal Rose`, `Potter's Ink`, `Kiln Gold`.

### castle_base.glb

| Mesh object | Triangles |
|---|---:|
| `courtyard_plinth` | 44 |
| `gate_arch` | 132 |
| `gate_handle_0.12` | 48 |
| `gate_handle_-0.12` | 48 |
| `gate_plank_0` | 12 |
| `gate_plank_0.3` | 12 |
| `gate_plank_-0.3` | 12 |
| `socket_disc_1` | 76 |
| `socket_disc_2` | 76 |
| `socket_disc_3` | 76 |
| `socket_disc_4` | 76 |
| `socket_disc_5` | 76 |
| `socket_disc_6` | 76 |
| `socket_disc_7` | 76 |
| `wall_back` | 144 |
| `wall_front_left` | 60 |
| `wall_front_right` | 60 |
| `wall_left` | 72 |
| `wall_right` | 72 |
| `wooden_gate` | 48 |

Empty nodes: `socket_1`, `socket_2`, `socket_3`, `socket_4`, `socket_5`, `socket_6`, `socket_7`, `castle_base`.

Materials: `Cream Plaster`, `Kiln Gold`, `Potter's Ink`, `Courtyard Sage`, `Warm Oak`.

### visitor.glb

| Mesh object | Triangles |
|---|---:|
| `arm_nub_1` | 48 |
| `arm_nub_-1` | 48 |
| `body` | 164 |
| `eye_1` | 48 |
| `eye_-1` | 48 |
| `foot_1` | 60 |
| `foot_-1` | 60 |
| `head` | 168 |
| `prop_chef_hat` | 296 |
| `prop_crown` | 168 |
| `prop_guard_cap` | 144 |
| `prop_helmet` | 116 |
| `prop_spear` | 36 |
| `prop_tiara` | 180 |
| `prop_wizard_hat` | 256 |
| `smile` | 40 |

Empty nodes: `visitor`.

Materials: `Body`, `Potter's Ink`, `Skin`, `Cream Plaster`, `Kiln Gold`, `Royal Rose`, `Warm Oak`, `Storybook Sky`.

### dragon.glb

| Mesh object | Triangles |
|---|---:|
| `arm_1` | 80 |
| `arm_-1` | 80 |
| `back_spike_1` | 16 |
| `back_spike_2` | 16 |
| `back_spike_3` | 16 |
| `belly` | 120 |
| `body` | 164 |
| `cheek_1` | 48 |
| `cheek_-1` | 48 |
| `eye_1` | 48 |
| `eye_-1` | 48 |
| `eye_glint_1` | 36 |
| `eye_glint_-1` | 36 |
| `foot_1` | 80 |
| `foot_-1` | 80 |
| `head` | 168 |
| `horn_1` | 44 |
| `horn_-1` | 44 |
| `muzzle` | 120 |
| `nostril_1` | 48 |
| `nostril_-1` | 48 |
| `smile` | 40 |
| `tail` | 92 |
| `wing_1` | 32 |
| `wing_-1` | 32 |
| `wing_ridge_1` | 20 |
| `wing_ridge_-1` | 20 |

Empty nodes: `dragon`.

Materials: `Courtyard Sage`, `Royal Rose`, `Cream Plaster`, `Potter's Ink`, `Kiln Gold`.

### kiln_door.glb

| Mesh object | Triangles |
|---|---:|
| `door_leaf` | 156 |

Empty nodes: `door_hinge`, `kiln_door`.

Materials: `Warm Oak`, `Potter's Ink`, `Kiln Gold`.

