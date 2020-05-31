require 'utils'

WEARABLE_ITEMS = LoadKeyValues("scripts/kv/wearable_items.txt")
CONTROL_POINTS = LoadKeyValues("scripts/kv/control_points.txt")
DARK_WILLOW_PARTS = {
    "models/items/dark_willow/the_naughty_witch_from_dark_woods_belt/the_naughty_witch_from_dark_woods_belt.vmdl",
    "models/items/dark_willow/the_naughty_witch_from_dark_woods_off_hand/the_naughty_witch_from_dark_woods_off_hand.vmdl",
    "models/items/dark_willow/the_naughty_witch_from_dark_woods_back/the_naughty_witch_from_dark_woods_back.vmdl",
    "models/items/dark_willow/the_naughty_witch_from_dark_woods_armor/the_naughty_witch_from_dark_woods_armor.vmdl",
    "models/items/dark_willow/the_naughty_witch_from_dark_woods_head/the_naughty_witch_from_dark_woods_head.vmdl"
}

RUBICK_ARCANA_PARTS = {
    "models/heroes/rubick/rubick_head.vmdl",
    "models/items/rubick/rubick_arcana/rubick_arcana_back.vmdl",
    "models/items/rubick/rubick_ti8_immortal_shoulders/rubick_ti8_immortal_shoulders.vmdl",
    "models/items/rubick/embrace_force_blue_weapon/embrace_force_blue_weapon.vmdl"
}

CM_ARCANA_PARTS = {
    "models/heroes/crystal_maiden/crystal_maiden_arcana_back.vmdl",
    "models/items/crystal_maiden/cm_ti9_immortal_weapon/cm_ti9_immortal_weapon.vmdl",
    "models/items/crystal_maiden/immortal_shoulders/cm_immortal_shoulders.vmdl",
    "models/items/crystal_maiden/cowl_of_ice/cowl_of_ice.vmdl",
    "models/items/crystal_maiden/np_arms/np_arms.vmdl",
}

if GameRules.Wearable == nil then
    GameRules.Wearable = {}
end

function GameRules.Wearable:HideWearables(unit)
    if(unit == nil or unit:IsNull()) then
        return
    end

    if(unit.hiddenWearables == nil) then
        unit.hiddenWearables = {}
    end
    
    local model = unit:FirstMoveChild()
    local toBeDeletedUnits = {}
    while model ~= nil do
        if(model.IsAttachedSkin == true) then
            table.insert(toBeDeletedUnits, model)
        elseif model:GetClassname() == "dota_item_wearable" then
            model:AddEffects(EF_NODRAW)
            table.insert(unit.hiddenWearables, model)
        end
        model = model:NextMovePeer()
    end

    for i, v in pairs(toBeDeletedUnits) do
        UTIL_Remove(v)
    end
end

function GameRules.Wearable:ShowWearables(unit)
    if(unit == nil or unit:IsNull()) then
        return
    end

    if(unit.hiddenWearables == nil) then
        return
    end

    for i,v in pairs(unit.hiddenWearables) do
        v:RemoveEffects(EF_NODRAW)
    end
end

function GameRules.Wearable:RemoveSkin(hUnit)
    if(hUnit.SkinParticles ~= nil) then
        for _,v in pairs(hUnit.SkinParticles) do
            ParticleManager:DestroyParticle(v, false)
            ParticleManager:ReleaseParticleIndex(v)
        end
    end
    table.clear(hUnit.SkinParticles)

    if(hUnit.DefaultModel ~= nil) then
        hUnit:SetOriginalModel(hUnit.DefaultModel)
        hUnit:NotifyWearablesOfModelChange(true)
    end

    if(hUnit:HasAbility("ability_hero_fly")) then
        hUnit:RemoveModifierByName("modifier_hero_fly")
        hUnit:RemoveAbility("ability_hero_fly")
    end
    
    hUnit:SetModelScale(1.0)
    GameRules.Wearable:ShowWearables(hUnit)
end

function GameRules.Wearable:WearSkin(hUnit, skinId, isFlying)
    if(hUnit == nil or hUnit:IsNull()) then
        return false
    end

    local info = WEARABLE_ITEMS[skinId]
    if(info == nil) then
        return false
    end

    GameRules.Wearable:HideWearables(hUnit)

    local skin = nil
    local groundModel = nil
    local flyModel = nil
    local particles = {}

    for i, v in pairs(info) do
        if(i == "skin") then
            skin = v
        elseif(type(v) == 'table') then
            if(v.type == "particle_create") then
                if(v.flying_courier_only == 1) then
                    if(isFlying) then
                        table.insert(particles, { model = v.modifier , attachPos = v.attachPos } )
                    end
                elseif(v.ground_courier_only == 1) then
                    if(isFlying == false) then
                        table.insert(particles, { model = v.modifier , attachPos = v.attachPos })
                    end
                else
                    table.insert(particles, { model = v.modifier , attachPos = v.attachPos })
                end
            end

            if(groundModel == nil and v.type == "courier") then
                groundModel = v.modifier
            end

            if(flyModel == nil and v.type == "courier_flying") then
                flyModel = v.modifier
            end
        end 
    end

    local modelName = groundModel
    if(isFlying) then
        modelName = flyModel
        SetAbility(hUnit, "ability_hero_fly", true)
    else
        if(hUnit:HasAbility("ability_hero_fly")) then
            hUnit:RemoveModifierByName("modifier_hero_fly")
            hUnit:RemoveAbility("ability_hero_fly")
        end
    end

    if(modelName == nil) then
        return false
    end

    if(hUnit.DefaultModel == nil) then
        hUnit.DefaultModel = hUnit:GetModelName()
    end

    hUnit:SetOriginalModel(modelName)
    hUnit:NotifyWearablesOfModelChange(true)
    hUnit:SetModel(modelName)
    hUnit:NotifyWearablesOfModelChange(false)

    if(skin ~= nil) then
        hUnit:SetSkin(skin)
    end

    if(hUnit.SkinParticles == nil) then
        hUnit.SkinParticles = {}
    end

    if(#particles > 0) then
        for _, p in pairs(particles) do
            GameRules.Wearable:AddParticle(hUnit, p.model, p.attachPos)
        end
    end

    if(skinId == "13680") then
        hUnit:SetModelScale(1.0)
        for i,v in pairs(DARK_WILLOW_PARTS) do
            local newWearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = v})
            newWearable.IsAttachedSkin = true
            newWearable:SetParent(hUnit, nil)
            newWearable:FollowEntity(hUnit, true)
        end
    elseif(skinId == "12451") then
        hUnit:SetModelScale(0.75)
        for i,v in pairs(RUBICK_ARCANA_PARTS) do
            local newWearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = v})
            newWearable.IsAttachedSkin = true
            newWearable:SetParent(hUnit, nil)
            newWearable:FollowEntity(hUnit, true)
        end
    elseif(skinId == "7385") then
        hUnit:SetModelScale(1.2)
        for i,v in pairs(CM_ARCANA_PARTS) do
            local newWearable = SpawnEntityFromTableSynchronous("prop_dynamic", {model = v})
            newWearable.IsAttachedSkin = true
            newWearable:SetParent(hUnit, nil)
            newWearable:FollowEntity(hUnit, true)

            if(v == "models/items/crystal_maiden/cm_ti9_immortal_weapon/cm_ti9_immortal_weapon.vmdl") then
                newWearable:SetSkin(1)
                newWearable.ParentUnit = hUnit 
                GameRules.Wearable:AddParticle(newWearable, "particles/econ/items/crystal_maiden/ti9_immortal_staff/cm_ti9_golden_staff_ambient.vpcf", nil)
            end
        end
    elseif(skinId == "11461" or skinId == "10758" or skinId == "11368" or skinId == "11997" or skinId == "10314") then
        hUnit:SetModelScale(1.35)
    else
        hUnit:SetModelScale(1.2)
    end

    return true
end

local attach_map = {
    customorigin = PATTACH_CUSTOMORIGIN,
    PATTACH_CUSTOMORIGIN = PATTACH_CUSTOMORIGIN,
    point_follow = PATTACH_POINT_FOLLOW,
    PATTACH_POINT_FOLLOW = PATTACH_POINT_FOLLOW,
    absorigin_follow = PATTACH_ABSORIGIN_FOLLOW,
    PATTACH_ABSORIGIN_FOLLOW = PATTACH_ABSORIGIN_FOLLOW,
    rootbone_follow = PATTACH_ROOTBONE_FOLLOW,
    PATTACH_ROOTBONE_FOLLOW = PATTACH_ROOTBONE_FOLLOW,
    renderorigin_follow = PATTACH_RENDERORIGIN_FOLLOW,
    PATTACH_RENDERORIGIN_FOLLOW = PATTACH_RENDERORIGIN_FOLLOW,
    absorigin = PATTACH_ABSORIGIN,
    PATTACH_ABSORIGIN = PATTACH_ABSORIGIN,
    customorigin_follow = PATTACH_CUSTOMORIGIN_FOLLOW,
    PATTACH_CUSTOMORIGIN_FOLLOW = PATTACH_CUSTOMORIGIN_FOLLOW,
    worldorigin = PATTACH_WORLDORIGIN,
    PATTACH_WORLDORIGIN = PATTACH_WORLDORIGIN
}

function GameRules.Wearable:AddParticle(hUnit, particle_name, attachPos)
    local attach_type = PATTACH_CUSTOMORIGIN
    local attach_entity = hUnit
    local p_table = CONTROL_POINTS[particle_name]
    if p_table then
        if p_table.attach_type then
            attach_type = attach_map[p_table.attach_type]
        end
        if p_table.attach_entity == "parent" then
            attach_entity = hUnit
        end
    end

    local p = CreateParticle(particle_name, attach_type, attach_entity, -1)

    if(hUnit.SkinParticles ~= nil) then
        table.insert(hUnit.SkinParticles, p)
    elseif(hUnit.ParentUnit ~= nil and hUnit.ParentUnit.SkinParticles ~= nil) then
        table.insert(hUnit.ParentUnit.SkinParticles, p)
    end

    if p_table and p_table["control_points"] then
        local cps = p_table["control_points"]
        for _cpi, cp_table in pairs(cps) do
            local control_point_index = cp_table.control_point_index

            attach_type = cp_table.attach_type
            if attach_type == "vector" then
                local vPosition = String2Vector(cp_table.cp_position)
                ParticleManager:SetParticleControl(p, control_point_index, vPosition)
            else
                local inner_attach_entity = attach_entity
                local attachment = cp_table.attachment
                if(attachment == "from_def" and attachPos ~= nil) then
                    attachment = attachPos
                end
                inner_attach_entity = hUnit

                local position = hUnit:GetAbsOrigin()
                if cp_table.position then
                    position = String2Vector(cp_table.position)
                end
                attach_type = attach_map[attach_type]

                if cp_table.attach_entity ~= "self" or attachment then
                    ParticleManager:SetParticleControlEnt(
                        p,
                        control_point_index,
                        inner_attach_entity,
                        attach_type,
                        attachment,
                        position,
                        true
                    )
                end
            end
        end
    end

    return p
end