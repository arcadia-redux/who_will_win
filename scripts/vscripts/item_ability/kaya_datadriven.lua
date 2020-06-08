function ToggleKaya(keys)
    local hCaster = keys.caster
    local hAbility = keys.ability
    if hCaster:HasModifier("modifier_kaya_3_datadriven") then
        local hAbility = hCaster:FindModifierByName("modifier_kaya_3_datadriven"):GetAbility()
        hCaster.flSP = hAbility:GetSpecialValueFor("spell_amplify")
    elseif hCaster:HasModifier("modifier_kaya_2_datadriven") then
        local hAbility = hCaster:FindModifierByName("modifier_kaya_2_datadriven"):GetAbility()
        hCaster.flSP = hAbility:GetSpecialValueFor("spell_amplify")
    else
        hCaster.flSP = nil
    end

    if hCaster.flSP ~= nil then
        --print(hCaster:GetUnitName() .. "'flSP: " .. hCaster.flSP)
    else
        --print(hCaster:GetUnitName() .. "'flSP is nil")
    end
end