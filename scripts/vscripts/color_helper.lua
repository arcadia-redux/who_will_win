if ColorHelper == nil then ColorHelper = class({}) end

function ColorHelper.TableToCssColor(tbl)
    local hex = '#'
    hex = hex .. ColorHelper.ToHex(tbl[1])
    hex = hex .. ColorHelper.ToHex(tbl[2])
    hex = hex .. ColorHelper.ToHex(tbl[3])
    return hex
end

function ColorHelper.TableToRgbColor(tbl)
    local hex = 'rgb('
    hex = hex .. tbl[1] .. ','
    hex = hex .. tbl[2] .. ','
    hex = hex .. tbl[3] .. ')'
    return hex
end

function ColorHelper.ToHex(value)
    return string.format('%02X', ColorHelper.ToBit(value))
end

function ColorHelper.ToBit(value)
    value = tonumber(value)
    if value and value <= 255 then
        return value
    end
    return 255
end