RoRota - Rogue One-Button Rotation (Vanilla 1.12.1)

Install:
- Place the `RoRota-TWOW` folder into your `Interface\AddOns` directory.
- Login to WoW and enable the addon.

Usage:
- Default mode is "suggest-only": the addon computes and displays suggestions (console output).
- Secure-click mode will create a small secure button that casts the last suggested ability when clicked. Due to Blizzard's restrictions, attribute updates are only safe out-of-combat.

Notes:
- This is a minimal implementation blueprint. Options UI, reordering, and full condition checks are planned.
- The addon respects WoW protected-function rules. It will not try to perform protected actions from insecure code during combat.
