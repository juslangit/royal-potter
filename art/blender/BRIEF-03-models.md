# Brief 03 — 3D models for "Kiln & Keep" (Blender Python scripts → GLB)

Read first: art/concept/key-art.png (APPROVED style reference), art/concept/palette.md,
art/concept/style-notes.md.

Blender is at /Applications/Blender.app/Contents/MacOS/Blender. For each model write a
script in art/blender/ and run it headless:
  /Applications/Blender.app/Contents/MacOS/Blender -b --python art/blender/<name>.py
Each script builds the model from scratch (clear the scene first) and exports
art/models/<name>.glb (glTF binary, +Y up, apply modifiers).

## Rules (the game applies its own toon shader and outline)
- LOW POLY, chunky, rounded, storybook — match key-art.png. Keep each model under
  ~3,000 triangles (the whole scene runs in a phone browser).
- NO textures. One material per colour, named exactly after the palette colour
  (e.g. material "Cream Plaster"), with the palette hex as base colour. The game reads the
  base colour.
- Smooth shading only where it is a rounded pottery surface; flat elsewhere.
- Real-world scale in metres is NOT needed; use these sizes: the potter's wheel head has
  radius 0.95 and sits at y = 0. A finished tower is 0.9–2.4 tall and up to 1.2 wide.
- Origin at the base centre of each model. Front faces −Z... use Blender's default
  forward (−Y in Blender, which becomes +Z/−Z correctly with the glTF exporter defaults).

## Models
1. `wheel.glb` — potter's wheel: stone head (radius 0.95, height 0.14, top at y=0),
   wooden body and a round wooden splash tray, like the key art.
2. `courtyard.glb` — the backdrop seen behind the wheel from a camera at (0, 2, 4) looking
   slightly down: cobbled courtyard floor (~12 x 12), the arched kiln on the left, a
   workbench with bowls and a tool pot on the right, low crenellated castle wall behind.
   Leave the centre-back open: the growing castle stands there.
3. `castle_base.glb` — the base the player's towers are placed on: a low cream plaster
   curtain wall with crenellations and a wooden gate, forming a courtyard ~6 wide x 3 deep,
   with 7 round empty sockets (flat discs, radius 0.6) where towers will stand. Also add an
   empty named Empty object at each socket centre called socket_1 … socket_7, arranged
   pleasingly (tallest-looking spots at the back).
4. `visitor.glb` — ONE friendly "bean" body (rounded capsule body + round head, simple dot
   eyes, no arms needed or tiny nubs), ~1.4 tall, material "Body" (the game recolours it),
   "Skin" for the head. Plus separate small props as separate objects in the same file,
   hidden-by-name convention prop_<name>: prop_crown, prop_tiara, prop_helmet,
   prop_wizard_hat, prop_chef_hat, prop_guard_cap, prop_spear.
5. `dragon.glb` — a small, cute, round dragon (~1.8 tall), sage or rose body, little wings,
   friendly face, origin at feet.
6. `kiln_door.glb` — (optional) a separate arched wooden door for the kiln that the game can
   open for the reveal.

When done, write art/models/README.md listing each file, its triangle count and
object names.
