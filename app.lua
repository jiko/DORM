local _M = {}

local cjson = require "cjson"
local mysql = require "resty.mysql"
local math = require "math"

local encode = cjson.encode
local random = math.random
local insert = table.insert


function _M.handler(ngx)
    ngx.header.content_type = 'application/json'
    
    if ngx.var.uri == '/json' then
        local resp = {message = "Hello, World!"}
        ngx.print( encode(resp) )
    elseif ngx.var.uri == '/db' then

        local mysqlconn = {
            host = "127.0.0.1",
            port = 3306,
            database = "hello_world",
            user = "benchmarkdbuser",
            password = "benchmarkdbpass"
        }

        local db, err = mysql:new()
        if not db then
          ngx.say("failed to instantiate mysql: ", err)
          return
        end

        local ok, err = db:connect(mysqlconn)
        if not ok then
          ngx.say("failed to connect: ", err)
        end

        local num_queries = tonumber(ngx.var.arg_queries) or 1
        local worlds = {}
        for i=1, num_queries do
            local wid = random(1, 10000)
            local res, err, errno, sqlstate =
                db:query('SELECT * FROM World WHERE id = '..wid)
            if not res then
                ngx.say("bad result: ", err, ": ", errno, ".")
                return
            end
            insert(worlds, res[1])
        end
        ngx.print( encode(worlds) )
        local ok, err = db:set_keepalive(0, 256)
    elseif ngx.var.uri == '/plaintext' then
        ngx.header.content_type = 'text/plain'
        ngx.print('Hello, World!')
    end
end

return _M
