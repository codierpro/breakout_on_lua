push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'
require 'Brick'
require 'StateMachine'
require 'BaseState'
require 'StartState'
require 'PaddleSelectState'
require 'ServeState'
require 'PlayState'
require 'VictoryState'
require 'GameOverState'
require 'HighScoreState'
require 'EnterHighScoreState'
require 'LevelMaker'
require 'Util'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
PADDLE_SPEED = 200


function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())
    smallFont = love.graphics.newFont('font.ttf', 8)
    mediumFont = love.graphics.newFont('font.ttf', 16)
    largeFont = love.graphics.newFont('font.ttf', 32)
    love.graphics.setFont(smallFont)

    gTextures = {
        ['background'] = love.graphics.newImage('background.png'),
        ['main'] = love.graphics.newImage('breakout.png'),
        ['arrows'] = love.graphics.newImage('arrows.png'),
        ['hearts'] = love.graphics.newImage('hearts.png'),
        ['particle'] = love.graphics.newImage('particle.png')
    }

    gFrames = {
        ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24),
        ['bricks'] = GenerateQuadsBricks(gTextures['main']),
        ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
        ['balls'] = GenerateQuadsBalls(gTextures['main']),
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9)
    }
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    gSounds = {
        ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav'),
        ['score'] = love.audio.newSource('sounds/score.wav'),
        ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav'),
        ['select'] = love.audio.newSource('sounds/select.wav'),
        ['no-select'] = love.audio.newSource('sounds/no-select.wav'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav'),
        ['victory'] = love.audio.newSource('sounds/victory.wav'),
        ['recover'] = love.audio.newSource('sounds/recover.wav'),
        ['high-score'] = love.audio.newSource('sounds/high_score.wav'),
        ['pause'] = love.audio.newSource('sounds/pause.wav'),

        ['music'] = love.audio.newSource('sounds/music.wav')
    }

    player = Paddle()
    ball = Ball(1)
    score = 0
    level = 1
    health = 3
    bricks = LevelMaker:createMap(level)

    highScores = loadHighScores()
    recoverPoints = 5000

    -- game state can be any of the following:
    -- 1. 'start' (the beginning of the game, where we're told to press Enter)
    -- 2. 'paddle-select' (where we get to choose the color of our paddle)
    -- 3. 'serve' (waiting on a key press to serve the ball)
    -- 4. 'play' (the ball is in play, bouncing between paddles)
    -- 5. 'victory' (the current level is over, with a victory jingle)
    -- 6. 'game-over' (the player has lost; display score and allow restart)
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end,
        ['paddle-select'] = function() return PaddleSelectState() end,
        ['serve'] = function() return ServeState() end,
        ['play'] = function() return PlayState() end,
        ['victory'] = function() return VictoryState() end,
        ['game-over'] = function() return GameOverState() end,
        ['high-scores'] = function() return HighScoreState() end,
        ['enter-high-score'] = function() return EnterHighScoreState() end
    }
    gStateMachine:change('start')

    gSounds['music']:play()
    gSounds['music']:setLooping(true)

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    gStateMachine:update(dt)
    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function love.draw()
    push:apply('start')

    love.graphics.draw(gTextures['background'], 
        0, 0, 
        0,
        VIRTUAL_WIDTH / 301, VIRTUAL_HEIGHT / 128)
    
    gStateMachine:render()

    displayFPS()
    
    push:apply('end')
end

function loadHighScores()
    love.filesystem.setIdentity('breakout')

    if not love.filesystem.exists('breakout.lst') then
        local defaultScores = ''
        for i = 10, 1, -1 do
            defaultScores = defaultScores .. 'CTO\n'
            defaultScores = defaultScores .. tostring(i * 1000) .. '\n'
        end

        love.filesystem.write('breakout.lst', defaultScores)
    end

    local name = true
    local currentName = nil
    local counter = 1

    local scores = {}
    for i = 1, 10 do

        scores[i] = {
            name = nil,
            score = nil
        }
    end

    for line in love.filesystem.lines('breakout.lst') do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

        name = not name
    end

    return scores
end

function renderBricks()
    for k, brick in pairs(bricks) do
        brick:render()
    end
end

function renderHealth()
    local healthX = VIRTUAL_WIDTH - 100

    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
        healthX = healthX + 11
    end

    for i = 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
        healthX = healthX + 11
    end
end

function playerMove()
    if love.keyboard.isDown('left') then
        player.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown('right') then
        player.dx = PADDLE_SPEED
    else
        player.dx = 0
    end
end

function renderScore()
    love.graphics.setFont(smallFont)
    love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end