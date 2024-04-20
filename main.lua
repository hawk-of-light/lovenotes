-- [Main Functions] --


function love.load()
-- Loads all the related components of the program

    -- Drawing relating --
    activePoints = {}
    drawnPoints = {}
    drawSize = 4
    love.graphics.setPointSize(drawSize)

    drawMode = true -- true if drawing, false if erasing
    eraseSize = 8
   

    -- Window Settings --
    windowWidth, windowHeight = love.window.getMode()    
    

end

function love.update()
-- Continuously updates the state of the world x frames per second

    --[[ Adds a points cooridanates (mouse x y posn) to a the list drawnPoints of points to be drawn.  
         The list format is necessary to allow them to remain drawn each frame 
         Additionally, calls addInterpolatedPoints to avoid diffraction in the draw strokes --]]
    if love.mouse.isDown(1) and drawMode then
        drawnPoints[#drawnPoints+1] = {love.mouse.getX(), love.mouse.getY()}
        activePoints[#activePoints+1] = {love.mouse.getX(), love.mouse.getY()}
        if #activePoints > 2 then
            local lastPoint = activePoints[#activePoints-2]
            local currentPoint = {love.mouse.getX(), love.mouse.getY()}
            addInterpolatedPoints(lastPoint, currentPoint)
        end
    end

    if not love.mouse.isDown(1) then
        activePoints = {}
    end

    --[[ Removes any points within the radius (eraseSize) of the mouse position (ex, ey) 
         from the list drawnPoints, effectively removing them from the screen --]]
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
-- Continously renders the state of the world x frames per second 

    -- Iterates through all points in drawnPoints and draws them to the canvas 
    if #drawnPoints > 0 then
        love.graphics.points(drawnPoints)
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

--[[ Adds points between pointA and pointB using linear interpolation to aide
     in mimicing the appearance of continious lines while drawing]]
function addInterpolatedPoints(pointA, pointB)
    local distance = math.sqrt((pointB[1] - pointA[1])^2 + (pointB[2] - pointA[2])^2)
    local numPoints = math.floor(distance / drawSize) 

    for i = 1, numPoints do
        local t = i / numPoints
        local x = pointA[1] * (1 - t) + pointB[1] * t
        local y = pointA[2] * (1 - t) + pointB[2] * t
        drawnPoints[#drawnPoints + 1] = {x, y}
    end
end
