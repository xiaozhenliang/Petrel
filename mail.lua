local _M = {}
local mt = { __index = _M }

local smtp = require("resty.smtp")
local mime = require("resty.smtp.mime")
--local ltn12 = require("resty.smtp.ltn12")
local config = require("config")


function _M.send(tos, subject, body)
    local msg = {
        headers= {
            subject= mime.ew(subject, nil,
                { charset= "utf-8" }),
            ["content-transfer-encoding"]= "BASE64",
            ["content-type"]= "text/plain; charset='utf-8'",
        },
        body= mime.b64(body)
    }
    local ret, err = smtp.send {
        from= config.DEFAULT_FROM_EMAIL,
        rcpt= tos;
        user= config.EMAIL_HOST_USER,
        password= config.EMAIL_HOST_PASSWORD,
        server= config.EMAIL_HOST,
        port= config.EMAIL_PORT,
        source= smtp.message(msg),
        ssl= { enable= config.EMAIL_USE_TLS, verify_cert= false },
    }
    return ret, err
end


return _M
