local json = require "cjson"
local kong = kong
local _M = {}

function _M.execute(conf, version, prefix, client)
  local method = kong.request.get_method()

  if not (method == 'POST') then
    return
  end

  local idempotency_id = kong.request.get_header('x-idempotency-id')

  if not idempotency_id then
    kong.response.exit(400, { message = 'x-idempotency-id required' })
  end

  local inserted_cache = client:set(string.format('%s%s', prefix, idempotency_id), true, 'ex', conf.redis_cache_time, 'nx')

  if inserted_cache then
    kong.response.set_header('x-idempotency-status', 'waiting_response')
    return
  end

  local cache = client:get(string.format('%s%s-response', prefix, idempotency_id))

  if not cache then
    kong.response.set_header('x-idempotency-status', 'waiting_response')
    kong.response.exit(409, { message = 'x-idempotency-status waiting_response' })
    return
  end

  local response = json.decode(cache)

  kong.response.set_header('x-idempotency-status', 'completed')
  kong.response.exit(response.status, response.body)
end

return _M
