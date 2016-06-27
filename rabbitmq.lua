local _M = {}
local mt = { __index = _M }

local rabbitmq = require "resty.rabbitmqstomp"
local config = require("config")
local log = require("log")


function _M.send(msg, contenttype)
    local opts = {
        username = config.RABBITMQ_USERNAME,
        password = config.RABBITMQ_PASSWORD,
        vhost = config.RABBITMQ_VHOST
    }
    local mq, err = rabbitmq:new(opts)
    if not mq then
        log.ngxlog("Can't new rabbitmq: " .. err)
        return nil, err
    end
    mq:set_timeout(config.RABBITMQ_TIMEOUT)

    local ok, err = mq:connect(config.RABBITMQ_HOST, config.RABBITMQ_PORT)
    if not ok then
        log.ngxlog("Can't connect to rabbitmq: " .. err)
        return nil, err
    end

    local headers = {}
    headers["destination"] = "/exchange/" .. config.RABBITMQ_EXCHANGE_NAME .. "/" .. config.RABBITMQ_QUEUE_NAME
    headers["persistent"] = config.RABBITMQ_OPT_PERSISTENT
    headers["content-type"] = contenttype

    local ok, err = mq:send(msg, headers)
    if not ok then
        log.ngxlog("Can't send to rabbitmq: " .. err)
        return nil, err
    end
    --log.ngxlog("Send to rabbitmq success")

    mq:set_keepalive(config.RABBITMQ_KEEPALIVE, config.RABBITMQ_POOLSIZE)
    return true, nil
end


return _M