---
name: postgresql-redis-expert
description: >
  Expert-level guidance on PostgreSQL, Redis, and pgBouncer for production systems. Trigger this skill whenever the user asks about database schema design, indexing, query optimization, connection pooling, pgBouncer configuration, Redis caching patterns, Redis Sentinel, data modeling, migrations, Patroni/HA setup, transactions, or any PostgreSQL/Redis infrastructure topic. Also trigger for async SQLAlchemy patterns, cache invalidation strategies, queue/extension schema design for ARA (Asterisk Realtime Architecture), or performance debugging.
---

# PostgreSQL + Redis + pgBouncer Expert

## Guiding Philosophy

- **Schema design is the most expensive thing to get wrong.** Fix it in migrations, not in the application.
- **Indexes are not free.** Every index costs write performance and storage. Add them with evidence, not hope.
- **Connection pooling is not optional at scale.** PostgreSQL's process-per-connection model will kill you. pgBouncer is mandatory.
- **Redis is a cache, a queue, and a pub/sub bus — not a database.** Treat data loss as expected behavior for anything in Redis only.

---

## PostgreSQL Schema Design

### General Rules

- Use `UUID` or `BIGSERIAL` for primary keys. UUIDs for cross-service IDs, BIGSERIAL for internal high-volume tables (CDR, events).
- Use `TIMESTAMPTZ` (not `TIMESTAMP`) always. Time zones exist. Pretending otherwise is a gift to your future self's worst day.
- Use `TEXT` over `VARCHAR(n)` unless the length constraint has business meaning.
- Use `ENUM` types for finite, stable sets. Avoid them for anything that will change in production (changing an ENUM requires `ALTER TYPE` which locks the table in older PG versions).
- Use `CHECK` constraints. The database is the last line of defense.
- Normalize aggressively, denormalize deliberately (with caching).

### Contact Center Schema Patterns

```sql
-- Extensions / PJSIP entities (ARA-compatible)
-- See asterisk-kamailio-expert skill for full ARA schema

-- Queue definitions
CREATE TABLE queues (
    name VARCHAR(40) PRIMARY KEY,
    musiconhold VARCHAR(40) DEFAULT 'default',
    announce VARCHAR(40),
    context VARCHAR(40) DEFAULT 'from-queue',
    timeout INTEGER DEFAULT 15,
    ringinuse VARCHAR(3) DEFAULT 'no',
    maxlen INTEGER DEFAULT 0,
    wrapuptime INTEGER DEFAULT 0,
    strategy VARCHAR(40) DEFAULT 'ringall',
    joinempty VARCHAR(40) DEFAULT 'no',
    leavewhenempty VARCHAR(40) DEFAULT 'no'
);

-- DID routing table
CREATE TABLE did_routing (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    did VARCHAR(20) NOT NULL UNIQUE,
    destination_type VARCHAR(20) NOT NULL CHECK (destination_type IN ('ivr', 'queue', 'extension', 'voicemail')),
    destination_id VARCHAR(40) NOT NULL,
    schedule_id UUID REFERENCES schedules(id),
    fallback_destination_id VARCHAR(40),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- IVR flow storage (JSON node graph)
CREATE TABLE ivr_flows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    version INTEGER NOT NULL DEFAULT 1,
    flow JSONB NOT NULL,               -- node graph
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- CDR (call detail records) — high volume, partition by month
CREATE TABLE cdr (
    id BIGSERIAL,
    call_id VARCHAR(64) NOT NULL,
    caller_id VARCHAR(40),
    destination VARCHAR(40),
    queue_name VARCHAR(40),
    agent_extension VARCHAR(20),
    start_time TIMESTAMPTZ NOT NULL,
    answer_time TIMESTAMPTZ,
    end_time TIMESTAMPTZ,
    duration INTEGER GENERATED ALWAYS AS (
        EXTRACT(EPOCH FROM (end_time - start_time))::INTEGER
    ) STORED,
    talk_time INTEGER GENERATED ALWAYS AS (
        EXTRACT(EPOCH FROM (end_time - answer_time))::INTEGER
    ) STORED,
    disposition VARCHAR(20) CHECK (disposition IN ('ANSWERED','NO ANSWER','BUSY','FAILED')),
    recording_path TEXT
) PARTITION BY RANGE (start_time);

-- Monthly CDR partitions (automate this)
CREATE TABLE cdr_2025_01 PARTITION OF cdr
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

### Indexing Rules

```sql
-- Index foreign keys (PostgreSQL doesn't do this automatically)
CREATE INDEX idx_did_routing_schedule ON did_routing(schedule_id);

-- Partial indexes — most underused feature in PostgreSQL
CREATE INDEX idx_active_ivr_flows ON ivr_flows(name) WHERE is_active = true;
CREATE INDEX idx_open_cdr ON cdr(call_id) WHERE end_time IS NULL;  -- live calls

-- Covering indexes for hot queries (avoid heap fetch entirely)
CREATE INDEX idx_cdr_agent_time ON cdr(agent_extension, start_time DESC)
    INCLUDE (duration, disposition);

-- GIN index for JSONB IVR flow search
CREATE INDEX idx_ivr_flow_gin ON ivr_flows USING GIN(flow);

-- Never index low-cardinality columns (disposition has 4 values — useless alone)
-- Never add indexes "just in case" — use EXPLAIN ANALYZE first
```

### Query Optimization

```sql
-- Always EXPLAIN ANALYZE before shipping a query, never EXPLAIN alone
EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON)
SELECT agent_extension, COUNT(*), AVG(duration)
FROM cdr
WHERE start_time >= NOW() - INTERVAL '7 days'
  AND disposition = 'ANSWERED'
GROUP BY agent_extension;

-- Seq Scan on a large table = missing index or bad query
-- Bitmap Heap Scan = fine for moderate selectivity
-- Index Scan = ideal for high selectivity (< ~5% of rows)
-- Hash Join > Nested Loop for large joins (check join strategy)
```

### Transactions and Isolation

```python
# Use SERIALIZABLE only when truly needed (e.g., seat/resource allocation)
# Default READ COMMITTED is correct for most CRUD operations

# Atomic PJSIP provisioning — never partial state
async with db.begin():
    await db.execute(insert(PsEndpoint).values(...))
    await db.execute(insert(PsAuth).values(...))
    await db.execute(insert(PsAor).values(...))
# If any fails, all roll back. Asterisk never sees partial config.

# Optimistic locking for concurrent edits (IVR flow designer)
async def update_ivr_flow(db, flow_id, expected_version, new_flow):
    result = await db.execute(
        update(IvrFlow)
        .where(IvrFlow.id == flow_id, IvrFlow.version == expected_version)
        .values(flow=new_flow, version=expected_version + 1)
        .returning(IvrFlow.id)
    )
    if not result.fetchone():
        raise ConflictError("Flow was modified by another user — reload and retry")
```

### Migrations (Alembic)

```python
# Never use autogenerate blindly — always review generated migrations
# alembic revision --autogenerate -m "add_did_routing_table"

# For large tables, avoid full-table locks:
# ✅ Add column with DEFAULT (PG 11+ evaluates lazily — no rewrite)
# ✅ CREATE INDEX CONCURRENTLY (no lock)
# ❌ ALTER COLUMN TYPE on a large table (full rewrite)
# ❌ ADD NOT NULL without a DEFAULT (scans entire table)

# Safe nullable → not-null migration
op.add_column('cdr', sa.Column('call_id', sa.String(64), nullable=True))
op.execute("UPDATE cdr SET call_id = gen_random_uuid()::text WHERE call_id IS NULL")
op.alter_column('cdr', 'call_id', nullable=False)
```

---

## pgBouncer

### Why It Exists

PostgreSQL spawns a process per connection. At 200 concurrent connections, you're paying 200× process overhead. pgBouncer sits in front and multiplexes many app connections onto a small pool of actual PostgreSQL connections.

### Pool Modes (choose carefully)

| Mode | How it works | Use when |
|---|---|---|
| `session` | Connection held for entire client session | Using session-level features (temp tables, advisory locks, `SET` vars) |
| `transaction` | Connection returned after each transaction | **Default choice for async apps with SQLAlchemy** |
| `statement` | Connection returned after each statement | Rarely — breaks multi-statement transactions |

**For FastAPI + SQLAlchemy async: use `transaction` mode.**

```ini
; pgbouncer.ini
[databases]
asterisk = host=127.0.0.1 port=5432 dbname=asterisk

[pgbouncer]
listen_addr = 127.0.0.1
listen_port = 6432
auth_type = scram-sha-256
auth_file = /etc/pgbouncer/userlist.txt

pool_mode = transaction
max_client_conn = 1000
default_pool_size = 20          ; actual PG connections per database/user pair
reserve_pool_size = 5
reserve_pool_timeout = 3
server_lifetime = 3600
server_idle_timeout = 600

; Important for SQLAlchemy health checks
server_check_query = SELECT 1
```

### pgBouncer + SQLAlchemy Gotchas

```python
# transaction pool mode breaks these — NEVER USE:
# - LISTEN/NOTIFY (use Redis pub/sub instead)
# - Advisory locks (session-scoped)
# - Temporary tables
# - Prepared statements (disable in SQLAlchemy)

engine = create_async_engine(
    dsn,
    # Disable prepared statements — incompatible with pgBouncer transaction mode
    connect_args={"prepared_statement_cache_size": 0},
    pool_pre_ping=True,
    # SQLAlchemy's own pool ON TOP of pgBouncer — keep small
    pool_size=5,
    max_overflow=10,
)
```

### Patroni (HA)

```yaml
# patroni.yml essentials
scope: asterisk-cluster
name: pg-node-1

restapi:
  listen: 0.0.0.0:8008
  connect_address: pg-node-1:8008

etcd3:
  hosts: etcd1:2379,etcd2:2379,etcd3:2379

bootstrap:
  dcs:
    ttl: 30
    loop_wait: 10
    retry_timeout: 30
    maximum_lag_on_failover: 1048576   # 1MB lag max before refusing promotion

postgresql:
  listen: 0.0.0.0:5432
  connect_address: pg-node-1:5432
  data_dir: /var/lib/postgresql/14/main
  parameters:
    wal_level: replica
    max_wal_senders: 10
    max_replication_slots: 10
    hot_standby: "on"
```

Point pgBouncer at HAProxy, which monitors Patroni REST API to route writes to primary:

```
# haproxy.cfg
backend pgsql_primary
    option httpchk GET /primary
    server pg1 pg-node-1:5432 check port 8008
    server pg2 pg-node-2:5432 check port 8008

backend pgsql_replica
    option httpchk GET /replica
    server pg1 pg-node-1:5432 check port 8008
    server pg2 pg-node-2:5432 check port 8008
```

---

## Redis

### Data Structure Selection

| Use case | Structure | TTL? |
|---|---|---|
| Session / JWT token cache | `STRING` (serialized JSON) | Yes — match JWT expiry |
| Extension/queue config cache | `STRING` or `HASH` | Yes — 60–300s |
| Active call state | `HASH` (key=call_id) | Yes — failsafe TTL |
| Pub/sub for ARI events → frontend | `PUBLISH/SUBSCRIBE` | N/A |
| Rate limiting | `INCR` + `EXPIRE` | Yes |
| Distributed lock (AMI reload) | `SET NX PX` | Yes — short (5–10s) |
| Queue metrics (live counters) | `INCR` / `HINCRBY` | No (reset on shift) |

### Key Naming Convention

```
{service}:{entity}:{id}:{field}

# Examples:
cc:extension:1001:config          # cached PJSIP endpoint config
cc:session:{token_hash}           # JWT session
cc:call:{call_id}:state           # active call
cc:lock:pjsip_reload              # distributed lock
cc:queue:support:metrics          # live queue counters
```

### Caching Patterns

```python
# Read-through cache with stale-while-revalidate
async def get_extension(redis: Redis, db: AsyncSession, ext_id: str) -> dict:
    key = f"cc:extension:{ext_id}:config"
    cached = await redis.get(key)
    if cached:
        return json.loads(cached)
    
    ext = await extension_repo.get(db, ext_id)
    if not ext:
        raise NotFoundError("Extension", ext_id)
    
    data = ext.model_dump()
    await redis.setex(key, 300, json.dumps(data))  # 5 min TTL
    return data

# Cache invalidation on write — always explicit, never rely on TTL alone
async def update_extension(redis: Redis, db: AsyncSession, ext_id: str, payload: dict):
    updated = await extension_repo.update(db, ext_id, payload)
    await redis.delete(f"cc:extension:{ext_id}:config")  # invalidate
    return updated
```

### Distributed Locking (for AMI reload coordination)

```python
async def with_pjsip_reload_lock(redis: Redis, ami: AmiClient):
    """Ensure only one PJSIP reload runs at a time across API nodes."""
    lock_key = "cc:lock:pjsip_reload"
    acquired = await redis.set(lock_key, "1", nx=True, px=5000)  # 5s TTL
    if not acquired:
        raise ConflictError("PJSIP reload already in progress")
    try:
        await ami.pjsip_reload()
    finally:
        await redis.delete(lock_key)
```

### Pub/Sub for Real-time Events

```python
# Publisher — FastAPI receives ARI event, publishes to Redis
async def publish_call_event(redis: Redis, event: dict):
    await redis.publish("cc:events:calls", json.dumps(event))

# Subscriber — could be a WebSocket handler pushing to frontend
async def subscribe_call_events(redis: Redis, websocket: WebSocket):
    pubsub = redis.pubsub()
    await pubsub.subscribe("cc:events:calls")
    async for message in pubsub.listen():
        if message["type"] == "message":
            await websocket.send_text(message["data"])
```

### Redis Sentinel (HA)

```python
# aioredis with Sentinel
from redis.asyncio.sentinel import Sentinel

sentinel = Sentinel(
    [("sentinel1", 26379), ("sentinel2", 26379), ("sentinel3", 26379)],
    socket_timeout=0.5,
)
redis_master = sentinel.master_for("cc-redis", password=settings.redis_password)
redis_replica = sentinel.slave_for("cc-redis", password=settings.redis_password)

# Use master for writes, replica for reads (cache reads)
await redis_master.set(key, value)
await redis_replica.get(key)
```

---

## Performance Debugging

### PostgreSQL

```sql
-- Find slow queries
SELECT query, mean_exec_time, calls, total_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 20;

-- Find missing indexes (sequential scans on large tables)
SELECT relname, seq_scan, idx_scan, n_live_tup
FROM pg_stat_user_tables
WHERE seq_scan > idx_scan AND n_live_tup > 10000
ORDER BY seq_scan DESC;

-- Connection pool saturation
SELECT count(*), state, wait_event_type, wait_event
FROM pg_stat_activity
GROUP BY state, wait_event_type, wait_event;

-- Table bloat (vacuum running?)
SELECT relname, n_dead_tup, last_autovacuum, last_autoanalyze
FROM pg_stat_user_tables
ORDER BY n_dead_tup DESC;
```

### Redis

```bash
# Real-time command monitoring (careful — logs everything)
redis-cli MONITOR

# Memory usage by key pattern
redis-cli --scan --pattern 'cc:extension:*' | xargs redis-cli MEMORY USAGE

# Slowlog
redis-cli SLOWLOG GET 25

# Info overview
redis-cli INFO stats | grep -E "connected_clients|used_memory_human|keyspace_hits|keyspace_misses"
```

---

## Production Checklist

### PostgreSQL
- [ ] `pg_stat_statements` extension enabled
- [ ] `autovacuum` tuned for high-write tables (CDR)
- [ ] WAL archiving configured for PITR
- [ ] `max_connections` set conservatively (pgBouncer handles the rest)
- [ ] Patroni + etcd for automatic failover
- [ ] Read replica for reporting queries (CDR analytics)
- [ ] CDR table partitioned by month with automated partition creation

### pgBouncer
- [ ] `transaction` pool mode
- [ ] `prepared_statement_cache_size=0` in SQLAlchemy
- [ ] `server_check_query` configured
- [ ] Pointing to HAProxy (not directly to PG primary)
- [ ] `max_client_conn` set based on expected concurrent API connections

### Redis
- [ ] Redis Sentinel (3 nodes minimum) or Redis Cluster
- [ ] `maxmemory-policy allkeys-lru` (cache behavior)
- [ ] `requirepass` enforced
- [ ] `bind` restricted to internal interface
- [ ] Replica used for read-heavy cache lookups
- [ ] Key TTLs set on all application-managed keys — no immortal cache entries
