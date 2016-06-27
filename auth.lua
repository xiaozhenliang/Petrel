local _M = {}
local mt = { __index = _M }

local utils = require("utils")
local config = require("config")


function _M.tokenCheck(accesskey, token)
    local rowtoken = ngx.decode_base64(token)
    local token_table = utils.split(rowtoken, ":")
    local time = token_table[1]
    local digest = token_table[2]
    if not time or not tonumber(time) then
        return false, "token is invalid"
    end
    if not digest then
        return false, "token is invalid"
    end
    if time + config.TOKEN_EXPIRATION_TIME < ngx.now() then
        return false, "token is expired, " .. time
    end
    local rowstring = time .. accesskey
    local secretkey = config.SECRETKEYS[accesskey]
    if not secretkey then
        return false, "accesskey is invalid"
    end
    local realdigest = ngx.hmac_sha1(secretkey, rowstring)
    if digest ~= realdigest then
        return false, "token is invalid"
    end
    return true, nil
end


function _M.genToken(accesskey, secretkey)
    local time = ngx.now()
    local rowstring = time .. accesskey
    local digest = ngx.hmac_sha1(secretkey, rowstring)
    local rowtoken = time .. ":" .. digest
    local token = ngx.encode_base64(rowtoken)
    return token
end


return _M
