# Brief 02 — Customers and words for "Kiln & Keep"

Read first: art/concept/key-art.png (approved style), art/concept/palette.md,
art/concept/style-notes.md. The game name is **Kiln & Keep** (approved).

## The game (recap)
Jam theme: Castles. You are the royal potter. Over ONE day (morning → evening) castle folk
visit your courtyard workshop, each ordering a castle tower. You throw it on the wheel with
your thumb, pick a glaze, fire it in the kiln, and it is placed on the growing castle.
The last visitor is a dragon. Calm, warm, gently funny, for all ages. No game over: clay
can collapse ("sploosh") and the visitor laughs kindly.

Tower types the game can make (use ONLY these ids):
`watchtower` (tall, slim), `round_keep` (short, wide), `turret` (flares out at the top),
`onion_dome` (swells then narrows to a point), `spire` (wide base tapering to a point),
`gatehouse` (wide base and top, pinched waist).

Glaze ids (from palette.md): `cream_crown`, `sage_keep`, `sky_spire`, `honey_hall`,
`rose_turret`, `terracotta_throne`.

## Deliverable: art/writing/customers.json
Exactly this shape (valid JSON, English only, no emoji):

{
  "intro": "one line shown on the title screen under the name (max 60 chars)",
  "day_start": "a line when the workshop opens (max 60 chars)",
  "customers": [
    {
      "id": "king",
      "name": "King Bertram",
      "role": "The King",
      "tower": "watchtower",
      "glaze_hint": "sage_keep",
      "look": "short visual description for the 3D model: body colour (hex from palette), hat/crown, one prop",
      "arrive": "what they say walking in (max 50 chars)",
      "wish": "the order, in their voice, that hints at the shape and the glaze colour (max 70 chars)",
      "react": ["0 stars (kind, max 40 chars)", "1 star", "2 stars", "3 stars (delighted)"],
      "sploosh": "their reaction when the clay collapses (kind, funny, max 40 chars)"
    }
  ],
  "dragon": {
    "name": "...", "role": "The Dragon", "look": "...",
    "arrive": "...", "wish": "...", "react": ["...","...","...","..."], "sploosh": "...",
    "tower": "a NEW tower id for the dragon's special tower",
    "tower_shape": [ten widths from bottom to top, each 0.1–1.0, 1.0 = widest],
    "tower_height": number between 1.6 and 2.6,
    "glaze_hint": "one glaze id"
  },
  "ending": ["3 short lines shown after the dragon, the castle complete (max 60 chars each)"]
}

- 6 customers (king, queen, knight, wizard, + two you invent, e.g. a baker, a guard),
  each ordering a DIFFERENT tower type, in an order that gets gently harder:
  round_keep first, then watchtower, turret, gatehouse, onion_dome, spire.
- The dragon is the 7th visitor and the ending. Friendly, not scary. Its tower should
  make sense for a dragon (a roost? a chimney?) and be satisfying to shape.
- Short lines. Phone screen, big font. Warm humour, no sarcasm, no pop-culture references.

Also write art/writing/itch-page.md: a 120-word itch.io description (pitch, how to play,
how it uses the Castles theme) and a one-line tagline.
