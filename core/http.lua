local _M = {}

function _M.get(url, args, headers)
        if headers then
                for key, val in pairs(headers) do
                        ngx.req.set_header(key, val)
                end
        end

        local ret = ngx.location.capture("/proxy/" .. url, {
                method = ngx.HTTP_GET,
                args = args,
        })

        return ret
end

function _M.post(url, body, headers)
        if headers then
                for key, val in pairs(headers) do
                        ngx.req.set_header(key, val)
                end
        end

        local ret = ngx.location.capture("/proxy/" .. url, {
                method = ngx.HTTP_POST,
                body = body,
        })

        return ret
end

return _M
