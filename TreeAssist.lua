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
	local a_Block = a_World:GetBlock(a_BlockX,a_BlockY,a_BlockZ)
	if(not BlockIsWood(a_Block)) then
		return
	end
	CollectWood(a_World,a_BlockX, a_BlockY, a_BlockZ,a_BlockType, a_BlockMeta)
end

a_Coord={
	{-1,0,-1},
	{-1,0,0},
	{-1,0,1},
	{0,0,-1},
	--{0,0,0},
	{0,0,1},
	{1,0,-1},
	{1,0,0},
	{1,0,1},
	{0,1,0},
	{-1,1,-1},
	{-1,1,0},
	{-1,1,1},
	{0,1,-1},
	{0,1,1},
	{1,1,-1},
	{1,1,0},
	{1,1,1},
}

function CollectWood( a_World,a_BlockX,a_BlockY,a_BlockZ,a_BlockType,a_BlockMeta )
	local  a_Block = a_World:GetBlock(a_BlockX,a_BlockY,a_BlockZ)
	if((not BlockIsWood(a_Block)) or (a_Block~=a_BlockType)) then
		return
	end
	a_World:DigBlock(a_BlockX, a_BlockY, a_BlockZ)
	local a_Items = cItems()
	a_Items:Add(a_BlockType,1,a_BlockMeta % 4)
	a_World:SpawnItemPickups(a_Items, a_BlockX, a_BlockY, a_BlockZ, math.random())
	--plant a tree
	if(a_World:GetBlock(a_BlockX,a_BlockY-1,a_BlockZ) == E_BLOCK_DIRT) then
		a_World:SetBlock(a_BlockX, a_BlockY, a_BlockZ, E_BLOCK_SAPLING, a_BlockMeta, false)
	end
	--check next wood
	for i=1,17 do
		if(BlockIsWood(a_World:GetBlock(a_BlockX+a_Coord[i][1],a_BlockY+a_Coord[i][2],a_BlockZ+a_Coord[i][3]))) then
			CollectWood(a_World,a_BlockX+a_Coord[i][1],a_BlockY+a_Coord[i][2],a_BlockZ+a_Coord[i][3],a_BlockType,a_BlockMeta)
		end
	end
end

function BlockIsWood( a_BlockID )
	return (a_BlockID == E_BLOCK_LOG) or(a_BlockID == E_BLOCK_NEW_LOG)
end
