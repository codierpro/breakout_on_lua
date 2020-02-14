ServeState = Class{__includes = BaseState}

function ServeState:init()
    player.x = VIRTUAL_WIDTH / 2 - 32
    player.y = VIRTUAL_HEIGHT - 24
end

function ServeState:enter(skin)
    player.skin = skin
    ball.skin = math.random(7)
end

function ServeState:update(dt)
    playerMove() 
    player:update(dt)
    ball.x = player.x + (player.width / 2) - 4
    ball.y = player.y - 8

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('play')
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()
    player:render()
    ball:render()

    renderBricks()
    renderHealth()
    renderScore()

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end