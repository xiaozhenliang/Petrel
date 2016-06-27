local _M = {}
local mt = { __index = _M }


function _M.split(str, sep)
    local fields = {}
    str:gsub("[^"..sep.."]+", function(c) fields[#fields+1] = c end)
    return fields
end


function _M.parseTable(itable)
    local rt_table = {}
    for k, v in pairs(itable) do
        if type(v) == "table" then
            rt_table[k] = _M.parseTable(v)
        elseif type(v) == "function" then
            rt_table[k] = "<function>"
        else
            rt_table[k] = v
        end
    end
    return rt_table
end


return _M