local typedefs = require "kong.db.schema.typedefs"

return {
  name = "idempotency",
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
      type = "record",
      fields = {
        { redis_host = { type = "string" }, },
        { redis_port = { type = "number" }, },
        { redis_cache_time = { type = "number" }, },
        { is_required = { type = "boolean", default = false, }, },
      },
    }, },
  }
}
