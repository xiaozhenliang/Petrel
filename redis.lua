local _M = {}
local mt = { __index = _M }


local redis = require("resty.redis_iresty")
local log = require("log")
local utils = require("utils")
local cache = ngx.shared.cache


local red = redis:new()


function _M.get_value_from_cache_or_redis(key)
    local value = cache:get(key)
    if value then
        return value, nil
    else
        local value, err = red:get(key)
        if value then
            cache:safe_set(key, value, 600)
            return value, nil
        else
            log.ngxlog("Can't get " .. key .. " from redis: ", err)
            return nil, err
        end
    end
end


function _M.get_smembers_from_cache_or_redis(key)
    local str = cache:get(key)
    if str then
        return utils.split(str, "|||||"), nil
    else
        local res, err = red:smembers(key)
        if res then
            local str = ""
            for key, value in ipairs(res) do
                if key == 1 then
                    str = value
                else
                    str = str .. "|||||" .. value
                end
            end
            cache:safe_set(key, str, 600)
            return res, nil
        else
            log.ngxlog("Can't get " .. key .. " from redis: ", err)
            return nil, err
        end
    end
end


return _M