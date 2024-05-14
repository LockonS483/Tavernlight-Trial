-- q1-3.lua

-- Q1 - Fix or improve the implementation of the below methods
-- (LUA)
-- The functions themselves are good. However, using addEvent to release player storage is problematic as cid will be destroyed on player logout, preventing the storage from being changed
-- Lua is not asynchronous in nature, so we cannot use a delay to wait for addEvent to finish running. Instead, the easiest fix for the implementation would be to simply call releaseStorage instead of adding it to an Event.
-- In the event that the 1 second delay is REALLY required, we may use a delayed database query instead (removing the row with our player's id and storage key 1000 should do the trick)

-- Since the first solution is pretty trivial, I will present the db query version here:
-- A simple function to fetch the player's database id, and then we run a query to remove the playerstorage key 

local function getPlayerIdByName(name)
    -- This function can fetch a player's database ID given the player's name
    local resultID = db.storeQuery("SELECT `id` FROM `players` WHERE `name` = " .. db.escapeString(name))
    if resultID ~= false then
        local id = result.getDataString(resultID, "id")
        result.free(resultID)
        return id
    end
    return 0
end

local function releaseStorage(playerDbId)
	-- player:setStorageValue(1000, -1)
    -- Function has been changed to call a deletion in the database instead (it works when the player is offline)
	db.query("DELETE FROM `player_storage` WHERE `key` = 1000 AND `player_id` = " .. db.escapeString(playerDbId))
end

function onLogout(player)
    if player:getStorageValue(1000) == 1 then
		-- releaseStorage(player)
        -- the 1 second delay will prevent the original releaseStorage from working, so we will use our new query-based one
		pid = getPlayerIdByName(getPlayerName(player))
        addEvent(releaseStorage, 1000, pid)
    end

	return true
end


-- Q2 - Fix or improve the implementation of the below method
-- (LUA)
-- at first glance this implementation looked pretty good, however, the problem is that the table structure of db.storeQuery in tfs does not allow the syntax that was originally used
-- First off, the getString function still wants a db result to be passed in as the first parameter. Secondly, getString in query result only outputs 1 row at a time.
-- We can use the next function until it returns nothing similar to a linked list, and print each element as they are outputted. We'll also free the resultId after we're done to preserve memory.

-- as a side note, after setting up vanilla tfs 1.4 and combing through the database, it does not seem like guilds have a max_member field. I added one to my database to try the query
-- for the sake of simplicity i put max_members as a column directly in the guilds table.

local function printSmallGuildNames(memberCount)
    -- this method is supposed to print names of all guilds that have less than memberCount max members
    -- changed to not use string formatting and use concat instead, since it's the styling used by the rest of TFS codebase
    local selectGuildQuery = "SELECT `name` FROM `guilds` WHERE `max_members` < "
    local resultId = db.storeQuery(selectGuildQuery..tostring(memberCount)..";")

    local linebreak = "\n"
    local outputStr = ""
    repeat --loop through result table to add each entry to our output
        local guildName = result.getString(resultId, "name")
        outputStr = outputStr .. guildName .. linebreak
    until not result.next(resultId)
    result.free(resultId)

    print(outputStr)
end


-- Q3 - Fix or improve the name and the implementation of the below method
-- (LUA)
-- The function will remove a specific member from the party given a a playerId, and the name of the person getting removed. I'll call it: kick_from_player_party()
-- Firstly, we can use ipairs instead of pairs as getMembers should return a table with positive numeric keys.
-- Names are unique in tfs, so we should also be able to check the names directly intsead of comparing creature/player objects -- as 'selfness' in Lua exists per object

--  Additionally I'll add some guard clauses for empty/no party conditions.

function kick_from_player_party(playerId, membername)
    player = Player(playerId)
    local party = player:getParty()
    if not party then
        print("player is not in a party")
        return
    end
    local pmembers = party:getMembers()
    if #pmembers == 0 then
        print("party has no members")
        return
    end

    for k,v in ipairs(pmembers) do
        if v:getName() == membername then
            party:removeMember(Player(membername))
        end
    end
end
