-- LooterShooter: A Love2D Looter-Shooter Game
-- By Botthew

function love.load()
    -- Window setup
    love.window.setTitle("LooterShooter")
    love.window.setMode(800, 600)
    
    -- Load libraries
    local bump = require("lib.bump")
    SceneManager = require("lib.scene_manager")
    require("lib.math_utils")  -- Add math extensions
    
    -- Load constants
    Colors = require("config.constants")
    
    -- Global game state
    Game = {
        world = bump.newWorld(64),
        collectedGuns = {},  -- All guns collected across runs
        player = nil,        -- Current player state
        wave = 1             -- Current wave
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
    if key == "escape" then
        love.event.quit()
    else
        SceneManager.keypressed(key)
    end
end

function love.mousepressed(x, y, button)
    SceneManager.mousepressed(x, y, button)
end
