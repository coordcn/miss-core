local object            = require("miss-core.src.object")
local http              = require("miss-core.src.http")
local log               = require("miss-core.src.log")
local utils             = require("miss-core.src.utils")
local uuid              = require("miss-core.src.uuid")
local querystring       = require("miss-core.src.querystring")
local uri               = require("miss-core.src.uri")
local xml               = require("miss-core.src.xml")

return {
        object          = object,
        http            = http,
        log             = log,
        utils           = utils,
        uuid            = uuid,
        querystring     = querystring,
        uri             = uri,
        xml             = xml,
}
