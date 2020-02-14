PlayState = Class{__includes = BaseState}

function PlayState:init()
    ball.dx = math.random(-200, 200)
    ball.dy = math.random(-50, -60) - math.min(100, level * 5)
    self.paused = false
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('escape') then
            love.event.quit()
        end

        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['music']:resume()
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['music']:pause()
        gSounds['pause']:play()
        return
    end

    playerMove(dt)
    player:update(dt)
    ball:update(dt)

    if ball:collides(player) then
        ball.y = player.y - 8
        ball.dy = -ball.dy

        if ball.x < player.x + (player.width / 2) and player.dx < 0 then

            if player.dx < 0 then
                ball.dx = -math.random(30, 50 + 
                    10 * player.width / 2 - (ball.x + 8 - player.x))
            end
        else

            if player.dx > 0 then
                ball.dx = math.random(30, 50 + 
                    10 * (ball.x - player.x - player.width / 2))
            end
        end
        gSounds['paddle-hit']:play()
    end

    for k, brick in pairs(bricks) do
        if brick.inPlay and ball:collides(brick) then
            score = score + (brick.tier * 200 + brick.color * 25)
            brick:hit()

            if score > recoverPoints then
                health = math.min(3, health + 1)
                recoverPoints = math.min(100000, recoverPoints * 2)
                gSounds['recover']:play()
            end

            if self:checkVictory() then
                gStateMachine:change('victory')
            end

            ball.x = ball.x + -ball.dx * dt
            ball.y = ball.y + -ball.dy * dt

            if ball.dx > 0 then

                if ball.x + 2 < brick.x then
                    ball.dx = -ball.dx
        
                elseif ball.y + 1 < brick.y then
                    ball.dy = -ball.dy

                else
                    ball.dy = -ball.dy
                end
            else
                if ball.x + 6 > brick.x + brick.width then
                    ball.dx = -ball.dx
                elseif ball.y + 1 < brick.y then
                    ball.dy = -ball.dy
                else
                    ball.dy = -ball.dy
                end
            end

            ball.dy = ball.dy * 1.02

            break
        end
    end

    if ball.y >= VIRTUAL_HEIGHT then
        health = health - 1
        gSounds['hurt']:play()

        if health == 0 then
            gStateMachine:change('game-over')
        else
            gStateMachine:change('serve', player.skin)
        end
    end

    for k, brick in pairs(bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    player:render()
    ball:render()

    renderBricks()
    renderScore()
    renderHealth()

    for k, brick in pairs(bricks) do
        brick:renderParticles()
    end

    love.graphics.setFont(smallFont)
    love.graphics.printf('Level ' .. tostring(level),
        0, 4, VIRTUAL_WIDTH, 'center')

    if self.paused then
        love.graphics.setFont(largeFont)
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(bricks) do
        if brick.inPlay then
            return false
        end 
    end

    return true
end