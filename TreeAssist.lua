--init a plugin
--Author Lorain.Li
g_Plugin = nil
a_LeavesMap = nil
function Initialize(a_Plugin)
	a_Plugin:SetName("TreeAssist")
	a_Plugin:SetVersion(4)
	g_Plugin = a_Plugin
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_BREAKING_BLOCK, MyOnPlayerBreakingBlock)
	LOG("TreeAssist v".. g_Plugin:GetVersion() .." is loaded")
	return true
end

function OnDisable()
	LOG("TreeAssist v" .. g_Plugin:GetVersion() .. " is disabling")
end

function MyOnPlayerBreakingBlock(a_Player, a_BlockX, a_BlockY, a_BlockZ, a_BlockFace, a_BlockType, a_BlockMeta)
	local EquippedItem = a_Player:GetEquippedItem()
	if (not ItemCategory.IsAxe(EquippedItem.m_ItemType)) then
		return false
	end
	local a_World = a_Player:GetWorld()
	CollectWood(a_World, a_BlockX, a_BlockY, a_BlockZ ,a_BlockType, a_BlockMeta % 4, a_LeavesMap = {})
end

function CollectWood(a_World, a_BlockX, a_BlockY, a_BlockZ ,a_BlockType, a_BlockMeta, a_LeavesMap)
	local a_BlockID = a_World:GetBlock(a_BlockX, a_BlockY, a_BlockZ)
	if(not (BlockIsWood(a_BlockID) or BlockIsLeaves(a_BlockID)) or (a_BlockID ~= a_BlockType)) then
		return
	end
	if(BlockIsWood(a_BlockID)) then
		local a_Items = cItems()
		a_Items:Add(a_BlockType, 1, a_BlockMeta)
		--collect log
		a_World:DigBlock(a_BlockX, a_BlockY, a_BlockZ)
		a_World:SpawnItemPickups(a_Items, a_BlockX, a_BlockY, a_BlockZ, math.random())
		--plant a sapling
		if(CanPlantSapling(a_World:GetBlock(a_BlockX, a_BlockY - 1, a_BlockZ))) then
			a_World:SetBlock(a_BlockX, a_BlockY, a_BlockZ, E_BLOCK_SAPLING, a_BlockMeta, false)
		end
	end
	if(BlockIsLeaves(a_BlockID)) then
		if(a_LeavesMap[a_BlockX .. ":" .. a_BlockY .. ":" .. a_BlockZ] == true) then
			return
		else
			a_LeavesMap[a_BlockX .. ":" .. a_BlockY .. ":" .. a_BlockZ] = true
		end
	end
	CollectWood(a_World, a_BlockX - 1, a_BlockY, a_BlockZ,a_BlockType, a_BlockMeta, a_LeavesMap)
	CollectWood(a_World, a_BlockX + 1, a_BlockY, a_BlockZ,a_BlockType, a_BlockMeta, a_LeavesMap)
	CollectWood(a_World, a_BlockX, a_BlockY, a_BlockZ - 1,a_BlockType, a_BlockMeta, a_LeavesMap)
	CollectWood(a_World, a_BlockX, a_BlockY, a_BlockZ + 1,a_BlockType, a_BlockMeta, a_LeavesMap)
	CollectWood(a_World, a_BlockX, a_BlockY + 1, a_BlockZ,a_BlockType, a_BlockMeta, a_LeavesMap)
end

function BlockIsWood(a_BlockID)
	return ((a_BlockID == E_BLOCK_LOG) or (a_BlockID == E_BLOCK_NEW_LOG))
end

function BlockIsLeaves( a_BlockID )
	return ((a_BlockID == E_BLOCK_LEAVES) or (a_BlockID == E_BLOCK_NEW_LEAVES))
end

function CanPlantSapling( a_BlockID )
	return (a_BlockID == E_BLOCK_DIRT) or (a_BlockID == E_BLOCK_GRASS)
end
