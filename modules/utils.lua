--[[ utility functions ]]--
-- General utility functions used across modules

-- Deep merge two tables, preserving existing values in dst
function RoRota:DeepMerge(dst, src)
    if type(dst) ~= 'table' then dst = {} end
    if type(src) ~= 'table' then return dst end
    for k, v in pairs(src) do
        if type(v) == 'table' then
            dst[k] = self:DeepMerge(dst[k], v)
        else
            if dst[k] == nil then dst[k] = v end
        end
    end
    return dst
end
