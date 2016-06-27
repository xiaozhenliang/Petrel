local _M = {}
local mt = { __index = _M }

local http = require("resty.http")
local config = require("config")
local utils = require("utils")
local log = require("log")

function _M.parseHeaders(headers)
    local headers_t = {}
    if headers then
        local items = utils.split(headers, ";;;")
        for _,item in ipairs(items) do
            local item_k_v = utils.split(item, ":::")
            local k = item_k_v[1]
            local v = item_k_v[2]
            headers_t[k] = v
        end
    end
    return headers_t
end


function _M.request_uri(uri, method, body, headers)
    local httpc = http.new()
    httpc:set_timeout(config.HTTP_TIMEOUT)

    local res, err = httpc:request_uri(uri, {
        method = method,
        body = body,
        headers = headers,
    })

    httpc:set_keepalive(config.HTTP_KEEPALIVE, config.HTTP_POOLSIZE)
    return res, err
end


return _M