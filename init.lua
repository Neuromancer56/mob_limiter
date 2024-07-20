local config = {}
local settingNamePrefix = "mob_limiter."

local function setting(name, default)
    local value = tonumber(minetest.settings:get(settingNamePrefix..name))
    if value == nil then
        value = default
    end
    config[name] = value
end

setting("max_mobs", 3)
setting("search_distance", 35)
setting("scan_period", 60)

local function isRemovableMob(obj)
    local ent = obj:get_luaentity()

    -- mobs mod
    if ent and ent._cmi_is_mob and not ent.tamed then
        return true
    end

    -- creatura
    -- FIXME: figure out how to exclude tamed mobs or things that aren't mobs
    -- if ent and ent._creatura_mob and TODO then
    --     return true
    -- end

    return false
end

local function clearExcessMobs()
    local players = minetest.get_connected_players()

    for _, player in ipairs(players) do
        local pos = player:get_pos()
        local objs = minetest.get_objects_inside_radius(pos, config.search_distance)
        local mobsCount = 0  -- Counter for mobs found around the player

        -- Count the number of mobs around the player
        for _, obj in ipairs(objs) do
            if isRemovableMob(obj) then
                mobsCount = mobsCount + 1
            end
        end

        -- Check if the number of mobs found exceeds the maximum allowed
        local excessMobs = mobsCount - config.max_mobs
        if excessMobs > 0 then
            local removedCount = 0

            -- Remove the excess mobs
            for _, obj in ipairs(objs) do
                if removedCount >= excessMobs then
                    break  -- Exit loop if enough mobs have been removed
                end

                if isRemovableMob(obj) then
                    obj:remove()  -- Remove the mob object directly
                    removedCount = removedCount + 1
                end
            end

           -- minetest.chat_send_player(player:get_player_name(), minetest.colorize("#FF0000", "[Server]") .. " " .. removedCount .. " excess mobs removed.")
        end
    end
end

local timeSinceLastScan = 0
-- Schedule the function to be called automatically at a regular interval
minetest.register_globalstep(function(dtime)
    timeSinceLastScan = timeSinceLastScan + dtime
    if timeSinceLastScan >= config.scan_period then
        timeSinceLastScan = 0
        clearExcessMobs()
    end
end)

