-- [Main Functions] --


function love.load()
-- Loads all the related components of the program

    -- Window Settings --
    windowWidth, windowHeight = love.window.getMode() 

    -- Drawing relating --
    activePoints = {}
    currentPage = {}
    drawSize = 4
    love.graphics.setPointSize(drawSize)

    drawMode = true -- true if drawing, false if erasing
    eraseSize = 8   

    -- Pages --
   pageTracker = 1
   pages = {currentPage}
   currentPage = pages[pageTracker]

end

function love.update()
-- Continuously updates the state of the world x frames per second

    draw(currentPage)

    if not love.mouse.isDown(1) then
        activePoints = {}
    end

    erase(currentPage)

end

function love.draw()
-- Continously renders the state of the world x frames per second 

    drawToScreen(currentPage)

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
function addInterpolatedPoints(pointA, pointB, canvas)
    local distance = math.sqrt((pointB[1] - pointA[1])^2 + (pointB[2] - pointA[2])^2)
    local numPoints = math.floor(distance / drawSize) 

    for i = 1, numPoints do
        local t = i / numPoints
        local x = pointA[1] * (1 - t) + pointB[1] * t
        local y = pointA[2] * (1 - t) + pointB[2] * t
        canvas[#canvas+1] = {x, y}
    end
end

--[[ Adds a points cooridanates (mouse x y posn) to a the list drawnPoints of points to be drawn.  
         The list format is necessary to allow them to remain drawn each frame 
         Additionally, calls addInterpolatedPoints to avoid diffraction in the draw strokes --]]
function draw(canvas)
    if love.mouse.isDown(1) and drawMode then
        canvas[#canvas+1] = {love.mouse.getX(), love.mouse.getY()}
        activePoints[#activePoints+1] = {love.mouse.getX(), love.mouse.getY()}
        if #activePoints > 2 then
            local lastPoint = activePoints[#activePoints-2]
            if lastPoint[1] >= 1 and lastPoint[1] <= windowWidth - 2 and lastPoint[2] >= 1 and lastPoint[2] <= windowHeight - 2 then -- [[This is necessary to avoid unwanted lines when mouse leaves window and returns]]
                local currentPoint = {love.mouse.getX(), love.mouse.getY()}
                addInterpolatedPoints(lastPoint, currentPoint, canvas)
            end
        end
    end
end

--[[ Removes any points within the radius (eraseSize) of the mouse position (ex, ey) 
         from the list drawnPoints, effectively removing them from the screen --]]
function erase(canvas)
    if love.mouse.isDown(1) and not drawMode then
        local ex, ey = love.mouse.getPosition()
        for i = #canvas, 1, -1 do
            local px, py = canvas[i][1], canvas[i][2]
            local distance = math.sqrt((ex - px)^2 + (ey - py)^2)
            if distance <= eraseSize then
                table.remove(canvas, i)
            end
        end
    end
end

-- Iterates through all points in drawnPoints and draws them to the canvas 
function drawToScreen(canvas)
    if #canvas > 0 then
        love.graphics.points(currentPage)
    end
end

-- Key handler
function love.keypressed(key, scancode, isrepeat)
    if key == "n" then
        pages[#pages+1] = {}
    end

    if key == "left" then
        if pageTracker > 1 then
            pageTracker = pageTracker - 1
        end
    end

    if key == "right" then
        if pageTracker < #pages then
            pageTracker = pageTracker + 1
        end
    end

    currentPage = pages[pageTracker]
end