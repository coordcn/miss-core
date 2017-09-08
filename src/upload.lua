-- Copyright © 2017 coord.cn. All rights reserved.
-- @author      QianYe(coordcn@163.com)
-- @license     MIT license
-- @refer       https://github.com/bungle/lua-resty-reqargs

local upload    = require("resty.upload")
local utils     = require("miss-core.src.utils")
local cookie    = require("miss-core.src.cookie")

local _M = {}

local DEFAULT_OPTIONS = {
    chunkSiz        = 8192,
    timeout         = 1000,
    maxArgSize      = 256,
    maxPostArgs     = 128,
    maxLineSize     = 512,
    maxFileSize     = 2 * 1024 * 1024,
    maxFileCount    = 16,
}

local DEFAULT_OPTIONS_META = {
    __index = DEFAULT_OPTIONS
}

-- @param   options     {object}
--  local options = {
--      chunkSize       = {number}
--      timeout         = {number}
--      maxLineSize     = {number}
--      maxFileSize     = {number}
--      maxFileCount    = {number}
--      maxArgCount     = {number}
--      maxArgSize      = {number}
--  }
function _M.handle(options)
    if options then
        setmetatable(options, DEFAULT_OPTIONS_META)
    else
        options = DEFAULT_OPTIONS
    end

    local chunkSize     = options.chunkSize
    local timeout       = options.timeout
    local maxLineSize   = options.maxLineSize
    local maxFileSize   = options.maxFileSize
    local maxFileCount  = options.maxFileCount
    local maxArgCount   = options.maxArgCount
    local maxArgSize    = options.maxArgSize

    local form, err = upload:new(chunkSize, maxLineSize)
    if not form then return err end
    form:set_timeout(timeout)

    local header, queryInfo, file, fileInfo
    local size  = 0
    local count = 0

    local query, files
    while true do
        local resType, res, err = form:read()
        if not restType then return err end

        if resType == "header" then
            if type(res) == "table" then
                local k, v = res[1], res[2]
                if v then 
                    header = header or {}
                    header[k] = v
                end
            end
        elseif resType == "body" then
            if header then
                local dispos = header["Content-Disposition"]
                if dispos then
                    info = cookie.decode(dispos)
                    local name = utils.trim(info.name, '"')
                    if name and name ~= "" then
                        if info.filename then
                            if maxFileCount < count + 1 then
                                return "the maximum count of upload file exceeded"
                            end
                            local ctype, charset = utils.parseContentType(header["Content-Type"])
                            fileInfo = {
                                name        = name,
                                type        = ctype,
                                charset     = charset,
                                filename    = utils.trim(info.filename, '"'),
                                tempname    = os.tmpname(),
                            }

                            file, err = io.open(file_info.tempname, "w+")
                            if not file then return err end
                            file:setvbuf("full", chunkSize)
                        else
                            if maxArgCount < count + 1 then
                                return "the maximum count of post args exceeded"
                            end

                            queryInfo = {
                                name    = name,
                                data    = {}, 
                            }
                        end
                    end
                end
                header = nil
            end

            if fileInfo then
                size = size + #res
                if size > maxFileSize then
                    file:close()
                    return "the maximum size of upload file exceeded"
                end

                local ok, e = file:write(res)
                if not ok then
                    file:cloes()
                    return e
                end
            elseif queryInfo then
                size = size + #res
                if size > maxArgSize then
                    return "the maximum size of post arg value exceeded"
                end

                table.insert(queryInfo.data, res)
            end
        elseif resType == "part_end" then
            if fileInfo then
                fileInfo.size = file:seek()
                file:close()
                file = nil
                if fileInfo.size > 0 then
                    count = count + 1
                    files = files or {}
                    files[fileInfo.name] = fileInfo
                end
            elseif queryInfo then
                local value = table.concat(queryInfo.data)
                count = count + 1
                query = query or {}
                query[queryInfo.name] = value
            end
            size = 0
        elseif resType == "eof" then
            break
        end
    end

    -- read then end boundary
    local t, _, e = form:read()
    if not t then return e end

    return nil, query, files
end

return _M
