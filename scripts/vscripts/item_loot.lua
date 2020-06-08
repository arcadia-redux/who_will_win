if ItemLoot == nil then ItemLoot = class({}) end

-- 物品掉落管理器
-- 触发功能 写在 Spawner 里面

function ItemLoot:Init()
      
   --掉落表
   ItemLoot.lootPool = {} 
   --掉落的物品计数
   ItemLoot.lootNumber = {} 
   --掉落的物品概率累加
   ItemLoot.lootChance = {} 

   --每级给玩家的掉落数量
   ItemLoot.lootPerLevel = 1

   if GetMapName()=="2x6" then
      ItemLoot.lootPerLevel = 2
   end

   if GetMapName()=="5v5" then
      ItemLoot.lootPerLevel = 5
   end

   for i=1,5 do
   	  ItemLoot.lootPool[i] = {} 
   	  ItemLoot.lootNumber[i] = {} 
   	  ItemLoot.lootChance[i] = {} 
   end
   
   local neutralItemKV =LoadKeyValues("scripts/npc/neutral_items.txt")
   for slevel, levelData in pairs(neutralItemKV) do
      if levelData and type(levelData) == "table" then
         for key,data in pairs(levelData) do
          	if key =="items" then
          		for k,v in pairs(data) do
          			table.insert(ItemLoot.lootPool[tonumber(slevel)], k)
          		end
          	end
         end
      end
   end

   ItemLoot.flChanceStack = 0.00068
   
   if GetMapName()=="2x6" then
      ItemLoot.flChanceStack = 0.00035
   end
   if GetMapName()=="5v5" then
      ItemLoot.flChanceStack = 0.00014
   end

end


function ItemLoot:DropItem(hUnit,nLevel,nTeamNumber)
    
  ItemLoot.lootNumber[nLevel][nTeamNumber] = ItemLoot.lootNumber[nLevel][nTeamNumber]+1

	local nItemIndex = RandomInt(1, #ItemLoot.lootPool[nLevel])
    local sItemName =  ItemLoot.lootPool[nLevel][nItemIndex]
    local hNewItem = CreateItem(sItemName, nil, nil)
    
    local hNewWorldItem = CreateItemOnPositionSync(hUnit:GetOrigin(), hNewItem)
    hNewItem:LaunchLoot(false, RandomFloat(300, 450), 0.5, hUnit:GetOrigin() + RandomVector(RandomFloat(100, 200)))
    hNewItem.nTeamNumber = nTeamNumber
    
    Timers:CreateTimer({
        endTime = 0.5,
        callback = function()
            EmitGlobalSound("ui.inv_drop_highvalue")
        end
    })
end