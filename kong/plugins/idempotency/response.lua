local redis = require 'redis'
local json = require "cjson"
local kong = kong
local _M = {}

function _M.execute(conf, version, prefix, client)
  local method = kong.request.get_method()

  if not (method == 'POST') then
    return
  end

  local body = kong.service.response.get_raw_body()
  local status = kong.response.get_status()
  local idempotency_id = kong.request.get_header('x-idempotency-id')

  kong.response.set_header('x-idempotency-status', 'completed')
  client:set(string.format('%s%s-response', prefix, idempotency_id), json.encode({ status = status, body = body }), 'ex', conf.redis_cache_time)
end

return _M
