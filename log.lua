local _M = {}
local mt = { __index = _M }

local cjson = require "cjson"
local config = require("config")
local utils = require("utils")


function _M.debuglog(...)
    local itable = {}
    for i = 1, select("#", ...) do
        local item = select(i, ...)
        if type(item) == "table" then
            itable[i] = utils.parseTable(item)
        else
            itable[i] = item
        end
    end
    ngx.log(ngx.ERR, "[PETREL-DEBUG] ", cjson.encode(itable))
end


function _M.ngxlog(...)
    ngx.log(ngx.ERR, "[PETREL] ", ...)
end


local fd, err = io.open(config.LOG_PATH, "ab")
if not fd then
    _M.ngxlog(err)
end


function _M.filelog(item)
    fd:write(item)
    fd:flush()
end


return _M
