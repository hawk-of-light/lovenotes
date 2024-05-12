-- [Main Functions] --

function love.load()
-- Loads all the related components of the program

    -- Window Settings --
    windowWidth, windowHeight = love.window.getMode() 
    hudON = true

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


   -- I/O -- 
   screenShot = false
   previewGif = false
   love.filesystem.setIdentity("Saved-Gifs-Images")

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

    if not previewGif then
        drawToScreen(currentPage)
    end


    if hudON then
        -- FPS counter for diagnostics
        love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)

        -- Page tracker
        love.graphics.print("page "..tostring(pageTracker).."of "..tostring(#pages), windowWidth-100, 10)
    end

    -- Takes a screenshot then returns Hud status to what it was
    if screenShot then
        love.graphics.captureScreenshot(os.time() .. ".png")
        hudON = hudStatus
        screenShot = false
    end

end

-- Alternates drawMode between true and false on right click
function love.mousepressed(x, y, button)
    if button == 2 then
        drawMode = not drawMode
    end
end

--[[ Adds points between pointA and pointB using linear interpolation to aide
     in mimicing the appearance of continious lines while drawing]]
function addInterpolatedPoints(pointA, pointB, pages)
    local distance = math.sqrt((pointB[1] - pointA[1])^2 + (pointB[2] - pointA[2])^2)
    local numPoints = math.floor(distance / drawSize) 

    for i = 1, numPoints do
        local t = i / numPoints
        local x = pointA[1] * (1 - t) + pointB[1] * t
        local y = pointA[2] * (1 - t) + pointB[2] * t
        pages[#pages+1] = {x, y}
    end
end

--[[ Adds a points cooridanates (mouse x y posn) to a the list drawnPoints of points to be drawn.  
         The list format is necessary to allow them to remain drawn each frame 
         Additionally, calls addInterpolatedPoints to avoid diffraction in the draw strokes --]]
function draw(pages)
    if love.mouse.isDown(1) and drawMode then
        pages[#pages+1] = {love.mouse.getX(), love.mouse.getY()}
        activePoints[#activePoints+1] = {love.mouse.getX(), love.mouse.getY()}
        if #activePoints > 2 then
            local lastPoint = activePoints[#activePoints-2]
            if lastPoint[1] >= 1 and lastPoint[1] <= windowWidth - 2 and lastPoint[2] >= 1 and lastPoint[2] <= windowHeight - 2 then -- [[This is necessary to avoid unwanted lines when mouse leaves window and returns]]
                local currentPoint = {love.mouse.getX(), love.mouse.getY()}
                addInterpolatedPoints(lastPoint, currentPoint, pages)
            end
        end
    end
end

--[[ Removes any points within the radius (eraseSize) of the mouse position (ex, ey) 
         from the list drawnPoints, effectively removing them from the screen --]]
function erase(pages)
    if love.mouse.isDown(1) and not drawMode then
        local ex, ey = love.mouse.getPosition()
        for i = #pages, 1, -1 do
            local px, py = pages[i][1], pages[i][2]
            local distance = math.sqrt((ex - px)^2 + (ey - py)^2)
            if distance <= eraseSize then
                table.remove(pages, i)
            end
        end
    end
end

-- Iterates through all points in drawnPoints and draws them to the pages 
function drawToScreen(pages)
    if #pages > 0 then
        love.graphics.points(currentPage)
    end
end

-- Key handler
function love.keypressed(key, scancode, isrepeat)
    
    -- creates a new blank page
    if key == "n" then
        pages[#pages+1] = {}
    end

    -- creates a copy of the current page 
    if key == "c" then
        pages[#pages+1] = copyTable(pages[pageTracker], {})
    end

    -- wipes current page clean
    if key == "w" then
        pages[pageTracker] = {}
    end

    -- deletes current page (moves to next page, unless there is not any)
    if key == "delete" then
        if #pages > 1 then
            if pages[pageTracker+1] == nil then
                table.remove(pages, pageTracker)
                pageTracker = pageTracker - 1
            else
                table.remove(pages, pageTracker)
            end
        end  
    end

    -- switches over to previous page if there is one
    if key == "left" then
        if pageTracker > 1 then
            pageTracker = pageTracker - 1
        end
    end

    -- flips over to the next page if there is one
    if key == "right" then
        if pageTracker < #pages then
            pageTracker = pageTracker + 1
        end
    end

    -- increase drawSize or eraseSize (broken)
    if key == "up" then
        if love.keyboard.isDown("lshift") then
            if drawMode then
                drawSize = drawSize + 1
                love.graphics.setPointSize(drawSize)
            elseif not drawMode then
                eraseSize = eraseSize + 1
            end
        end
    end

    -- decrease drawSize or eraseSize (broken)
    if key == "down" then
        if love.keyboard.isDown("lshift") then
            if drawMode then
                drawSize = drawSize - 1
                love.graphics.setPointSize(drawSize)
            elseif not drawMode then
                eraseSize = eraseSize - 1
            end
        end
    end

    -- turn hud on or off (off by default during screenshot and gif processesing)
    if key == "h" then
        hudON = not hudON
    end

    -- capture screenshot (actual implementation required to be done inside love.draw...)
    if key == "s" then
        hudStatus = hudON
        hudON = false
        screenShot = true
    end

    -- preview gif
    if key == "p" then
        hudStatus = hudON
        hudON = false
        previewGif = true
    end

    currentPage = pages[pageTracker] -- Updates the currentPage
end

-- simple table copy auxilary
function copyTable(oldtable, newtable)
    for k, v in pairs(oldtable) do
        newtable[k] = v
    end

    return newtable
end