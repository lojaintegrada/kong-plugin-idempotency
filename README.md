# Idempotency

A Kong plugin that enables idempotency to HTTP POST.

## Description

This plugin set a `nx` key on redis database for each `x-idempotency-id` came from the client, when the same `x-idempotency-id` came in other request throws error because the keys is already set on redis.

## Installation

```bash
$ luarocks install kong-plugin-idempotency
```

Update the `plugins` config to add `idempotency`:

```
plugins = bundled,idempotency
```

## Use cases [WIP]

### Host offloading [WIP]

## Configuration [WIP]

```bash
$ curl -X POST http://kong:8001/apis/{api}/plugins \
    --data "name=the-idempotency" \
    --data "config.url=http://myservice"
```

| Parameter | default | description |
| ---       | ---     | ---         |
| `config.redis_host` | [required] | Host of redis server. |
| `config.redis_port` | [required] | Port of redis server. |
| `config.redis_cache_time` | [required] | Caches expiration time in seconds. |
