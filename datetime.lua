local _M = {}
local mt = { __index = _M }

local os_date = os.date


function _M.strftime(ts)
    return os_date("%Y-%m-%d %H:%M:%S", ts)
end


return _M