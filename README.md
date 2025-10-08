# RoRota - Rogue One-Button Rotation

**Version:** 0.6.2  
**Target:** Vanilla WoW 1.12.1 (Turtle WoW)  
**Author:** feeder5

---

## Features

### Core Rotation
- **One-button rotation** - Press keybind to execute optimal ability
- **Smart opener system** - Automatic opener selection with failsafe fallback
- **Finisher priority** - Customizable priority order (drag-and-drop)
- **Builder failsafe** - Auto-switch to secondary builder if primary fails
- **Energy pooling** - Pool energy at 4+ CP for immediate finisher at 5 CP
- **Smart Eviscerate** - Execute at any CP if it will kill target
- **Smart Rupture** - Skip if it would overkill target

### Interrupts & Defensive
- **Interrupt priority** - Kick → Gouge → Kidney Shot
- **Threat management** - Feint with multiple modes (Always/WhenTargeted/HighThreat)
- **Emergency Vanish** - Auto-vanish at configurable HP threshold
- **Reactive abilities** - Riposte (after parry), Surprise Attack (after dodge)
- **Ghostly Strike** - Conditional usage based on HP thresholds

### Poison Management
- **Auto-apply poisons** - Automatically apply when missing
- **Combat control** - Allow/disallow poison application in combat
- **Sharpening Stone support** - Can use sharpening stones instead of poisons
- **Separate MH/OH** - Different poison for each weapon
- **8 Turtle WoW poisons** - Full support for all Turtle WoW poison types
- **Poison warnings** - Alerts for low time/charges
- **Manual application** - Button to manually apply poisons

### Advanced Features
- **Ability queue** - Preview shows current + next ability in rotation
- **Macro generator** - One-click macro creation for rotation keybind
- **Profile system** - Create, switch, and delete profiles
- **Auto-profile switching** - Automatic switching for Solo/Group/Raid
- **SuperWoW support** - Enhanced features when SuperWoW is available
- **Performance optimized** - Throttling, caching, and state management
- **Debug system** - Built-in debugging tools (/rr debug, /rr state, /rr perf)

---

## Installation

1. Download the latest release
2. Extract `RoRota-TWOW` folder to `Interface\AddOns\`
3. Login to WoW and enable the addon
4. Type `/rr` to open settings

---

## Usage

### Keybindings
Set up keybindings in ESC → Key Bindings → RoRota:
- **Run Rotation** - Execute rotation (main keybind)
- **Show Options** - Open settings GUI
- **Toggle Preview** - Show/hide rotation preview window

### Macro Setup
Use the macro creation buttons in the About tab:
- **Create Rotation Macro** - Creates "RoRota" macro with `/script RoRotaRunRotation()`
- **Create Poison Macro** - Creates "RoRotaPoison" macro with `/script RoRotaApplyPoison()`
- Drag macros to action bar for easy access
- Macros are character-specific and update if already created

### Slash Commands
- `/rr` or `/rorota` - Open settings GUI
- `/rr preview` - Toggle rotation preview window
- `/rr debug on/off` - Toggle debug mode
- `/rr trace on/off` - Toggle rotation trace logging
- `/rr state` - Show cached state values
- `/rr logs` - Show recent debug logs
- `/rr perf` - Show performance statistics
- `/rr poison` - Test poison warnings
- `/rr help` - Show command list

---

## Configuration

The addon features a modern GUI with vertical sidebar navigation and scrollable content.

### About Tab
- Addon information and version
- Macro creation buttons
- Feature list and commands
- GitHub link

### Openers Tab
- Primary opener ability
- Secondary opener (failsafe)
- Pick Pocket before opener
- Sap fail emergency action

### Finishers Tab
- Enable/disable individual finishers
- Min/Max CP per finisher (Slice and Dice, Envenom, Rupture, Expose Armor)
- Finisher priority system with up/down buttons (Eviscerate always last)
- Smart Eviscerate toggle (execute at any CP if it kills target)
- Smart Rupture toggle (skip if it would overkill)
- Energy pooling settings

### Builders Tab
- Main builder ability
- Secondary builder (failsafe)
- Failsafe attempt threshold
- Riposte toggle
- Surprise Attack toggle
- Hemorrhage toggle
- Ghostly Strike settings (enable, target max HP, player min/max HP)
- Smart Combo Builders toggle

### Defensive Tab
- Interrupt settings (Kick, Gouge, Kidney Shot with max CP)
- Vanish settings (enable, HP threshold)
- Feint settings (enable, mode: Always/WhenTargeted/HighThreat)

### Poisons Tab
- Auto-apply toggle
- Apply in combat toggle
- Main hand poison/stone selection (9 options including Turtle WoW poisons)
- Off hand poison/stone selection
- Warning settings (enable, time threshold, charges threshold)
- Test warning button

### Profiles Tab
- Create new profiles
- Switch between profiles
- Delete profiles
- Auto-switch settings (Solo/Group/Raid)

---

## Requirements

- **WoW Version:** 1.12.1 (Vanilla)
- **Class:** Rogue only
- **Recommended:** SuperWoW for enhanced features
- **Recommended:** Nampower for energy tracking

---

## Version History

### v0.6.2 (Current)
- Complete GUI redesign with vertical sidebar navigation
- Scrollable content area
- About tab with macro creation buttons
- Finisher priority system with drag-to-reorder
- Character-specific macro creation

### v0.6.1
- GUI layout improvements
- Widget alignment fixes

### v0.6.0
- Modular GUI architecture
- Dark theme design

### v0.5.0
- Ability queue (current + next ability preview)
- Macro generator button
- Improved rotation planning

### v0.4.0
- Modular architecture refactoring
- Split helpers.lua into 6 focused modules
- Improved code organization and maintainability

### v0.3
- Code quality improvements
- Style guide creation
- Class check on login

### v0.2
- Sharpening Stone support
- Poison verification system
- Bug fixes

### v0.1
- Initial release
- Core rotation system
- Poison management
- Profile system

---

## Support

- **GitHub:** https://github.com/thefeeder5/RoRota-TWOW
- **Issues:** Report bugs on GitHub Issues
- **Discord:** Turtle WoW Discord

---

## Credits

- **Author:** feeder5
- **Inspired by:** pfUI's modular architecture
- **Libraries:** Ace2 framework
- **Testing:** Turtle WoW community

---

## License

This addon is free and open source.
