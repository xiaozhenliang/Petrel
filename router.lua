local uri = ngx.var.uri
local cache = ngx.shared.cache
local log = require("log")
local config = require("config")
local ngx_localtime = ngx.localtime()


cache:add("QPS." .. ngx_localtime, 0)
cache:incr("QPS." .. ngx_localtime, 1)


local handler = router:dispatch(uri)
if handler then
    local response = handler()
    local response_type = type(response)
    if response_type == "string" then
        ngx.status = ngx.HTTP_OK
        ngx.header.content_type = config.DEFAULT_CONTENT_TYPE
        ngx.say(response)
        ngx.exit(ngx.HTTP_OK)
    elseif response_type == "table" then
        ngx.status = response.status
        ngx.header = response.header
        ngx.say(response.body)
        ngx.exit(response.status)
    elseif response_type == "nil" then
    else
        ngx.status = ngx.HTTP_SERVICE_UNAVAILABLE
        ngx.header.content_type = config.DEFAULT_CONTENT_TYPE
        ngx.say("RESPONSE WRONG TYPE")
        ngx.exit(ngx.HTTP_SERVICE_UNAVAILABLE)
    end
else
    local res = ngx.location.capture(ngx.var.request_uri)
    ngx.status = res.status
    ngx.header = res.header
    ngx.say(res.body)
    ngx.exit(res.status)
end

