local _M = {}
local mt = { __index = _M }

local log = require("log")
local sformat = string.format


function _M.maillog(tos, sbj, body)
    local ngx_localtime = ngx.localtime()
    local item = sformat([=[[  MAIL  ] "%s": %s <%s> %s]=], ngx_localtime, tos, sbj, body)
    log.filelog(item .. "\n")
end


function _M.rabbitmqlog(msg, contenttype)
    local ngx_localtime = ngx.localtime()
    local item = sformat([=[[RABBITMQ] "%s": <%s> %s]=], ngx_localtime, contenttype, msg)
    log.filelog(item .. "\n")
end


return _M
