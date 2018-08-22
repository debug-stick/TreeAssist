--init a plugin
--Author Lorain.Li
g_Plugin=nil;
function Initialize(a_Plugin)
	a_Plugin:SetName("TreeAssist")
	a_Plugin:SetVersion(3)
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
	local a_BlockC = a_World:GetBlock(a_BlockX,a_BlockY,a_BlockZ)
	if(not (BlockIsWood(a_BlockC) or BlockIsLeaves(a_BlockC))) then
		return false
	end
	local m_Block = cItems()
	m_Block:Add(a_BlockType, 1, a_BlockMeta % 4)
	for PosY=a_BlockY,a_World:GetHeight(a_BlockX, a_BlockZ),1 do
		if(not CollectXZWood(a_BlockX,PosY,a_BlockZ,a_World,m_Block)) then
			break
		end
	end
	a_World:SetBlock(a_BlockX, a_BlockY, a_BlockZ, E_BLOCK_SAPLING, a_BlockMeta, false)
	return false
end

function CollectXZWood( x_X,x_Y,x_Z,x_World,m_Block)
	local a_BlockC = x_World:GetBlock(x_X,x_Y,x_Z)
	if(not (BlockIsWood(a_BlockC) or BlockIsLeaves(a_BlockC))) then
		return false
	end
	for PosX=x_X,x_X+5,1 do
		if(not CollectZWood(PosX,x_Y,x_Z,x_World,m_Block)) then
			break
		end
	end
	for PosX=x_X-1,x_X-5,-1 do
		if(not CollectZWood(PosX,x_Y,x_Z,x_World,m_Block)) then
			break
		end
	end
	return true
end

function CollectZWood( z_X,z_Y,z_Z ,z_World,m_Block)
	local a_BlockC = z_World:GetBlock(z_X,z_Y,z_Z)
	if(not (BlockIsWood(a_BlockC) or BlockIsLeaves(a_BlockC))) then
		return false
	end
	for PosZ = z_Z,z_Z+5,1 do
		local a_BlockC = z_World:GetBlock(z_X,z_Y,PosZ)
		if(not (BlockIsWood(a_BlockC) or BlockIsLeaves(a_BlockC))) then
			break
		end
		DigAndSpawnPickup(z_World,z_X,z_Y,z_Z,m_Block)
	end
	for PosZ = z_Z-1,z_Z-5,-1 do
		local a_BlockC = z_World:GetBlock(z_X,z_Y,PosZ)
		if(not (BlockIsWood(a_BlockC) or BlockIsLeaves(a_BlockC))) then
			break
		end
		DigAndSpawnPickup(z_World,z_X,z_Y,PosZ,m_Block)
	end
	return true
end

function BlockIsWood(a_BlockID)
	return ((a_BlockID == E_BLOCK_LOG) or (a_BlockID == E_BLOCK_NEW_LOG))
end

function BlockIsLeaves( a_BlockID )
	return ((a_BlockID == E_BLOCK_LEAVES) or (a_BlockID == E_BLOCK_NEW_LEAVES))
end

function DigAndSpawnPickup(a_World, a_BlockX, a_BlockY, a_BlockZ,m_Block)
	local a_BlockC = a_World:GetBlock(a_BlockX, a_BlockY, a_BlockZ)
	if(not BlockIsWood(a_BlockC)) then 
		return
	end
	a_World:DigBlock(a_BlockX, a_BlockY, a_BlockZ)
	a_World:SpawnItemPickups(m_Block, a_BlockX, a_BlockY, a_BlockZ, math.random())
end

function GetSaplingMeta(a_BlockType, a_BlockMeta)
	if (a_BlockType == E_BLOCK_LOG) then
		return a_BlockMeta
	end
	return a_BlockMeta + 4
end
