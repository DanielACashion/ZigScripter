local dx, dy = 1000, 500

function update(delta, x, y)
    local nx = x + dx * delta
    local ny = y + dy * delta
    if nx > WINDOW_WIDTH or nx <= 0  then dx = -dx end
    if ny > WINDOW_HEIGHT or ny <= 0  then dy = -dy end
    print("x was: "..x.." Y was: "..y)
print("swapped")
    return nx, ny
end