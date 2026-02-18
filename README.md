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
- **Joe's Bar**: Interactive bartender NPC with dialogue and HP restoration
- **Death Loop**: Die and return to HQ with all collected loot
- **Placeholder Art**: Bright, cartoon-style colored rectangles and circles

### Store System (NEW!)
The shop in HQ provides a way to spend currency earned from defeating enemies:
- **Currency System**: Gain gold from kills (melee: 10+wave, ranged: 25+2*wave, boss: 100+10*wave)
- **Gun Shop**: Buy pre-built weapons to add to your collection
  - Basic Pistol: 50 currency (common)
  - Combat Rifle: 150 currency (rare)
  - Plasma Rifle: 400 currency (epic)
  - Legendary Cannon: 800 currency (legendary)
  - Grail Blaster: 1500 currency (grail)
- **Upgrades**: Purchase stat boosts that apply to your character
  - Health Boost: +25 Max HP (75 currency)
  - Damage Upgrade: +10% Damage (100 currency)
  - Fire Rate Boost: 10% Faster Fire (100 currency)
  - Ammo Efficiency: +20% Magazine Size (150 currency)
  - Accuracy Upgrade: -15% Spread (80 currency)
- **Controls**: 
  - Press E near the store counter to open
  - ↑/↓ Arrow keys to navigate
  - ENTER to purchase selected item
  - ESC to close or go back to main menu

### Joe's Bar
Located in the HQ, Joe's Bar offers:
- **Buy Drinks**: Restore HP (free for now)
- **Chat**: Get random dialogue from Joe
- **Menu Options**:
  - Health Potion (+25 HP)
  - Big Brew (+50 HP)
  - Just Chatting (new random dialogue)
  - Leave (close dialogue)
- **Controls**: Press E near the bar to open, use arrow keys to navigate

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
- **E** - Interact with nearby zone (store, bar, vault, mission)
- **Store/Menu Navigation**:
  - **↑/↓ Arrow Keys** - Navigate menu items
  - **ENTER** - Select/Buy item
  - **ESC** - Go back or close menu

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
├── scenes/
│   ├── hq.lua           # HQ base scene (includes Joe's Bar)
│   └── game.lua         # Main gameplay scene
├── utils/
│   └── dialogue.lua     # Joe's dialogue system
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
- **Joe's Bar**: Interactive bartender NPC with dialogue system
  - HP restoration menu (drinks restore health)
  - Random dialogue lines for Joe
  - Navigation and selection UI for dialogue
- **Store System** (NEW!):
  - Currency earning from enemy kills (scales by wave and enemy type)
  - Shop inventory with guns and upgrades
  - Interactive menu to browse and purchase items
  - Gun Vault to manage collected weapons
  - Upgrade system for permanent stat boosts

### 🚧 Future Enhancements
- Sprite animations (anim8 ready)
- Advanced collision (bump library ready)
- Grenade mechanics
- Special abilities
- Boss encounters
- Weapon equipping system (buy and switch guns)
- Sound and music
- Particle effects
- More enemy types
- Shop persistence (remember purchases across runs)

## License

MIT License - Feel free to extend and modify!

## Author

Created by Botthew for Love2D game jam exploration.
