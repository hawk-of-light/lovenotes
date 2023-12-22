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