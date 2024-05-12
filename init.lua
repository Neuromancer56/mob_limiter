local function clearExcessMobs(maxMobs)
    local players = minetest.get_connected_players()

    for _, player in ipairs(players) do
        local pos = player:get_pos()
        local objs = minetest.get_objects_inside_radius(pos, 35)
        local mobsCount = 0  -- Counter for mobs found around the player

        -- Count the number of mobs around the player
        for _, obj in ipairs(objs) do
            local ent = obj:get_luaentity()

            if ent and ent._cmi_is_mob and not ent.tamed then
                mobsCount = mobsCount + 1
            end
        end

        -- Check if the number of mobs found exceeds the maximum allowed
        local excessMobs = mobsCount - maxMobs
        if excessMobs > 0 then
            local removedCount = 0

            -- Remove the excess mobs
            for _, obj in ipairs(objs) do
                if removedCount >= excessMobs then
                    break  -- Exit loop if enough mobs have been removed
                end

                local ent = obj:get_luaentity()

                if ent and ent._cmi_is_mob and not ent.tamed then
                    obj:remove()  -- Remove the mob object directly
                    removedCount = removedCount + 1
                end
            end

           -- minetest.chat_send_player(player:get_player_name(), minetest.colorize("#FF0000", "[Server]") .. " " .. removedCount .. " excess mobs removed.")
        end
    end
end

-- Adjust this value according to your desired maximum number of mobs allowed
local maxMobsAllowed = 3

-- Schedule the function to be called automatically at a regular interval
minetest.register_globalstep(function(dtime)
    -- Adjust the interval based on your needs; this runs every 60 seconds
    if math.floor(minetest.get_gametime() % 60) == 0 then
        clearExcessMobs(maxMobsAllowed)
    end
end)

