local view = require("view")
local route = require("route")
router = route.new()


router:add("/__admin__/", view.admin)
router:add("/__admin__/upload/", view.upload)

router:add("/__api__/qps/", view.qps)

router:add("/__api__/token/", view.token)

router:add("/__api__/mail/", view.mail)
router:add("/__api__/rabbitmq/", view.rabbitmq)
router:add("/__api__/mongo/", view.mongo)
router:add("/__api__/postgres/", view.postgres)
router:add("/__api__/redis/", view.redis)
router:add("/__api__/http/", view.http)
