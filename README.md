# LooterShooter

A Love2D looter-shooter game with wave-based enemy spawning, procedural loot generation, and roguelike progression.

## Features

- **HQ Base**: Central hub with store, bar, gun vault, and mission exit
- **Player Controller**: WASD movement, mouse aiming, click-to-shoot mechanics
- **Wave System**: Endless waves of enemies with increasing difficulty
- **Enemy Types**: 
  - Melee (red) - chase the player
  - Ranged (purple) - shoot projectiles
- **Loot System**:
  - 5 rarity tiers: Common → Rare → Epic → Legendary → Grail
  - Procedurally generated gun stats (damage, fire rate, mag size, spread)
  - Color-coded loot chests that auto-pickup when near player
- **Death Loop**: Die and return to HQ with all collected loot
- **Placeholder Art**: Bright, cartoon-style colored rectangles and circles

## How to Run

### Requirements
- Love2D 11.0+ (available at https://love2d.org)

### Running the Game

```bash
love /data/.openclaw/workspace/looter-shooter
```

Or if you have `love` in PATH:

```bash
cd /data/.openclaw/workspace/looter-shooter
love .
```

## Controls

### In HQ
- **WASD** - Move around
- **Click "TO MISSION"** - Start a run

### In Mission
- **WASD** - Move around
- **Mouse** - Aim
- **Left Click** - Shoot
- **R** - Grenade (placeholder)
- **E** - Pickup loot (auto-pickup within range)

### General
- **ESC** - Quit
- **R (when dead)** - Return to HQ

## Game Loop

1. **Start in HQ** with previous loot in the Gun Vault
2. **Click "TO MISSION"** to enter the combat arena
3. **Survive waves** of enemies and collect loot drops
4. **Defeat all enemies** to progress to the next wave
5. **Die or retreat** back to HQ (your loot stays!)
6. **Repeat** to build a collection and tackle harder waves

## Project Structure

```
looter-shooter/
├── main.lua              # Core game logic
├── lib/
│   ├── anim8.lua        # Animation library
│   └── bump.lua         # Collision detection library
├── README.md            # This file
└── .gitignore           # Git ignore patterns
```

## Implemented Systems

### ✅ Completed
- Basic player movement and aiming
- Mouse-based shooting (click to fire)
- Enemy spawning at random edges (melee + ranged)
- Wave progression with difficulty scaling
- Projectile collision detection with enemies
- Loot chest spawning with weighted rarity
- Procedural gun generation
- Death → HQ loop with loot persistence
- HQ scene with locations and player spawn
- Simple AI for enemy movement toward player

### 🚧 Future Enhancements
- Sprite animations (anim8 ready)
- Advanced collision (bump library ready)
- Grenade mechanics
- Special abilities
- Boss encounters
- Weapon upgrade system
- Sound and music
- Particle effects
- More enemy types

## License

MIT License - Feel free to extend and modify!

## Author

Created by Botthew for Love2D game jam exploration.
