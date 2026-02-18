-- Simple scene manager for switching between game scenes.

local SceneManager = {
    scenes = {},
    current = nil
}

function SceneManager.add(name, scene)
    if type(name) ~= "string" or name == "" then
        error("SceneManager.add: name must be a non-empty string")
    end
    if type(scene) ~= "table" then
        error("SceneManager.add: scene must be a table")
    end

    SceneManager.scenes[name] = scene
    scene.__sceneName = name
end

function SceneManager.getCurrent()
    return SceneManager.current
end

function SceneManager.switch(sceneOrName, ...)
    local nextScene = sceneOrName
    if type(sceneOrName) == "string" then
        nextScene = SceneManager.scenes[sceneOrName]
    end

    if type(nextScene) ~= "table" then
        error("SceneManager.switch: unknown scene")
    end

    if SceneManager.current and type(SceneManager.current.unload) == "function" then
        SceneManager.current:unload()
    end

    SceneManager.current = nextScene

    if type(SceneManager.current.load) == "function" then
        SceneManager.current:load(...)
    end
end

function SceneManager.update(dt)
    if SceneManager.current and type(SceneManager.current.update) == "function" then
        SceneManager.current:update(dt)
    end
end

function SceneManager.draw()
    if SceneManager.current and type(SceneManager.current.draw) == "function" then
        SceneManager.current:draw()
    end
end

function SceneManager.keypressed(key)
    if SceneManager.current and type(SceneManager.current.keypressed) == "function" then
        SceneManager.current:keypressed(key)
    end
end

function SceneManager.mousepressed(x, y, button)
    if SceneManager.current and type(SceneManager.current.mousepressed) == "function" then
        SceneManager.current:mousepressed(x, y, button)
    end
end

return SceneManager
