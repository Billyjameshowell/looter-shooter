-- LooterShooter: A Love2D Looter-Shooter Game
-- By Botthew

local Save = require("utils.save")

function love.load()
  love.window.setTitle("LooterShooter")
  love.window.setMode(800, 600)

  bump = require("lib.bump")
  SceneManager = require("lib.scene_manager")
  require("lib.math_utils")

  Colors = require("config.constants")

  Game = {
    world = bump.newWorld(64),
    collectedGuns = {},
    player = nil,
    equippedWeapon = nil,
    playerUpgrades = {},
    currency = 0,
    wave = 1,
    bestWave = 1
  }

  Save.load()

  require("scenes.hq")
  require("scenes.game")
  require("scenes.vault")

  SceneManager.switch(HQScene)

  print("LooterShooter loaded!")
  print("Controls: WASD move | E interact | Click shoot | R reload | G grenade")
end

function love.update(dt)
  SceneManager.update(dt)
end

function love.draw()
  SceneManager.draw()
end

function love.keypressed(key)
  SceneManager.keypressed(key)
end

function love.mousepressed(x, y, button)
  SceneManager.mousepressed(x, y, button)
end

function love.quit()
  Save.save()
end
