local redis = require 'redis'
local kong = kong
local _M = {
  client = nil
}

function _M.connection(conf)
  if _M.client then
    return _M.client
  end

  _M.client = redis.connect(conf.redis_host, conf.redis_port)

  return _M.client
end

return _M
