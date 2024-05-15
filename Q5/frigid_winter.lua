-- registering spell (revscript)
local spell = Spell("Instant")
spell:name("Frigid Winter")
spell:words("frigo")
spell:group("attack")
spell:vocation("sorcerer", "druid")
spell:id(119)
spell:cooldown(2*1000)
spell:groupCooldown(4*1000)
spell:level(1)
spell:mana(100)
spell:isSelfTarget(true)
spell:isPremium(false)
spell:register()

-- table for tiles to hit
local arr_all = {
	{0, 0, 0, 1, 0, 0, 0},
	{0, 0, 1, 1, 1, 0, 0},
	{0, 1, 1, 1, 1, 1, 0},
	{1, 1, 1, 3, 1, 1, 1},
	{0, 1, 1, 1, 1, 1, 0},
	{0, 0, 1, 1, 1, 0, 0},
	{0, 0, 0, 1, 0, 0, 0}
}

-- standard combat object creation (without effect)
local combat1 = Combat()
combat1:setParameter(COMBAT_PARAM_TYPE, COMBAT_ICEDAMAGE)
local area = createCombatArea(arr_all)
combat1:setArea(area)
--
function onGetFormulaValues(player, level, magicLevel)
	local min = (level / 5) + (magicLevel * 1.6) + 17
	local max = (level / 5) + (magicLevel * 3.2) + 34
	return -min, -max
end
combat1:setCallback(CALLBACK_PARAM_LEVELMAGICVALUE, "onGetFormulaValues")


--Animation handling function
local function animation(pos, playerpos)
	if not Tile(Position(pos)):hasProperty(CONST_PROP_BLOCKPROJECTILE) then
		Position(pos):sendMagicEffect(CONST_ME_ICETORNADO)
	end
end


function onCastSpell(creature, variant)
	local animationarea = arr_all
	local creaturepos = creature:getPosition()
	local playerpos = Position(creaturepos)
	local delay = 350

	local center = {}
	local damagearea = {}
	-- building a list of all tiles to do animation on
	for k,v in ipairs(animationarea) do
		for i = 1, #v do
			if v[i] == 3 then
				center.Row = k
				center.Column = i
				table.insert(damagearea, center)
			elseif v[i] == 1 then
				local darea = {}
				darea.Row = k
				darea.Column = i
				table.insert(damagearea, darea)
			end
		end
	end

	-- Randomly select sets of 6 to do effect on
	for i = 1, 4 do
		local hitarea = {}
		for count = 1, 6 do
			local idx = math.random(1, #damagearea)

			local animDelay = (i-1) * delay
			local offsetX = damagearea[idx].Column - center.Column
			local offsetY = damagearea[idx].Row - center.Row
			local damagePos = Position(creaturepos)
			
			damagePos.x = damagePos.x + offsetX
			damagePos.y = damagePos.y + offsetY
			
			table.remove(damagearea, idx) -- remove from damagearea table so same tile isn't hit twice
			
			-- send over to animation handler
			addEvent(animation, animDelay, damagePos, playerpos)
		end
	end
	return combat1:execute(creature, var)
end
