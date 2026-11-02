-- Pong Game in Love2D
-- Name: Yaqoub Al-Hanbali
-- Section: 2 / 4

local WINDOW_WIDTH = 800
local WINDOW_HEIGHT = 480

-- Game states: 'serve' or 'play'
local gameState = "serve"
local servingPlayer = 1

local player1Score = 0
local player2Score = 0

-- Paddle tables storing position, size, and speed
local player1 = {
    x = 30,
    y = 195,
    width = 14,
    height = 90,
    speed = 380
}

local player2 = {
    x = WINDOW_WIDTH - 30 - 14,
    y = 195,
    width = 14,
    height = 90,
    speed = 380
}

-- Ball table storing position, size, and velocity
local ball = {
    x = (WINDOW_WIDTH - 12) / 2,
    y = (WINDOW_HEIGHT - 12) / 2,
    width = 12,
    height = 12,
    dx = 280,
    dy = 160
}

-- Fonts
local scoreFont
local smallFont

-- Reset ball to center and set initial speed
local function resetBall(server)
    ball.x = (WINDOW_WIDTH - ball.width) / 2
    ball.y = (WINDOW_HEIGHT - ball.height) / 2

    local speedX = 280
    local speedY = math.random(-140, 140)
    if math.abs(speedY) < 40 then
        speedY = (speedY >= 0 and 60 or -60)
    end

    if server == 1 then
        ball.dx = speedX
    else
        ball.dx = -speedX
    end
    ball.dy = speedY
end

-- AABB collision detection between two rectangles
local function checkCollision(r1, r2)
    return r1.x < r2.x + r2.width and
           r1.x + r1.width > r2.x and
           r1.y < r2.y + r2.height and
           r1.y + r1.height > r2.y
end

-- 1. love.load: runs once at the beginning to initialize settings and resources
function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        resizable = false,
        vsync = true
    })
    love.window.setTitle("Pong")

    math.randomseed(os.time())

    scoreFont = love.graphics.newFont(40)
    smallFont = love.graphics.newFont(16)

    resetBall(servingPlayer)
end

-- 2. love.update: runs every frame to handle movement, physics, and collisions
function love.update(dt)
    -- Left paddle controls (W / S)
    if love.keyboard.isDown("w") then
        player1.y = player1.y - player1.speed * dt
    elseif love.keyboard.isDown("s") then
        player1.y = player1.y + player1.speed * dt
    end

    -- Right paddle controls (Up / Down)
    if love.keyboard.isDown("up") then
        player2.y = player2.y - player2.speed * dt
    elseif love.keyboard.isDown("down") then
        player2.y = player2.y + player2.speed * dt
    end

    -- Keep paddles inside the screen
    player1.y = math.max(0, math.min(WINDOW_HEIGHT - player1.height, player1.y))
    player2.y = math.max(0, math.min(WINDOW_HEIGHT - player2.height, player2.y))

    -- Ball physics and collisions during active play
    if gameState == "play" then
        -- Move ball using horizontal and vertical velocities
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt

        -- Top and bottom wall bouncing
        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        elseif ball.y + ball.height >= WINDOW_HEIGHT then
            ball.y = WINDOW_HEIGHT - ball.height
            ball.dy = -ball.dy
        end

        -- Paddle collisions (AABB) + anti-stick repositioning + ball speedup
        if checkCollision(ball, player1) and ball.dx < 0 then
            ball.dx = -ball.dx * 1.04 -- custom feature: speed up slightly on hit
            ball.x = player1.x + player1.width -- push outside paddle to prevent sticking

            -- Add vertical angle variation based on hit position
            local hitOffset = (ball.y + ball.height / 2) - (player1.y + player1.height / 2)
            ball.dy = ball.dy + hitOffset * 2.5
        end

        if checkCollision(ball, player2) and ball.dx > 0 then
            ball.dx = -ball.dx * 1.04 -- custom feature: speed up slightly on hit
            ball.x = player2.x - ball.width -- push outside paddle to prevent sticking

            local hitOffset = (ball.y + ball.height / 2) - (player2.y + player2.height / 2)
            ball.dy = ball.dy + hitOffset * 2.5
        end

        -- Scoring: Player 2 scores if ball passes left edge
        if ball.x + ball.width < 0 then
            player2Score = player2Score + 1
            servingPlayer = 1
            resetBall(servingPlayer)
            gameState = "serve"
        end

        -- Scoring: Player 1 scores if ball passes right edge
        if ball.x > WINDOW_WIDTH then
            player1Score = player1Score + 1
            servingPlayer = 2
            resetBall(servingPlayer)
            gameState = "serve"
        end
    end
end

-- Single-press key events
function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        if gameState == "serve" then
            gameState = "play"
        end
    elseif key == "r" then
        -- Reset game scores and state
        player1Score = 0
        player2Score = 0
        servingPlayer = 1
        resetBall(servingPlayer)
        gameState = "serve"
    end
end

-- 3. love.draw: runs every frame to draw all visual elements
function love.draw()
    -- Dark background
    love.graphics.clear(0.06, 0.08, 0.12)

    -- Dashed center line
    love.graphics.setColor(0.2, 0.25, 0.32, 0.8)
    for y = 6, WINDOW_HEIGHT, 22 do
        love.graphics.rectangle("fill", WINDOW_WIDTH / 2 - 1, y, 2, 12)
    end

    -- Draw scores
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(0.25, 0.75, 0.95) -- Player 1 Cyan
    love.graphics.print(tostring(player1Score), WINDOW_WIDTH / 4, 30)

    love.graphics.setColor(1.0, 0.45, 0.38) -- Player 2 Coral
    love.graphics.print(tostring(player2Score), 3 * WINDOW_WIDTH / 4 - 20, 30)

    -- Draw paddles (custom colors)
    love.graphics.setColor(0.25, 0.75, 0.95)
    love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)

    love.graphics.setColor(1.0, 0.45, 0.38)
    love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)

    -- Draw ball
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)

    -- UI state text
    love.graphics.setFont(smallFont)
    if gameState == "serve" then
        love.graphics.setColor(1, 0.95, 0.4)
        local msg = "Player " .. servingPlayer .. " Serve - Press SPACE to Serve"
        local textW = smallFont:getWidth(msg)
        love.graphics.print(msg, (WINDOW_WIDTH - textW) / 2, 90)
    end

    -- Controls help
    love.graphics.setColor(0.5, 0.58, 0.68)
    local controls = "P1: [W / S]   |   P2: [Up / Down]   |   Serve: [Space]   |   Reset: [R]"
    local ctrlW = smallFont:getWidth(controls)
    love.graphics.print(controls, (WINDOW_WIDTH - ctrlW) / 2, WINDOW_HEIGHT - 28)
end
