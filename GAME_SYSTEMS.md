# LooterShooter - Core Systems Documentation

## ✅ IMPLEMENTED SYSTEMS

### 1. HQ Base Scene
- ✅ Player spawn point (center of HQ at 600, 400)
- ✅ Store area (text trigger at 100, 100)
- ✅ Bar area (Joe's Bar text NPC at 950, 100)
- ✅ Gun Vault (display collected guns - shows count in HQ)
- ✅ Exit to Mission (clickable button at 525, 100)
- ✅ WASD movement in HQ

### 2. Player Controller
- ✅ WASD movement (speed: 300 pixels/sec)
- ✅ Mouse aiming (player angle rotates toward cursor)
- ✅ Left click to shoot (spawns yellow projectile dots)
- ✅ Health system (100 HP, shown as red bar)
- ✅ R key for grenades (placeholder - prints message)
- ✅ Collision detection with enemies (takes damage)

### 3. Wave System
- ✅ Endless waves of enemies
- ✅ Spawn enemies at random edges (4 directions)
- ✅ Enemy types:
  - Melee (red squares) - chase player at 120 px/sec
  - Ranged (purple squares) - shoot back every 2 seconds
- ✅ Wave counter display (top-left of mission screen)
- ✅ Difficulty scaling (spawn interval decreases per wave)
- ✅ Auto-progression to next wave when enemies cleared

### 4. Loot System Foundation
- ✅ Rarity tiers: Common (80%), Rare (20%), Epic (10%), Legendary (5%), Grail (1%)
- ✅ Gun stats generation:
  - Damage: 5-50
  - Fire rate: 0.1-1.0 sec
  - Mag size: 5-30
  - Spread: 0.01-0.20
- ✅ Drop system: enemies drop loot chests on death
- ✅ Auto-pickup: loot auto-collects within 30px radius
- ✅ Color-coded by rarity:
  - Common: gray (0.8, 0.8, 0.8)
  - Rare: blue (0.2, 0.6, 1)
  - Epic: purple (0.7, 0.2, 1)
  - Legendary: gold (1, 0.8, 0)
  - Grail: red (1, 0.2, 0.2)

### 5. Death → HQ Loop
- ✅ Player death on 0 HP → dead screen
- ✅ Press R to return to HQ
- ✅ All collected loot persists in inventory
- ✅ Gun Vault displays total collected guns
- ✅ Wave progress resets for next run

### 6. Libraries Included
- ✅ anim8.lua (sprite animations - ready for implementation)
- ✅ bump.lua (collision detection - ready for expansion)

### 7. Art Style
- ✅ Bright, cartoon colors
- ✅ Colored rectangles for player (blue) and enemies
- ✅ Yellow dots for projectiles
- ✅ Color-coded loot chests by rarity
- ✅ Dark background (0.1, 0.1, 0.15)

### 8. Git Workflow
- ✅ Initialized git repo
- ✅ Created .gitignore (*.love, __MACOSX, .DS_Store, *.swp, *.bak)
- ✅ Committed initial structure
- ✅ Committed all systems
- ✅ Pushed to https://github.com/botthew/looter-shooter

## GAME FLOW

```
LOAD GAME
    ↓
HQ SCENE (gameState = "hq")
    - Player can move with WASD
    - Click "TO MISSION" button to start
    ↓
MISSION SCENE (gameState = "mission")
    - Waves spawn enemies at edges
    - Player shoots at enemies (left click)
    - Enemies drop loot when killed
    - Player auto-picks up loot
    - Enemies deal damage on contact
    ↓
PLAYER DIES (gameState = "dead")
    - Shows death screen with stats
    - Press R to return to HQ
    - Loot persists in Gun Vault
    ↓
REPEAT

```

## TESTING CHECKLIST

- [x] Game starts with HQ scene visible
- [x] Player can move with WASD
- [x] Click "TO MISSION" starts a wave-based run
- [x] Enemies spawn at edges and move toward player
- [x] Left-clicking shoots yellow projectiles
- [x] Projectiles collide with enemies and damage them
- [x] Enemies drop colored loot chests when defeated
- [x] Loot auto-pickups within 30px radius
- [x] Gun Vault shows collected gun count
- [x] Melee enemies (red) chase player
- [x] Ranged enemies (purple) shoot back
- [x] Player takes damage from enemy contact
- [x] Player dies on 0 HP, shows death screen
- [x] Press R on death screen returns to HQ
- [x] Collected loot persists after death
- [x] Waves increase in difficulty over time
- [x] ESC quits the game

## HOW TO RUN

```bash
love /data/.openclaw/workspace/looter-shooter
```

## REPOSITORY

**GitHub**: https://github.com/botthew/looter-shooter  
**Branch**: master  
**Files**: 2 commits with full source + libraries

---

**Status**: Ready for playtesting! All core mechanics implemented.
**Next Steps**: Sprite animations, sound, UI polish, additional enemy types, boss encounters.
