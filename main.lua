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

    --[[ Adds a point's cooridanates (mouse xy posn on canvas) to a list of points to be drawn on left click 
         The list format is necessary to allow them to remain drawn each frame 
         Additionally, calls addInterpolatedPoints to create smoothness in the drawing --]]
    if love.mouse.isDown(1) and drawMode then
        drawnPoints[#drawnPoints+1] = {love.mouse.getX(), love.mouse.getY()}
        if #drawnPoints > 0 then
            local lastPoint = drawnPoints[#drawnPoints]
            local currentPoint = {love.mouse.getX(), love.mouse.getY()}
            addInterpolatedPoints(lastPoint, currentPoint)
        end
    end

    --[[ On left click, removes any points within radius = eraseSize of the mouse position (ex, ey) 
         from the list of points to be drawn onto the screen --]]
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
    
    -- FPS counter for diagnostics
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

end

-- Alternates drawMode between true and false on right click
function love.mousepressed(x, y, button)
    if button == 2 then
        drawMode = not drawMode
    end
end

--[[ Adds points between the last point drawn and the current point drawn using linear interpolation to 
     attempt to reproduce smoothness]]
function addInterpolatedPoints(pointA, pointB)
    local distance = math.sqrt((pointB[1] - pointA[1])^2 + (pointB[2] - pointA[2])^2)
    local numPoints = math.floor(distance / drawSize) -- Adjust this based on drawSize for better smoothness

    for i = 1, numPoints do
        local t = i / numPoints
        local x = pointA[1] * (1 - t) + pointB[1] * t
        local y = pointA[2] * (1 - t) + pointB[2] * t
        drawnPoints[#drawnPoints + 1] = {x, y}
    end
end
