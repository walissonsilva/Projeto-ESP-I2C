dofile("head_display.lua")
    if (g == 1) then dofile("guiche_1.lua")
    elseif (g == 2) then dofile("guiche_2.lua")
    elseif (g == 3) then dofile("guiche_3.lua")
    elseif (g == 4) then dofile("guiche_4.lua")
    else dofile("guiche_5.lua") end

    if (t == "P") then dofile("senha_p.lua")
    else dofile("senha_c.lua") end
