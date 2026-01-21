_G.love = require("love")


function love.load()
movePressed = false
    love.window.setMode(800, 600)
    love.window.setTitle("Cat in the Box")

    Music = love.audio.newSource("music.ogg", "stream")
    Music:setLooping(true)

    collectSound = love.audio.newSource("select.ogg", "static")
    selectSound  = love.audio.newSource("click.ogg", "static")

    playScale = 5
    gameState = "menu"

    love.graphics.setDefaultFilter("nearest", "nearest")

    playerImg = love.graphics.newImage("player.png")
    bg        = love.graphics.newImage("bg.png")
    exitBtn   = love.graphics.newImage("exit.png")
    playBtn   = love.graphics.newImage("play.png")
    melon     = love.graphics.newImage("melon.png")
    menuBg    = love.graphics.newImage("menubg.png")
    title     = love.graphics.newImage("title.png")

    playX, playY = 250, 400
    exitX, exitY = 240, 500

    playW = playBtn:getWidth() * playScale
    playH = playBtn:getHeight() * playScale
    exitW = exitBtn:getWidth() * playScale
    exitH = exitBtn:getHeight() * playScale

    x, y = 0, 0
    vx, vy = 0, 0
    speed = 350

    playerW, playerH = 50, 50
    melonW,  melonH  = 32, 32
    melonX, melonY   = 500, 500

    score = 0
    key   = 15
    lowkey = false

    math.randomseed(os.time())
end

function startGame()
    gameState = "play"
    score = 0
    key = 15
    melonX = math.random(0, 700)
    melonY = math.random(0, 500)
    Music:play()
end
function love.update(dt)
    if gameState ~= "play" then return end

    local js = love.joystick.getJoysticks()[1]
    local moving = false

    if js then
        if js:isGamepadDown("dpleft") then
            vx = -speed
            moving = true
        end
        if js:isGamepadDown("dpright") then
            vx = speed
            moving = true
        end
        if js:isGamepadDown("dpup") then
            vy = -speed
            moving = true
        end
        if js:isGamepadDown("dpdown") then
            vy = speed
            moving = true
        end
    end

    -- 🔑 KEY DRAIN (once per press)
    if moving and not movePressed then
        key = key - 1
        movePressed = true
    end

    if not moving then
        movePressed = false
    end

    -- movement (momentum stays)
    x = x + vx * dt
    y = y + vy * dt

    -- bounds
    x = math.max(2, math.min(700, x))
    y = math.max(0, math.min(500, y))

    -- melon collision
    if x < melonX + melonW and
       x + playerW > melonX and
       y < melonY + melonH and
       y + playerH > melonY then

        score = score + 1
        key = key + (key > 50 and 1.5 or key >= 20 and 2 or 3)

        collectSound:stop()
        collectSound:play()

        melonX = math.random(0, 700)
        melonY = math.random(0, 500)
    end

    -- game over
    if key <= 0 then
        gameState = "gameover"
        Music:stop()
    end
end

	
	
local js = love.joystick.getJoysticks()[1]
local moving = false

if js and gameState == "play" then
    if js:isGamepadDown("dpleft") then
        vx = -speed
        moving = true
    end
    if js:isGamepadDown("dpright") then
        vx = speed
        moving = true
    end
    if js:isGamepadDown("dpup") then
        vy = -speed
        moving = true
    end
    if js:isGamepadDown("dpdown") then
        vy = speed
        moving = true
    end

    -- 🔑 KEY DRAIN (ONCE PER PRESS, NOT PER FRAME)
    if moving and not movePressed then
        key = key - 1
        movePressed = true
    end

    if not moving then
        movePressed = false
    end
end


function love.gamepadpressed(joystick, button)
    if button == "start" then
        love.event.quit()
    end
end



function love.touchpressed(id, x, y)
    if gameState == "menu" then
        if x > playX and x < playX + playW and
           y > playY and y < playY + playH then
            selectSound:play()
            startGame()
            return
        end

        if x > exitX and x < exitX + exitW and
           y > exitY and y < exitY + exitH then
            love.event.quit()
        end
    elseif gameState == "gameover" then
        startGame()
    end
end

function love.draw()
    if gameState == "menu" then
        love.graphics.draw(menuBg, 0, 0)
        love.graphics.draw(title, 150, 50, 0, 0.8, 0.8)
        love.graphics.draw(playBtn, playX, playY, 0, 5, 5)
        love.graphics.draw(exitBtn, exitX, exitY, 0, 5, 5)

    elseif gameState == "play" then
        love.graphics.draw(bg, 0, 0)
        love.graphics.draw(melon, melonX, melonY, 0, 2, 2)
        love.graphics.draw(playerImg, x, y, 0, 3)
        love.graphics.print("Score: " .. score, 10, 10, 0, 2.5)
        love.graphics.print("Keys Left: " .. key, 10, 550, 0, 2.5)

    elseif gameState == "gameover" then
        love.graphics.draw(menuBg, 0, 0)
        love.graphics.print("GAME OVER", 240, 180, 0, 4)
        love.graphics.print("Score: " .. score, 300, 260, 0, 2.5)
        love.graphics.draw(playBtn, 250, 340, 0, 5, 5)
    end

    if lowkey then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("LOW KEYS!", 250, 10, 0, 5)
        love.graphics.setColor(1, 1, 1)
    end
end
