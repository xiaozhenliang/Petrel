local _M = {}
local mt = { __index = _M }

local template = require "resty.template"
local cache = ngx.shared.cache
local log = require("log")
local customlog = require("customlog")
local config = require("config")
local utils = require("utils")
local mail = require("mail")
local rabbitmq = require("rabbitmq")
local auth = require("auth")
local mongo =require("mongo")
local postgres = require("postgres")
local redis = require("redis")
local render = require("render")
local http = require("http")
local upload = require "resty.upload"


function _M.admin()
    template.render("index.html")
end


function _M.upload()
    local request_method = ngx.var.request_method
    if request_method == "GET" then
        template.render("upload.html")
    elseif request_method == "POST" then
        local rt = {}
        local chunk_size = 4096
        local form, err = upload:new(chunk_size)
        if not form then
            log.ngxlog("failed to new upload: ", err)
            rt = {code=config.ERR_INTERNAL, msg="internal error", meta=err}
        end
        form:set_timeout(config.UPLOAD_TIMEOUT)
        while true do
            local typ, res, err = form:read()
            if not typ then
                rt = {code=config.ERR_INTERNAL, msg="internal error", meta=err }
                render.json(rt)
            end

            if typ == "header" then
                local file_name = string.match(res[2], [[filename%=%"(.+)%"]])
                if file_name == "" then file_name = nil end

                if file_name then
                    file = io.open(config.UPLOAD_PATH .. file_name, "w+")
                    if not file then
                        log.ngxlog("failed to open file ", file_name)
                        rt = {code=config.ERR_INTERNAL, msg="internal error", meta=err }
                        render.json(rt)
                    end
                end
            elseif typ == "body" then
                if file then
                    file:write(res)
                end
            elseif typ == "part_end" then
                if file then
                    file:close()
                    file = nil
                end

            elseif typ == "eof" then
                rt = {code=0}
                break
            else
            end
        end

        render.json(rt)
    end
end


function _M.qps()
    local rt = {}
    local ngx_localtime = ngx.localtime()
    local qps, err = cache:get("QPS." .. ngx_localtime)
    if err ~= nil then
        log.ngxlog("Can't get QPS in cache: " .. "QPS." .. ngx_localtime)
    end
    rt = {code=0, data={qps=qps, time=ngx_localtime}}
    render.json(rt)
end


function _M.token()
    local rt = {}
    local accesskey = ngx.var.arg_accesskey
    if not accesskey then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="accesskey"}
    else
        local secretkey = config.SECRETKEYS[accesskey]
        if not secretkey then
            rt = {code=config.ERR_RESOURCE_NOT_FOUND, msg="resource not found", meta=accesskey }
        else
            local token = auth.genToken(accesskey, secretkey)
            rt = {code=0, data=token }
        end
    end
    render.json(rt)
end


function _M.mail()
    local rt = {}
    local accesskey = ngx.var.arg_accesskey
    local token = ngx.var.arg_token
    local sbj = ngx.var.arg_subject
    local tos = ngx.var.arg_tos
    local body = ngx.var.arg_body
    if not accesskey then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="accesskey"}
    elseif not token then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="token"}
    elseif not sbj then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="subject"}
    elseif not tos then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="tos"}
    elseif not body then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="body"}
    else
        local ok, err = auth.tokenCheck(accesskey, token)
        if not ok then
            rt = {code=config.ERR_AUTH_FAILED, msg="auth failed", meta=err}
        else
            local tos_t = utils.split(tos, ",")
            local ret, err = mail.send(tos_t, sbj, body)
            if err then
                rt = {code=config.ERR_INTERNAL, msg="internal error", meta=err}
            else
                customlog.maillog(tos, sbj, body)
                rt = {code=0, meta=ret}
            end
        end
    end
    render.json(rt)
end


function _M.rabbitmq()
    local rt = {}
    local accesskey = ngx.var.arg_accesskey
    local token = ngx.var.arg_token
    local msg = ngx.var.arg_msg
    local contenttype = ngx.var.arg_contenttype
    if not accesskey then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="accesskey"}
    elseif not token then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="token"}
    elseif not msg then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="msg"}
    elseif not contenttype then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="contenttype"}
    else
        local ok, err = auth.tokenCheck(accesskey, token)
        if not ok then
            rt = {code=config.ERR_AUTH_FAILED, msg="auth failed", meta=err}
        else
            local ok, err = rabbitmq.send(msg, contenttype)
            if not ok then
                rt = {code=config.ERR_INTERNAL, msg="internal error", meta=err}
            else
                customlog.rabbitmqlog(msg, contenttype)
                rt = {code=0}
            end
        end
    end
    render.json(rt)
end


function _M.mongo()
    local rt = {}
    local accesskey = ngx.var.arg_accesskey
    local token = ngx.var.arg_token
    local db = ngx.var.arg_db
    local col = ngx.var.arg_col
    local query = ngx.var.arg_query
    local includefields = ngx.var.arg_returnfields or ""
    local excludefields = ngx.var.arg_excludefields or ""
    local num_each_query = ngx.var.arg_num_each_query or 0
    if not accesskey then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="accesskey"}
    elseif not token then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="token"}
    elseif not db then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="db"}
    elseif not col then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="col"}
    else
        local ok, err = auth.tokenCheck(accesskey, token)
        if not ok then
            rt = {code=config.ERR_AUTH_FAILED, msg="auth failed", meta=err}
        else
            local returnfields = mongo.parseReturnFields(includefields, excludefields)
            local res_table = mongo.find(db, col, query, returnfields, num_each_query)
            rt = {code=0, data=res_table}
        end
    end
    render.json(rt)
end


function _M.postgres()
    local rt = {}
    local accesskey = ngx.var.arg_accesskey
    local token = ngx.var.arg_token
    local sql = ngx.var.arg_sql
    if not accesskey then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="accesskey"}
    elseif not token then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="token"}
    elseif not sql then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="sql"}
    else
        local ok, err = auth.tokenCheck(accesskey, token)
        if not ok then
            rt = {code=config.ERR_AUTH_FAILED, msg="auth failed", meta=err}
        else
            local realsql = ngx.unescape_uri(sql)
            local res_table, err = postgres.query(realsql)
            if err then
                rt = {code=config.ERR_INTERNAL, msg="internal error", meta=err }
            else
                rt = {code=0, data=res_table }
            end
        end
    end
    render.json(rt)
end


function _M.redis()
    local rt = {}
    local accesskey = ngx.var.arg_accesskey
    local token = ngx.var.arg_token
    local key = ngx.var.arg_key
    if not accesskey then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="accesskey"}
    elseif not token then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="token"}
    elseif not key then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="key"}
    else
        local ok, err = auth.tokenCheck(accesskey, token)
        if not ok then
            rt = {code=config.ERR_AUTH_FAILED, msg="auth failed", meta=err}
        else
            local value, err = redis.get_smembers_from_cache_or_redis(key)
            if err then
                rt = {code=config.ERR_INTERNAL, msg="internal error", meta=err}
            else
                rt = {code=0, data=value}
            end
        end
    end
    render.json(rt)
end


function _M.http()
    local rt = {}
    local accesskey = ngx.var.arg_accesskey
    local token = ngx.var.arg_token
    local uri = ngx.var.arg_uri
    local method = ngx.var.arg_method
    local body = ngx.var.arg_body
    local headers = ngx.var.arg_headers
    if not accesskey then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="accesskey"}
    elseif not token then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="token"}
    elseif not uri then
        rt = {code=config.ERR_MISSING_PARAM, msg="param is missing", meta="uri"}
    else
        local ok, err = auth.tokenCheck(accesskey, token)
        if not ok then
            rt = {code=config.ERR_AUTH_FAILED, msg="auth failed", meta=err}
        else
            local headers_t = http.parseHeaders(headers)
            local res, err = http.request_uri(uri, method, body, headers_t)
            if not res then
                log.ngxlog("Http request error: ", err)
                res = {
                    status = ngx.HTTP_BAD_GATEWAY,
                    body = "HTTP_BAD_GATEWAY",
                    header = {content_type = config.DEFAULT_CONTENT_TYPE}
                }
            end
            render.render(res)
        end
    end
    render.json(rt)
end


return _M
