package.path = "/home/s/apps/nginx/conf/?.lua"

local reqmonit = require("reqmonit")
local host = ngx.var.host
local port = ngx.var.server_port
local request_time = ngx.var.request_time
local body_bytes_sent = ngx.var.body_bytes_sent
local status = ngx.var.status
local domain = ngx.shared.domain

svrname_key = table.concat({host,"-",port})

--domain.rec(ngx.shared.domain, svrname_key)
domain:set(svrname_key,'60')

--请求时间
reqmonit.stat(ngx.shared.statics_dict, svrname_key, request_time, '-sumtime')

--记录总请求数
reqmonit.stat(ngx.shared.statics_dict, svrname_key, 1, '-count')

--记录流量
reqmonit.stat(ngx.shared.statics_dict, svrname_key, body_bytes_sent, '-sumtraffic')

--记录各个状态的请求数
if tonumber(status) >= 500  then
    reqmonit.stat(ngx.shared.statics_dict, svrname_key, 1, '-5xx')
    --ngx.print(status)
elseif tonumber(status) == 499 then
    reqmonit.stat(ngx.shared.statics_dict, svrname_key, 1, '-499')
elseif tonumber(status) > 400 then
    reqmonit.stat(ngx.shared.statics_dict, svrname_key, 1, '-4xx')
elseif tonumber(status)  >300  then
    reqmonit.stat(ngx.shared.statics_dict, svrname_key, 1, '-3xx')
else 
    reqmonit.stat(ngx.shared.statics_dict, svrname_key, 1, '-2xx')
end
