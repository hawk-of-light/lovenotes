-- [Main Functions] --


function love.load()
-- Loads all the related components of the program

    -- Draw settings --
    drawSize = 5
    love.graphics.setPointSize(drawSize)

    drawnPoints = {}

    -- Window Settings --
    windowWidth, windowHeight = love.window.getMode()    
    

end

function love.update()

    if love.mouse.isDown(1) then
        drawnPoints[#drawnPoints+1] = {love.mouse.getX(), love.mouse.getY()}
    end

end

function love.draw()

    for k, v in pairs(drawnPoints) do
        love.graphics.points(v[1], v[2])
    end    
    

end


