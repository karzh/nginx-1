package.path = "/home/s/apps/nginx/conf/?.lua"
local uri_args = ngx.req.get_uri_args()
svrname_key = uri_args["domain"]
if not svrname_key then
    ngx.print("host arg not found.")
    ngx.exit(ngx.HTTP_OK)
elseif svrname_key == 'getlist' then
    local keys = ngx.shared.domain:get_keys()
    for  idx,v in pairs(keys)  do
        ngx.say(v)
    end
else 

    local reqmonit = require("reqmonit")
    --local keys = ngx.shared.domain:get_keys(20)
    
    --for  idx,svrname_key in pairs(keys)  do
    local qps, avg_time, avg_traffic, req_5xx, req_4xx, req_499, req_3xx, req_2xx = reqmonit.analyse(ngx.shared.statics_dict, svrname_key)
    
    
    ngx.say("Server Name key:\t", svrname_key)
    ngx.say("Average Req Time Sec:\t", avg_time)
    ngx.say("Requests Per Secs:\t", qps)
    ngx.say("Requests traffic:\t", avg_traffic)
    ngx.say("5xx num:\t", req_5xx)
    ngx.say("4xx num:\t", req_4xx)
    ngx.say("3xx num:\t", req_3xx)
    ngx.say("2xx num:\t", req_2xx)
    ngx.say("499 num:\t", req_499)
end
