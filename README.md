# LooterShooter

A Love2D looter-shooter with wave-based combat, procedural loot, an HQ hub, and persistent progression.

## Features

- **HQ Base**: Store, Joe's Bar, Gun Vault, and mission launch
- **Combat**: WASD movement, mouse aim, click-to-shoot with fire-rate cooldowns
- **Waves**: Endless scaling waves with a short clear intermission between waves
- **Enemies**: Melee, ranged, and every-5th-wave bosses with modifiers
- **Loot**: 5 rarity tiers with procedural gun stats and auto-pickup
- **Meta**: Currency, shop upgrades, vault loadout selection, save/load between sessions
- **Polish**: Damage numbers, particle bursts, cached fonts

## How to Run

### Requirements

- Love2D 11.0+ — https://love2d.org (includes Lua; you do not need a separate Lua install to play)

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install love
```

**macOS (Homebrew):**

```bash
brew install love
```

**Windows:** Download the installer from https://love2d.org

### Running the Game

```bash
cd /path/to/looter-shooter
love .
```

Progress is saved automatically to `save.dat` in the Love2D save directory when you quit, return to HQ, buy items, equip guns, or use the bar.

## Controls

### HQ

- **WASD** — Move
- **E** — Interact with nearby zones (store, bar, vault, mission)
- **↑/↓** or **J/K** — Navigate menus
- **ENTER** — Select / buy / equip
- **ESC** — Close menus, or quit when no menu is open

### Mission

- **WASD** — Move
- **Mouse** — Aim
- **Left Click** — Shoot
- **R** — Reload
- **G** — Throw grenade
- **ESC** — Extract to HQ (keeps current wave progress)
- **R (when dead)** — Return to HQ (resets wave progress)

### Gun Vault

- **Arrow Keys** — Navigate collection
- **E** or **Click** — Equip selected gun
- **S** — Toggle sort (rarity / acquisition)
- **ESC** or **L** — Return to HQ

## Game Loop

1. Start in HQ with saved loot, currency, upgrades, and equipped weapon
2. Visit the store, bar, or vault to prepare
3. Enter the mission and survive escalating waves
4. Collect loot, earn currency, and level up during the run
5. Die or extract back to HQ — loot and currency persist
6. Repeat and push your best wave

## Project Structure

```
looter-shooter/
├── main.lua
├── conf.lua
├── config/constants.lua
├── lib/
│   ├── anim8.lua
│   ├── bump.lua
│   ├── math_utils.lua
│   └── scene_manager.lua
├── scenes/
│   ├── hq.lua
│   ├── game.lua
│   └── vault.lua
├── utils/
│   ├── dialogue.lua
│   ├── fonts.lua
│   ├── particles.lua
│   ├── player_stats.lua
│   ├── save.lua
│   ├── shop.lua
│   └── sprites.lua
├── assets/sprites/
│   ├── hero/          # 8-direction bounty hunter
│   ├── enemies/       # melee, ranged, boss
│   ├── npcs/          # Joe + arms dealer
│   └── fx/            # bullets, explosions, chests
└── scripts/check_lua_syntax.py
```

## Implemented Systems

- HQ hub with store, bar, vault, and mission zones
- Wave combat with bosses every 5 waves
- Procedural loot and shop inventory
- Upgrade system with one purchase per upgrade type
- Equipped weapon loadout from the vault
- Save/load for currency, guns, upgrades, wave, and best wave
- Death screen, wave-clear intermissions, combat feedback

## Future Enhancements

- Sprite animations via `anim8`
- Sound and music
- More enemy types and elemental weapon effects
- Deeper boss attack patterns
- In-run upgrade choices on level-up

## License

MIT License

## Author

Created by Botthew for Love2D game jam exploration.
