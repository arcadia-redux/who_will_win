require 'res_def'
require 'shared'

function datadriven_roll_hero(data)
    if not IsServer() then return end

    local caster = data.caster
    if(caster == nil or caster:IsNull()) then
        return
    end

    local ab = caster:FindAbilityByName("ability_hero_roll")
    if(ab == nil or ab:IsActivated() == false) then
        SendMessageToPlayer(caster:GetPlayerID(), "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
        return
    end
    
    local playerId = caster:GetPlayerID()
    local particleName = ParticleRes.OPEN_ROLL_PANEL
    CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster, 5)
    EmitSoundOn(SoundRes.OPEN_ROLL_PANEL, caster)
    
    local playerInfo = GameRules.DW.PlayerList[playerId]

    if(playerInfo ~= nil) then
        playerInfo.LockRoll = 0
        if (playerInfo.Hero ~= nil and playerInfo.Hero:IsNull() == false) then
            GameRules.DW.ShowRollPanel(playerInfo.Hero)
        end
    end
end

function datadriven_sell_hero(data)
    if not IsServer() then return end

    local caster = data.caster

    if(caster == nil or caster:IsNull()) then
        return
    end

    local playerId = caster:GetPlayerID()
    local hero = data.target
    
    if(hero ~= nil and hero:IsNull() == false) then
        if(hero.GetPlayerID ~= nil and hero:GetPlayerID() ~= playerId) then
            return
        end

        local gridVector = GameRules.DW.FindGridInfo(playerId, hero)
        if(gridVector ~= nil) then
            local toBeSold = GameRules.DW.GetGridInfo(playerId, gridVector.x, gridVector.y)
            if(toBeSold ~= nil and toBeSold:IsNull() == false) then
                if(toBeSold.IsRealHero == nil or toBeSold:IsRealHero() == false) then
                    SendMessageToPlayer(playerId, "SHOW_PROMPT", {message = "CAN_NOT_DO_THIS"})
                    return
                end
            end

            local heroName = string.gsub(toBeSold:GetName(), HeroNamePrefix, "")
            if(GameRules.DW.RecycleHero[playerId] ~= nil and #GameRules.DW.RecycleHero[playerId] >= 5) then
                if(GameRules.DW.GetHeroCountInRecycleBin(playerId, heroName, toBeSold:GetLevel()) == 0) then
                    SendMessageToPlayer(playerId, "SELL_HERO_CONFIRM", { entindex = toBeSold:GetEntityIndex()})
                    return
                end
            end

            GameRules.DW.SellHero(gridVector, caster, true)
        end
    end
end

function datadriven_control_hero(data)
    if not IsServer() then return end

    local caster = data.caster

    if(caster == nil or caster:IsNull()) then
        return
    end

    local playerId = caster:GetPlayerID()
    local hero = data.target
    
    if(hero ~= nil and hero:IsNull() == false) then
        if(hero.GetPlayerID ~= nil and hero:GetPlayerID() ~= playerId) then
            return
        end

        local gridVector = GameRules.DW.FindGridInfo(playerId, hero)
        if(gridVector ~= nil) then
            GameRules.DW.ManualControl(gridVector, caster)
        end
    end
end

function datadriven_hero_ability_refresh(data)
    if not IsServer() then return end

    local caster = data.caster

    if(caster == nil or caster:IsNull()) then
        return
    end

    local playerId = caster:GetPlayerID()
    local hero = data.target
    
    if(hero ~= nil and hero:IsNull() == false) then
        if(hero.GetPlayerID ~= nil and hero:GetPlayerID() ~= playerId) then
            return
        end

        local gridVector = GameRules.DW.FindGridInfo(playerId, hero)
        if(gridVector ~= nil) then
            GameRules.DW.RefreshHero(gridVector, caster)
        end
    end
end

function datadriven_item_retrieve(data)
    if not IsServer() then return end

    local caster = data.caster

    if(caster == nil or caster:IsNull()) then
        return
    end
    
    local hero = data.target
    
    if(hero ~= nil and hero:IsNull() == false) then
        if(hero.GetPlayerID ~= nil and hero:GetPlayerID() ~= caster:GetPlayerID()) then
            return
        end

        local targetItemCount = 0
        for slotIndex = 0, 16 do
            if hero:GetItemInSlot(slotIndex) ~= nil then
                targetItemCount = targetItemCount + 1
            end
        end

        local casterItemCount = 0
        for slotIndex = 0, 16 do
            if caster:GetItemInSlot(slotIndex) ~= nil then
                casterItemCount = casterItemCount + 1
            end
        end

        if(targetItemCount + casterItemCount > 10 and casterItemCount > 0) then
            SendMessageToPlayer(caster:GetPlayerID(), "SHOW_PROMPT", {message = "ITEM_SLOT_FULL"})
            return
        end

        local itemCount = 0
        for slotIndex = 0, 16 do
            local item = hero:GetItemInSlot(slotIndex)
            if item ~= nil then
                itemCount = itemCount + 1
                local itemName = item:GetName()
                local stackCount = 0
                if(item:IsStackable()) then
                    for checkIndex = 0, 15 do
                        if(checkIndex <= 8 or checkIndex == 15) then
                            local checkItem = caster:GetItemInSlot(checkIndex)
                            if checkItem ~= nil and checkItem:GetName() == itemName then
                                stackCount = checkItem:GetCurrentCharges()
                                break
                            end
                        end
                    end
                end
                if(caster:HasRoomForItem(itemName, true, true) <= 2 or stackCount > 0) then
                    local newItem = caster:AddItemByName(itemName)
                    newItem:SetPurchaseTime(item:GetPurchaseTime())
                    local newStackCount = item:GetCurrentCharges() + stackCount
                    newItem:SetCurrentCharges(newStackCount)
                    if(itemName == "item_bloodstone") then
                        item.SavedCharges = item:GetCurrentCharges()
                    end
                    hero:RemoveItem(item)
                else
                    GameRules.DW.DropItem(hero, item)
                end
            end
        end
        
        if itemCount == 0 then
            local count = 0
            for slotIndex = 0, 16 do
                if(slotIndex <= 5 or slotIndex == 15 or slotIndex == 16) then
                    local item = caster:GetItemInSlot(slotIndex)
                    if item ~= nil then
                        count = count + 1
                        local itemName = item:GetName()
                        local newItem = hero:AddItemByName(itemName)
                        newItem:SetPurchaseTime(item:GetPurchaseTime())
                        newItem:SetCurrentCharges(item:GetCurrentCharges())
                        caster:RemoveItem(item)
                    end
                end
            end

            if(count > 0) then
                EmitSoundOn(SoundRes.RETRIEVE_ITEM_REVERSE, caster)
                local midas_particle = CreateParticle(ParticleRes.RETRIEVE_ITEM, PATTACH_ABSORIGIN_FOLLOW, hero, 3)
                ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetAbsOrigin(), false)
            else
                SendMessageToPlayer(caster:GetPlayerID(), "SHOW_PROMPT", {message = "HAS_NO_ITEM"})
            end
        else
            EmitSoundOn(SoundRes.RETRIEVE_ITEM, caster)
            local midas_particle = CreateParticle(ParticleRes.RETRIEVE_ITEM, PATTACH_ABSORIGIN_FOLLOW, caster, 3)
            ParticleManager:SetParticleControlEnt(midas_particle, 1, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
        end
    end
end

function datadriven_level_up(data)
    if not IsServer() then return end

    if(data.caster == nil or data.caster.GetPlayerID == nil) then
        return
    end

    local playerInfo = GameRules.DW.PlayerList[data.caster:GetPlayerID()]

    if(playerInfo ~= nil) then
        if(playerInfo.Hero == nil or playerInfo.Hero:IsNull()) then
            return
        end
        
        GameRules.DW.UpgradePlayer(playerInfo.Hero)
    end
end

--------------------------------------------------------------------------------------
LinkLuaModifier("modifier_hero_move", "hero_ability", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_hero_move_fly", "hero_ability", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hero_move_caster", "hero_ability", LUA_MODIFIER_MOTION_NONE)

ability_hero_move = class({})
function ability_hero_move:OnSpellStart(params)
    if not IsServer() then return end
    local caster = self:GetCaster()
    if caster:HasModifier("modifier_hero_move_caster") then
        local target_loc = self:GetCursorPosition()
        
        local gridVector = GameRules.DW.GetGridVectorByPosition(target_loc, caster:GetPlayerID())
        if(gridVector == nil) then
            return
        end

        local existHero = GameRules.DW.GetGridInfo(caster:GetPlayerID(), gridVector.x, gridVector.y)
        
        if(existHero ~= nil and existHero:IsNull() == false) then
            if(existHero ~= nil and existHero:HasModifier("modifier_hero_move_fly") == false) then
                local findVector = GameRules.DW.FindEmptyVectorNearBy(gridVector, caster:GetPlayerID())
                if(findVector == nil) then return nil end
                gridVector = findVector
            end
        end
        
        target_loc = GameRules.DW.GetPositionByGridVector(gridVector, caster:GetPlayerID())
        
        -- self.pos_marker_pfx = CreateParticle(ParticleRes.HERO_MOVE_DROP, PATTACH_CUSTOMORIGIN, caster, 3)
        -- ParticleManager:SetParticleControl(self.pos_marker_pfx, 0, target_loc)
        -- ParticleManager:SetParticleControl(self.pos_marker_pfx, 1, Vector(3, 0, 0))
        -- ParticleManager:SetParticleControl(self.pos_marker_pfx, 2, self.target_origin)
        -- ParticleManager:SetParticleControl(self.target_modifier.tele_pfx, 1, target_loc)
        
        self.target_modifier.final_loc = target_loc
        self.target_modifier.changed_target = true
        self:EndCooldown()

        if(self.target_modifier.duration == nil) then
            self.target_modifier.duration = self:GetSpecialValueFor("lift_duration")
        end

        if(self.target_modifier.fall_animation == nil) then
            self.target_modifier.fall_animation = self:GetSpecialValueFor("fall_animation")
        end
        
        self.target_modifier.current_time = self.target_modifier.duration - self.target_modifier.fall_animation
        ParticleManager:SetParticleControl(self.target_modifier.tele_pfx, 2, Vector(0, 0, 0))
        caster:RemoveModifierByName("modifier_hero_move_caster")
    else
        self.target = self:GetCursorTarget()
        if(self.target == nil) then
            return
        end

        if(self.target.GetPlayerID ~= nil and self.target:GetPlayerID() ~= caster:GetPlayerID()) then
            return
        end
        
        self.target_origin = self.target:GetAbsOrigin()

        local gridVector = nil

        gridVector = GameRules.DW.GetGridVectorByPosition(self.target_origin, caster:GetPlayerID())
        
        if(gridVector == nil) then
            return
        end

        local ab = caster:FindAbilityByName("ability_hero_roll")
        if(ab ~= nil) then
            ab:SetActivated(false)
        end
        
        local duration = self:GetSpecialValueFor("lift_duration")
        self.target:AddNewModifier(caster, self, "modifier_hero_move_fly", {duration = duration})
        
        self.target_modifier = self.target:AddNewModifier(caster, self, "modifier_hero_move", {duration = duration})
        
        self.target_modifier.tele_pfx = CreateParticle(ParticleRes.HERO_MOVE_LIFT, PATTACH_CUSTOMORIGIN, caster, 3)
        ParticleManager:SetParticleControlEnt(self.target_modifier.tele_pfx, 0, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.target_modifier.tele_pfx, 1, self.target, PATTACH_POINT_FOLLOW, "attach_hitloc", self.target:GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.target_modifier.tele_pfx, 2, Vector(duration, 0, 0))
        self.target_modifier:AddParticle(self.target_modifier.tele_pfx, false, false, 1, false, false)
        caster:EmitSound(SoundRes.HERO_MOVE_CASTER)
        self.target:EmitSound(SoundRes.HERO_MOVE_TARGET)
        
        self.target_modifier.final_loc = self.target_origin
        self.target_modifier.changed_target = false
        caster:AddNewModifier(caster, self, "modifier_hero_move_caster", {duration = duration + FrameTime()})
        SendMessageToPlayer(caster:GetPlayerID(), "CLICK_ABILITY", {name = "ability_hero_move"})
        
        self:EndCooldown()
    end
end

function ability_hero_move:GetBehavior()
    if self:GetCaster():HasModifier("modifier_hero_move_caster") then
        return DOTA_ABILITY_BEHAVIOR_POINT
    end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function ability_hero_move:CastFilterResultTarget(target)
    if IsServer() then
        local caster = self:GetCaster()
        local casterID = caster:GetPlayerOwnerID()
        local targetID = target:GetPlayerOwnerID()
        
        if target ~= nil and not target:IsOpposingTeam(caster:GetTeamNumber())
            and PlayerResource:IsDisableHelpSetForPlayerID(targetID, casterID) then
            return UF_FAIL_DISABLE_HELP
        end
        
        local nResult = UnitFilter(target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber())
        return nResult
    end
end

modifier_hero_move_caster = class({})
function modifier_hero_move_caster:IsDebuff() return false end
function modifier_hero_move_caster:IsHidden() return true end
function modifier_hero_move_caster:OnDestroy()
    local ability = self:GetAbility()
    if ability.pos_marker_pfx then
        CreateTimer(function()
            ParticleManager:DestroyParticle(ability.pos_marker_pfx, false)
            ParticleManager:ReleaseParticleIndex(ability.pos_marker_pfx)
        end, 0.5)
    end
end

--------------------------------------------------------------------------------------
modifier_hero_move = class({})
function modifier_hero_move:IsDebuff() return true end
function modifier_hero_move:IsHidden() return false end
function modifier_hero_move:IsMotionController() return true end
function modifier_hero_move:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_MEDIUM end
function modifier_hero_move:OnCreated(params)
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        self.parent = self:GetParent()
        self.z_height = 0
        self.duration = params.duration
        self.lift_animation = ability:GetSpecialValueFor("lift_animation")
        self.fall_animation = ability:GetSpecialValueFor("fall_animation")
        self.current_time = 0
        self.frametime = FrameTime()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_hero_move:OnIntervalThink()
    if IsServer() then
        self:VerticalMotion(self.parent, self.frametime)
        self:HorizontalMotion(self.parent, self.frametime)
    end
end

function modifier_hero_move:EndTransition()
    if IsServer() then
        if self.transition_end_commenced then
            return nil
        end
        
        self.transition_end_commenced = true
        
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local ability = self:GetAbility()
        
        GameRules.DW.SetUnitOnClearGround(parent)
        ResolveNPCPositions(parent:GetAbsOrigin(), 64)
        
        parent:RemoveModifierByName("modifier_hero_move_fly")
        
        local parent_pos = parent:GetAbsOrigin()
        local ability = self:GetAbility()
        GridNav:DestroyTreesAroundPoint(parent_pos, 325, true)
        
        parent:StopSound(SoundRes.HERO_MOVE_TARGET)
        parent:EmitSound(SoundRes.HERO_MOVE_LAND)
        if(self.tele_pfx) then
            ParticleManager:ReleaseParticleIndex(self.tele_pfx)
        end
        
        local landing_pfx = CreateParticle(ParticleRes.HERO_MOVE_LAND, PATTACH_CUSTOMORIGIN, self:GetCaster(), 3)
        ParticleManager:SetParticleControl(landing_pfx, 0, parent_pos)
        ParticleManager:SetParticleControl(landing_pfx, 1, parent_pos)
        
        ability:UseResources(true, false, true)
        
        local gridVector = GameRules.DW.GetGridVectorByPosition(parent:GetAbsOrigin(), caster:GetPlayerID())

        if(gridVector == nil) then
            return
        end
        
        GameRules.DW.MoveToGrid(caster:GetPlayerID(), gridVector.x, gridVector.y, parent)

        if(GameRules.DW.StageName[GameRules.DW.Stage] == "PREPARE" or table.exist(GameRules.DW.BattlePlayers, caster:GetPlayerID()) == false) then
            local ab = caster:FindAbilityByName("ability_hero_roll")
            if(ab ~= nil) then
                ab:SetActivated(true)
            end
        end
    end
end

function modifier_hero_move:VerticalMotion(unit, dt)
    if IsServer() then
        self.current_time = self.current_time + dt
        local max_height = self:GetAbility():GetSpecialValueFor("max_height")
        if self.current_time <= self.lift_animation then
            self.z_height = self.z_height + ((dt / self.lift_animation) * max_height)
            unit:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit) + Vector(0, 0, self.z_height))
        elseif self.current_time > (self.duration - self.fall_animation) then
            self.z_height = self.z_height - ((dt / self.fall_animation) * max_height)
            if self.z_height < 0 then self.z_height = 0 end
            unit:SetAbsOrigin(GetGroundPosition(unit:GetAbsOrigin(), unit) + Vector(0, 0, self.z_height))
        else
            max_height = self.z_height
        end
        
        if self.current_time >= self.duration then
            self:EndTransition()
            self:Destroy()
        end
    end
end

function modifier_hero_move:HorizontalMotion(unit, dt)
    if IsServer() then
        self.distance = self.distance or 0
        if (self.current_time > (self.duration - self.fall_animation)) then
            if self.changed_target then
                local frames_to_end = math.ceil((self.duration - self.current_time) / dt)
                self.distance = (unit:GetAbsOrigin() - self.final_loc):Length2D() / frames_to_end
                self.changed_target = false
            end
            if (self.current_time + dt) >= self.duration then
                unit:SetAbsOrigin(self.final_loc)
                self:EndTransition()
            else
                unit:SetAbsOrigin(unit:GetAbsOrigin() + ((self.final_loc - unit:GetAbsOrigin()):Normalized() * self.distance))
            end
        end
    end
end

function modifier_hero_move:GetTexture()
    return "rubick_telekinesis"
end

function modifier_hero_move:OnDestroy()
    if IsServer() then
        if not self.parent:IsAlive() then
            GameRules.DW.SetUnitOnClearGround(self.parent)
        end
    end
end

--------------------------------------------------------------------------------------
modifier_hero_move_fly = class({})
function modifier_hero_move_fly:IsDebuff() return false end
function modifier_hero_move_fly:IsHidden() return true end
function modifier_hero_move_fly:DeclareFunctions()
    local decFuns =
    {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
    return decFuns
end

function modifier_hero_move_fly:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end

function modifier_hero_move_fly:CheckState()
    local state =
    {
        [MODIFIER_STATE_UNSELECTABLE] = true
    }
    return state
end