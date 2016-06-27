local _M = {}
local mt = { __index = _M }

_M.LOG_PATH = "/tmp/petrel.log"

_M.DEFAULT_CONTENT_TYPE = "text/html"

_M.TOKEN_EXPIRATION_TIME = 300 * 999999 -- Seconds
_M.SECRETKEYS = {dawiawnidnainw="ndiwnaidwaoiijiialndksnd"}

_M.ERR_MISSING_PARAM = 1
_M.ERR_INTERNAL = 2
_M.ERR_RESOURCE_NOT_FOUND = 3
_M.ERR_AUTH_FAILED = 4

_M.EMAIL_USE_TLS = true
_M.EMAIL_HOST = 'smtp.qq.com'
_M.EMAIL_PORT = 465
_M.EMAIL_HOST_USER = 'hevienz@qq.com'
_M.EMAIL_HOST_PASSWORD = 'arajmjruwnyacadddsds'
_M.DEFAULT_FROM_EMAIL = 'hevienz@qq.com'

_M.HTTP_TIMEOUT = 3000 -- mSeconds
_M.HTTP_KEEPALIVE = 3000 -- mSeconds
_M.HTTP_POOLSIZE = 3000

_M.RABBITMQ_HOST = "127.0.0.1"
_M.RABBITMQ_PORT = 61613
_M.RABBITMQ_USERNAME = "guest"
_M.RABBITMQ_PASSWORD = "guest"
_M.RABBITMQ_VHOST = "/"
_M.RABBITMQ_EXCHANGE_NAME = "petrel"
_M.RABBITMQ_QUEUE_NAME = "log"
_M.RABBITMQ_OPT_PERSISTENT = "true"
_M.RABBITMQ_TIMEOUT = 3000 -- mSeconds
_M.RABBITMQ_KEEPALIVE = 3000 -- mSeconds
_M.RABBITMQ_POOLSIZE = 3000

_M.REDIS_HOST = "127.0.0.1"
_M.REDIS_PORT = 6379

_M.POSTGRES_HOST = "127.0.0.1"
_M.POSTGRES_PORT = 5432
_M.POSTGRES_DB = "wiziot"
_M.POSTGRES_USER = "postgres"
_M.POSTGRES_PASSWORD = "password"
_M.POSTGRES_TIMEOUT = 3000 -- mSeconds
_M.POSTGRES_KEEPALIVE = 3000 -- mSeconds
_M.POSTGRES_POOLSIZE = 3000

_M.MONGO_HOST = "127.0.0.1"
_M.MONGO_PORT = 27017
_M.MONGO_TIMEOUT = 3000 -- mSeconds
_M.MONGO_KEEPALIVE = 3000 -- mSeconds
_M.MONGO_POOLSIZE = 3000

_M.UPLOAD_PATH = "/tmp/petrel/upload/"
_M.UPLOAD_TIMEOUT = 3000 -- mSeconds


return _M