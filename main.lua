local width, height = 800, 480
local left, right

local function paddle(x)
    return { x = x, y = (height - 88) / 2, width = 14, height = 88, speed = 360 }
end

function love.load()
    love.window.setMode(width, height)
    love.window.setTitle("Pong")
    love.graphics.setBackgroundColor(0.045, 0.065, 0.10)
    left = paddle(32)
    right = paddle(width - 32 - 14)
end

local function movePaddle(p, up, down, dt)
    local direction = 0
    if love.keyboard.isDown(up) then direction = direction - 1 end
    if love.keyboard.isDown(down) then direction = direction + 1 end
    p.y = math.max(0, math.min(height - p.height, p.y + direction * p.speed * dt))
end

function love.update(dt)
    movePaddle(left, "w", "s", dt)
    movePaddle(right, "up", "down", dt)
end

local function drawRect(r)
    love.graphics.rectangle("fill", r.x, r.y, r.width, r.height)
end

function love.draw()
    love.graphics.setColor(0.15, 0.20, 0.26)
    for y = 4, height, 20 do
        love.graphics.rectangle("fill", width / 2 - 1, y, 2, 10)
    end
    love.graphics.setColor(0.28, 0.88, 0.80)
    drawRect(left)
    love.graphics.setColor(1, 0.66, 0.38)
    drawRect(right)
end
