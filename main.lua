-- LooterShooter: A Love2D Looter-Shooter Game
-- By Botthew

function love.load()
    -- Window setup
    love.window.setTitle("LooterShooter")
    love.window.setMode(800, 600)
    
    -- Load libraries
    bump = require("lib.bump")
    SceneManager = require("lib.scene_manager")
    require("lib.math_utils")

    -- Load constants
    Colors = require("config.constants")

    -- Global game state
    Game = {
        world = bump.newWorld(64),
        collectedGuns = {},
        player = nil,
        equippedWeapon = nil,
        playerUpgrades = {},
        currency = 0,
        wave = 1
    }
    
    -- Load scenes (order matters - utils first, then scenes)
    require("scenes.hq")
    require("scenes.game")
    require("scenes.vault")
    
    -- Initialize HQ scene
    SceneManager.switch(HQScene)
    
    print("LooterShooter loaded!")
    print("Controls: WASD to move, E to interact, Click to shoot")
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
