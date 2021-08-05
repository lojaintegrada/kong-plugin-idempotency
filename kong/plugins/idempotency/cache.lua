local redis = require 'redis'
local _M = {
  client = nil
}

function ping()
  return _M.client:ping()
end

function _M.connection(conf)
  if _M.client then
    local result = pcall(ping)

    if result then
      return _M.client
    end

    _M.client = nil
  end

  client = redis.connect(conf.redis_host, conf.redis_port)
  _M.client = client

  return _M.client
end

return _M
