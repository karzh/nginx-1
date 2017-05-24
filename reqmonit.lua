local reqmoit = {}
local function incr(dict, key, increment)
   increment = increment or 1
   local newval, err = dict:incr(key, increment)
   if err then
      dict:set(key, increment, 300)
      newval = increment
   end
   return newval
end

-- 记录访问时间 对访问值做累加
function reqmoit.stat(dict, key, value, surf)
   local start_time_key = table.concat({key,'start_time'})
   local host_key = table.concat({key,surf})


   local start_time = dict:get(start_time_key)
   if not start_time then
      dict:set(start_time_key, ngx.now(), 300)
   end

   local sum = incr(dict, host_key, value)
end

function reqmoit.operation(dict, key, count)
   local sum = dict:get(key) or 0
   local avg = 0
   if count > 0 then
      avg = sum / count
   end
   return avg
end
   
   

--status 记录返回码数量
--count  用于计算qps
--traffic 记录流量  时间

function reqmoit.analyse(dict, key)
   local sum_time = table.concat({key,'-sumtime'}) 
   local sum_traffic = table.concat({key,'-sumtraffic'}) 
   local count_key = table.concat({key,'-count'}) 
   local start_time_key = table.concat({key,'start_time'})
   local server_5xx_key = table.concat({key,'-5xx'}) 
   local server_4xx_key = table.concat({key,'-4xx'}) 
   local server_499_key = table.concat({key,'-499'}) 
   local server_3xx_key = table.concat({key,'-3xx'}) 
   local server_2xx_key = table.concat({key,'-2xx'}) 

   local elapsed_time = 1
   local avg_time = 0
   local avg_traffic = 0
   local req_5xx = 0
   local req_4xx = 0
   local req_499 = 0
   local req_3xx = 0
   local req_2xx = 0


   local start_time = dict:get(start_time_key)
   if start_time then
      elapsed_time = ngx.now() - start_time
   end
--count is access number  request avg time is  sum / count
   local count = dict:get(count_key) or 1
   local count_2xx = dict:get(server_2xx_key) or 1

   avg_time = reqmoit.operation(dict, sum_time, count_2xx)
   avg_traffic = reqmoit.operation(dict, sum_traffic, elapsed_time)
   req_5xx = reqmoit.operation(dict, server_5xx_key, elapsed_time)
   req_4xx = reqmoit.operation(dict, server_4xx_key, elapsed_time)
   req_499 = reqmoit.operation(dict, server_499_key, elapsed_time)
   req_3xx = reqmoit.operation(dict, server_3xx_key, elapsed_time)
   req_2xx = reqmoit.operation(dict, server_2xx_key, elapsed_time)
   qps = reqmoit.operation(dict, count_key, elapsed_time)

   dict:delete(sum_time)
   dict:delete(sum_traffic)
   dict:delete(count_key)
   dict:delete(start_time_key)
   dict:delete(server_5xx_key)
   dict:delete(server_4xx_key)
   dict:delete(server_3xx_key)
   dict:delete(server_2xx_key)
   dict:delete(server_499_key)

   return qps, avg_time, avg_traffic, req_5xx, req_4xx, req_499, req_3xx, req_2xx
end

return reqmoit
