-- Lightweight particle bursts for combat feedback.

local Particles = {}

function Particles.spawnBurst(list, x, y, options)
    options = options or {}

    local count = options.count or 12
    local speed = options.speed or 120
    local life = options.life or 0.5
    local radius = options.radius or 4
    local color = options.color or {255, 200, 80}

    for _ = 1, count do
        local angle = math.random() * math.pi * 2
        local velocity = speed * (0.5 + math.random() * 0.5)

        table.insert(list, {
            x = x,
            y = y,
            vx = math.cos(angle) * velocity,
            vy = math.sin(angle) * velocity,
            life = life,
            maxLife = life,
            radius = radius,
            color = color
        })
    end
end

function Particles.update(list, dt)
    for index = #list, 1, -1 do
        local particle = list[index]
        particle.life = particle.life - dt
        particle.x = particle.x + particle.vx * dt
        particle.y = particle.y + particle.vy * dt
        particle.vx = particle.vx * 0.92
        particle.vy = particle.vy * 0.92

        if particle.life <= 0 then
            table.remove(list, index)
        end
    end
end

function Particles.draw(list)
    for _, particle in ipairs(list) do
        local alpha = math.max(0, particle.life / particle.maxLife)
        love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3], alpha)
        love.graphics.circle("fill", particle.x, particle.y, particle.radius * alpha)
    end
end

return Particles
