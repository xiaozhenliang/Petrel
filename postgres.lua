local _M = {}
local mt = { __index = _M }

local config = require("config")
local postgres = require("resty.postgres")


function _M.query(sql)
    local pg = postgres:new()
    pg:set_timeout(config.POSTGRES_TIMEOUT)
    local ok, err = pg:connect({
        host=config.POSTGRES_HOST,
        port=config.POSTGRES_PORT,
        database=config.POSTGRES_DB,
        user=config.POSTGRES_USER,
        password=config.POSTGRES_PASSWORD
    })
    if not ok then
        ngxlog("Can't connect to postgres:", err)
        return nil, err
    end
    local results, err = pg:query(sql)
    pg:set_keepalive(config.POSTGRES_KEEPALIVE, config.POSTGRES_POOLSIZE)
    return results, err
end


return _M