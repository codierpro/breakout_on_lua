VictoryState = Class{__includes = BaseState}

function VictoryState:enter()
    gSounds['victory']:play()
end

function VictoryState:update(dt)
    playerMove()
    player:update(dt)
    ball.x = player.x + (player.width / 2) - 4
    ball.y = player.y - 8

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        level = level + 1
        bricks = LevelMaker:createMap(level)
        gStateMachine:change('play')
    end
end

function VictoryState:render()
    player:render()
    ball:render()

    renderHealth()
    renderScore()

    love.graphics.setFont(largeFont)
    love.graphics.printf("Level " .. tostring(level) .. " complete!",
        0, VIRTUAL_HEIGHT / 4, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end