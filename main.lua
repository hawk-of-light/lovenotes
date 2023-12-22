function love.load()
    -- Window settings
    windowWidth, windowHeight = love.window.getMode()

    drawmode = true -- true (draw) or false (erase)
    draw = false -- for drawing
    erase = false -- for erasing
    drawSize = 5
    eraseSize = 8
    love.graphics.setPointSize(drawSize)

    pointsToDraw = {}
    pointsDrawn = {}
    erasures = {}
end

function love.update(dt)
    if draw then
        drawx, drawy = love.mouse.getPosition()
        if #pointsDrawn > 0 then
            local lastPoint = pointsDrawn[#pointsDrawn]
            addInterpolatedPoints(lastPoint, {drawx, drawy})
        end
        pointsToDraw[#pointsToDraw + 1] = {drawx, drawy}
    end

    if erase then
        erasex, erasey = love.mouse.getPosition()
    end
end


function love.draw()

    for k, v in pairs(pointsDrawn) do
        love.graphics.points(v[1], v[2])

    end    

    if draw then
        love.graphics.points(drawx, drawy)
        pointsDrawn[#pointsDrawn+1] = {drawx, drawy}
    end

    if erase then
        for i = #pointsDrawn, 1, -1 do
            local px, py = pointsDrawn[i][1], pointsDrawn[i][2]
            local distance = math.sqrt((erasex - px)^2 + (erasey - py)^2)
            if distance <= eraseSize then
                table.remove(pointsDrawn, i)
            end
        end
    end
end



function love.mousepressed(x, y, button)
    if button == 1 and drawmode then
        draw = true
    end

    if button == 1 and not drawmode then
        erase = true
    end

    if button == 2 then
        drawmode = not drawmode
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        draw = false
        erase = false
    end
end

function addInterpolatedPoints(pointA, pointB)
    local distance = math.sqrt((pointB[1] - pointA[1])^2 + (pointB[2] - pointA[2])^2)
    local numPoints = math.floor(distance / drawSize) -- Adjust this based on your drawSize for better smoothness

    for i = 1, numPoints do
        local t = i / numPoints
        local x = pointA[1] * (1 - t) + pointB[1] * t
        local y = pointA[2] * (1 - t) + pointB[2] * t
        pointsToDraw[#pointsToDraw + 1] = {x, y}
    end
end
