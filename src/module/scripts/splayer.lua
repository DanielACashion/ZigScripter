--vars avail are 
--window_width
--window_height
--width, height
local dx, dy = 50, 50

function update(delta,x,y)
    local nx = x + dx * delta
    local ny = y + dy * delta
    if nx > WINDOW_WIDTH or nx <= 0  then dx = -dx end
    if ny > WINDOW_HEIGHT or ny <= 0  then dy = -dy end

    return nx, ny
end