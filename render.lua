local _M = {}
local mt = { __index = _M }

local cjson = require "cjson"


function _M.json(json)
    ngx.status = ngx.HTTP_OK
    ngx.header.content_type = "application/json"
    ngx.say(cjson.encode(json))
    ngx.exit(ngx.HTTP_OK)
end


function _M.render(response)
    ngx.status = response.status
    ngx.header = response.headers
    ngx.say(response.body)
    ngx.exit(response.status)
end


function _M.error(text)
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    ngx.header.content_type = config.DEFAULT_CONTENT_TYPE
    ngx.say(text)
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end


return _M
