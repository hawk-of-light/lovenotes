-- [Main Functions] --


function love.load()
-- Loads all the related components of the program

    -- Drawing relating --
    drawnPoints = {}
    drawSize = 5
    love.graphics.setPointSize(drawSize)

    drawMode = true -- true if drawing, false if erasing
    eraseSize = 8
   

    -- Window Settings --
    windowWidth, windowHeight = love.window.getMode()    
    

end

function love.update()
-- continuously updates the state of the world x frames per second

    -- Adds a points cooridanates (mouse xy posn on canvas) to a list of points to be drawn on left click 
    -- The list format is necessary to allow them to remain drawn each frame
    if love.mouse.isDown(1) and drawMode then
        drawnPoints[#drawnPoints+1] = {love.mouse.getX(), love.mouse.getY()}
    end

    if love.mouse.isDown(1) and not drawMode then
        local ex, ey = love.mouse.getPosition()
        for i = #drawnPoints, 1, -1 do
            local px, py = drawnPoints[i][1], drawnPoints[i][2]
            local distance = math.sqrt((ex - px)^2 + (ey - py)^2)
            if distance <= eraseSize then
                table.remove(drawnPoints, i)
            end
        end
    end
end

function love.draw()
-- continously renders the state of the world x frames per second 

    -- Iterates through all points in drawnPoints and draws them to the canvas 
    for k, v in pairs(drawnPoints) do
        love.graphics.points(v[1], v[2])
    end    
    

end

-- Alternates drawMode between true and false on right click
function love.mousepressed(x, y, button)
    if button == 2 then
        drawMode = not drawMode
    end
end

