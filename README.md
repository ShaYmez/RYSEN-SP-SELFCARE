# RYSEN Hotspot Proxy (Selfcare)

Docker image for the [RYSEN](https://github.com/ShaYmez/RYSEN) stack: hotspot UDP proxy with MariaDB-backed client selfcare.

**Image:** `shaymez/rysen-sp-selfcare:latest`

For a standalone proxy without MariaDB, use [RYSEN-SP](https://github.com/ShaYmez/RYSEN-SP) instead.

## Docker

Copy `sync/proxy-SAMPLE.cfg` to your host (e.g. `/etc/rysen/proxy.cfg`). Set `MASTER` and the `[SELF SERVICE]` database settings to match your stack.

```yaml
proxy:
    container_name: proxy
    image: shaymez/rysen-sp-selfcare:latest
    volumes:
        - '/etc/rysen/proxy.cfg:/opt/rysen-sp-selfcare/proxy.cfg'
    ports:
        - '62031:62031/udp'
    restart: unless-stopped
    depends_on:
        - rysen
        - mariadb
    read_only: true
```

## Configuration

| Key | Purpose |
|-----|---------|
| `MASTER` | Backend RYSEN master IP |
| `LISTENPORT` | Public UDP port (usually 62031) |
| `DESTPORTSTART` / `DESTPORTEND` | Backend slot port range |
| `[SELF SERVICE]` | MariaDB connection for client options |

See [hotspot proxy docs](https://github.com/ShaYmez/RYSEN/blob/master/doc/hotspot-proxy-v2.md) on RYSEN for more detail.
