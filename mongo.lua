local _M = {}
local mt = { __index = _M }

local mongol = require("resty.mongol")
local table_insert = table.insert
local config = require("config")
local log = require("log")
local utils = require("utils")


function parseItem(itable)
    local rt_table = {}
    for k, v in pairs(itable) do
        if k == "_id" then
            rt_table[k] = v:tostring()
        elseif type(v) == "table" then
            rt_table[k] = utils.parseTable(v)
        else
            rt_table[k] = v
        end
    end
    return rt_table
end


function _M.parseReturnFields(includefields, excludefields)
    local returnfields = {}
    if includefields then
        local includefields_t = utils.split(includefields, ",")
        for _,v in ipairs(includefields_t) do
            returnfields[v] = 1
        end
    end

    if excludefields then
        local excludefields_t = utils.split(excludefields, ",")
        for _,v in ipairs(excludefields_t) do
            returnfields[v] = 0
        end
    end

    return returnfields
end


function _M.find(db, col, query, returnfields, num_each_query)
    local mc = mongol()
    mc:set_timeout(config.MONGO_TIMEOUT)
    local ok, err = mc:connect(config.MONGO_HOST, config.MONGO_PORT)
    if not ok then
        log.ngxlog("Can't connect to mongodb:", err)
        return nil, err
    end
    local mdb = mc:new_db_handle(db)
    local col = mdb:get_col(col)
    local cursor = col:find(query, returnfields, num_each_query)
    local items = {}
    for _,item in cursor:pairs() do
        table_insert(items, parseItem(item))
    end
    mc:set_keepalive(config.MONGO_KEEPALIVE, config.MONGO_POOLSIZE)
    return items
end


return _M
