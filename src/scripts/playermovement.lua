local dx, dy = 100, 100

---------------------------------------
--UPDATE
--
function update(delta, x, y)
    x = x + dx * delta
    y = y + dy * delta

    if x > WINDOW_WIDTH or x <= 0  then dx = -dx end
    if y > WINDOW_HEIGHT or y <= 0  then dy = -dy end
    set_player_pos(x, y)
end