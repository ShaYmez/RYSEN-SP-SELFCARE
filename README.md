# RYSEN Hotspot Proxy V2 (Selfcare)

Motorola Homebrew hotspot UDP proxy with MariaDB selfcare for the [RYSEN](https://github.com/ShaYmez/RYSEN) stack — public hotspot port to many backend master slots, with client options from the `Clients` table.

Published as **`shaymez/rysen-sp-selfcare:latest`**, modelled on [RYSEN-SP-IPSC](https://github.com/ShaYmez/RYSEN-SP-IPSC). Keeps a **separate slim Docker image** so deployments do not need the full RYSEN image for the hotspot proxy service.

## Develop in RYSEN; publish here

**Source of truth:** [ShaYmez/RYSEN](https://github.com/ShaYmez/RYSEN) (`ipsc` branch during IPSC milestone work; `master` after merge). Edit proxy logic, DB layer, sample config, and tests **only in RYSEN**.

This repo **syncs** those files into [`sync/`](sync/) and [`tests/`](tests/), then builds and pushes the Docker image. Do not hand-edit synced copies — they are overwritten by [`.github/workflows/sync-from-rysen.yml`](.github/workflows/sync-from-rysen.yml).

| Synced from RYSEN | Local path |
|-------------------|------------|
| `hotspot_proxy_v2_sc.py` | `sync/hotspot_proxy_v2.py` |
| `proxy_db.py` | `sync/proxy_db.py` |
| `hotspot_proxy_v2_sc-SAMPLE.cfg` | `sync/proxy-SAMPLE.cfg` |
| `tests/test_hotspot_proxy.py` | `tests/test_hotspot_proxy.py` |

Refresh: **Actions → Sync from RYSEN** (manual), push to proxy files on RYSEN (`ipsc` or `master`), `repository_dispatch`, or daily scheduled sync. A sync commit triggers **Build-RYSEN-SP-SELFCARE** (tests, then image push).

### Wiring RYSEN → this repo

```
RYSEN push (ipsc or master, hotspot proxy paths)
    → RYSEN: Sync satellite proxy repos
    → repository_dispatch → RYSEN-SP-SELFCARE: Sync from RYSEN
    → commit sync/ if changed → Build-RYSEN-SP-SELFCARE → Docker Hub
```

1. **PAT in RYSEN** — same **`SATELLITE_DISPATCH_TOKEN`** used for RYSEN-SP-IPSC (one PAT triggers both satellite repos).

2. **RYSEN workflow** — [`.github/workflows/sync-satellite-repos.yml`](https://github.com/ShaYmez/RYSEN/blob/ipsc/.github/workflows/sync-satellite-repos.yml) dispatches `rysen-selfcare-updated` with `client_payload.ref` = the branch you pushed.

3. **Scheduled / manual fallback ref** — set Actions variable **`RYSEN_SYNC_REF`** on this repo to `ipsc` now; change to `master` after RYSEN merge. Push-triggered sync always uses the branch that was pushed.

4. **Docker Hub** — repository secrets **`DOCKER_USERNAME`** and **`DOCKER_PASSWORD`**.

After `ipsc` → `master` merge: update **`RYSEN_SYNC_REF`** to `master` on this repo and on RYSEN-SP-IPSC.

## Quick start (Docker)

1. Copy `sync/proxy-SAMPLE.cfg` to your host config path (e.g. `/etc/rysen/proxy.cfg`).
2. Set `MASTER` to the RYSEN container IP on your compose network.
3. Configure MariaDB connection settings to match your RYSEN stack.

```yaml
hotspot-proxy:
    container_name: hotspot-proxy
    image: shaymez/rysen-sp-selfcare:latest
    volumes:
        - '/etc/rysen/proxy.cfg:/opt/rysen-sp-selfcare/proxy.cfg'
    ports:
        - '62031:62031/udp'
    restart: unless-stopped
    depends_on:
        - rysen
        - mariadb
    networks:
        app_net:
          ipv4_address: 172.16.238.20
    read_only: true
```

See RYSEN `docker-configs/docker-compose.yml` for the full compose profile (`--profile hotspot`).

## Quick start (bare metal)

```bash
pip install -r requirements.txt
cp sync/proxy-SAMPLE.cfg proxy.cfg
# edit proxy.cfg
PYTHONPATH=sync python sync/hotspot_proxy_v2.py -c proxy.cfg
```

## Tests

```bash
pip install -r requirements.txt
PYTHONPATH=sync python -m unittest discover -s tests -v
```

## Build image locally

```bash
docker build -t shaymez/rysen-sp-selfcare:latest .
```

## Related

- RYSEN hotspot docs: [hotspot-proxy-v2.md](https://github.com/ShaYmez/RYSEN/blob/master/doc/hotspot-proxy-v2.md)
- Satellite sync model: [satellite-proxy-repos.md](https://github.com/ShaYmez/RYSEN/blob/ipsc/doc/satellite-proxy-repos.md)
- RYSEN master: [ShaYmez/RYSEN](https://github.com/ShaYmez/RYSEN)
