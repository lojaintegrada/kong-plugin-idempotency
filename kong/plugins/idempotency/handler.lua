local json = require "cjson"
local redis = require 'redis'
local prefix = 'kong-idempotency-plugin:'
local kong = kong

local Idempotency = {
  VERSION = "0.1.0"
}

function Idempotency:access(conf)
  local method = kong.request.get_method()

  if not (method == 'POST') then
    return
  end

  local client = redis.connect(conf.redis_host, conf.redis_port)
  local idempotency_id = kong.request.get_header('x-idempotency-id')

  if not idempotency_id then
    kong.response.set_header('x-idempotency-status', 'processing')
    kong.response.exit(400, { message = 'x-idempotency-id required' })
  end

  local inserted_cache = client:set(string.format('%s%s', prefix, idempotency_id), true, 'ex', conf.redis_cache_time, 'nx')

  if inserted_cache then
    kong.response.set_header('x-idempotency-status', 'processing')
    return
  end

  local cache = client:get(string.format('%s%s-result', prefix, idempotency_id))


  if not cache then
    kong.response.set_header('x-idempotency-status', 'processing')
    kong.response.exit(400, { message = 'x-idempotency-status processing' })
    return
  end

  local response = json.decode(cache)

  kong.response.set_header('x-idempotency-status', 'completed')
  kong.response.exit(response.status, response.body)
end

function Idempotency:response(conf)
  local client = redis.connect(conf.redis_host, conf.redis_port)
  local body = kong.service.response.get_raw_body()
  local status = kong.response.get_status()
  local idempotency_id = kong.request.get_header('x-idempotency-id')

  kong.response.set_header('x-idempotency-status', 'completed')
  client:set(string.format('%s%s-result', prefix, idempotency_id), json.encode({ status = status, body = body }), 'ex', conf.redis_cache_time, 'nx')
end

return Idempotency
