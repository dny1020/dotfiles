---
name: ccaas-architecture
description: >
  Expert-level CCaaS (Contact Center as a Service) architecture guidance covering WebRTC call flows, SIP signaling patterns, modular contact center design, Genesys Cloud-level feature parity on open-source infrastructure, agent/supervisor/admin/developer role separation, queue strategies, IVR design principles, presence management, outbound campaign architecture, recording pipelines, reporting data models, and multi-tenant design. Trigger this skill whenever the user asks about CCaaS design, contact center architecture, call flow design, queue strategy, presence management, SLA/metric modeling, campaign design, WebRTC topology, feature parity with commercial platforms (Genesys, Five9, Wolkvox, OmniLeads), or any high-level architectural decision about the contact center system.
---

# CCaaS Architecture — Modern Contact Center on Open Source

## North Star

Build a contact center platform that matches **Genesys Cloud** in UX and feature completeness, running on **Asterisk + Kamailio + PostgreSQL + Redis + FastAPI + React**. Every architectural decision is measured against: *would a Genesys customer feel this is a downgrade?*

---

## System Decomposition

```
┌─────────────────────────────────────────────────────────────────┐
│                        CONTROL PLANE                            │
│                                                                 │
│  FastAPI API ──► PostgreSQL (source of truth)                   │
│       │                  │                                      │
│       ▼                  ▼                                      │
│    Redis              pgBouncer ──► Asterisk Realtime (ODBC)   │
│  (cache/events)                                                 │
└───────────────────────────┬─────────────────────────────────────┘
                            │ AMI / ARI
┌───────────────────────────▼─────────────────────────────────────┐
│                        MEDIA PLANE                              │
│                                                                 │
│  Kamailio (SIP proxy/registrar)                                 │
│       │ UDP:5059                                                │
│  Asterisk (PBX, queues, recording, dialplan)                    │
│       │ ARI:8088                                                │
│  IVR Engine (Python, ARI, FSM)                                  │
└─────────────────────────────────────────────────────────────────┘
                            │ WSS:443
┌───────────────────────────▼─────────────────────────────────────┐
│                        CLIENT PLANE                             │
│                                                                 │
│  Nginx (TLS, static, proxy)                                     │
│  React (Agent | Supervisor | Admin | Developer)                 │
│  JsSIP (WebRTC softphone)                                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## The Four Interfaces — Feature Scope

### Agent Interface
The agent's entire workday lives here. Quality bar: Genesys Agent Desktop.

**Must have:**
- Softphone (answer, hangup, hold, transfer, DTMF, mute)
- Presence management (Available / Break / Busy / Offline) with reason codes
- Live call info (caller ID, queue origin, wait time before answer, duration)
- Call disposition + after-call work (ACW) timer with wrap-up codes
- Callback queue — missed calls queued for agent callback
- Campaign preview — click-to-call with contact data, attempt tracking
- Call history — personal CDR with recording playback
- Internal chat / notes per call
- Performance dashboard — own stats (calls handled, AHT, SLA contribution)

**Design principle:** Agent UI is high-frequency, low-latency. Every interaction maps to a real-time state change. No full-page reloads. All state via WebSocket push.

### Supervisor Interface
Command and control. Quality bar: Genesys Supervisor Desktop + WFM lite.

**Must have:**
- Live agent grid — all agents, presence, current call, duration, queue
- Live queue boards — calls waiting, longest wait, agents available, SLA%
- Real-time metrics — every counter updates via WS push (not polling)
- Spy / whisper / barge on active calls (via AMI ChanSpy)
- Remote agent state change — force break, force available
- Queue management — add/remove agents, change penalties live
- Historical reporting — SLA, AHT, abandonment, occupancy per queue/agent/period
- CDR search — filter by agent, queue, disposition, date range, DID

**Design principle:** Supervisor sees everything in their division only. Global admins see across divisions.

### Admin Interface
Configuration and provisioning. Quality bar: Genesys Admin UI.

**Must have:**
- Extension management (create/edit/delete PJSIP endpoints atomically)
- Queue management (strategy, timeout, MoH, SLA threshold, member management)
- DID routing (map DIDs to IVR/queue/extension with schedule support)
- Trunk management (SBC registration status, call limits)
- Recording management (search, playback, retention policy, download)
- User management (agents, roles, divisions, password reset)
- Blacklist management (per-division inbound blocking)
- API client management (client_id/secret for integrations)
- System settings CRUD (LDAP, S3, TTS, recording retention — no restart needed)
- Audit log viewer (every admin action, filterable)
- Division management (multi-tenant boundaries)

### Developer Interface
IVR and routing logic. Quality bar: Genesys Architect (flow designer).

**Must have:**
- Visual IVR flow builder (React Flow canvas)
- Node types: Start, Menu (DTMF), Play, Input (collect digits), Condition, Transfer (queue/extension), Voicemail, Hangup, Webhook, Set Variable
- Schedule management (business hours, holidays → IVR branching)
- Audio file management (upload, TTS preview, assign to nodes)
- DNIS routing table (DID → flow mapping)
- Flow versioning (draft vs active, rollback)
- Flow deployment (activate flow → DID routing updates)

---

## WebRTC Call Flow — End to End

### Inbound call (PSTN → Browser Agent)

```
1. PSTN call arrives at SBC
2. SBC sends INVITE to Kamailio (SIP trunk)
3. Kamailio routes to Asterisk (dispatcher)
4. Asterisk dialplan: from-did context → AGI did_router.py
5. did_router queries PostgreSQL: DID → IVR flow or queue
6. If IVR:  Stasis(cc) → IVR engine takes over via ARI
7. If queue: Queue(queue_name) → agent selection
8. Asterisk sends INVITE to Kamailio (ps_aors.contact = Kamailio:5059)
9. Kamailio resolves agent's WebSocket location from usrloc
10. INVITE forwarded to browser via WSS
11. JsSIP answers → WebRTC negotiation (ICE/DTLS/SRTP)
12. Media flows: Browser ←RTP/SRTP→ Asterisk (NOT through Kamailio)
13. AMI fires QueueCallerJoin + AgentConnect events
14. FastAPI AMI handler updates Redis + publishes to WS channel
15. Agent UI updates call state from WS event
```

### Outbound call (Agent click-to-call)

```
1. Agent clicks "Call" in UI → POST /api/calls/originate
2. FastAPI validates permission + rate limit
3. AMI Action: Originate (agent channel + destination)
4. Asterisk creates two channels: agent leg + customer leg
5. Dials agent first (PJSIP/{ext}) → agent's browser rings
6. Agent answers → Asterisk connects to destination
7. UserEvent(OutboundCall) fires in dialplan
8. AMI handler: INSERT into calls table with agent_extension
9. WS event pushed to agent UI: call active
```

### Transfer (blind)

```
1. Agent clicks Transfer → enters target extension
2. JsSIP: session.refer(`sip:{target}@{domain}`)
3. Kamailio receives REFER, proxies to Asterisk
4. Asterisk processes REFER → bridges to target
5. Agent leg releases
6. AMI event: AgentComplete on original channel
7. WS event: agent call state → idle
```

---

## Presence Architecture

Presence is the heartbeat of a contact center. Every agent state change must propagate to all supervisors in under 1 second.

### State machine

```
         ┌──────────────────────────────────┐
         │           OFFLINE                │
         └─────────────┬────────────────────┘
                       │ login
         ┌─────────────▼────────────────────┐
    ┌───▶│           AVAILABLE              │◀───┐
    │    └──────┬──────────────┬────────────┘    │
    │           │ call arrives │ manual break     │
    │    ┌──────▼──────┐  ┌───▼─────────────┐   │
    │    │   ON CALL   │  │     BREAK        │   │
    │    └──────┬──────┘  └───┬─────────────┘   │
    │           │ hangup      │ end break        │
    └───────────┘             └─────────────────┘
```

### Presence sources

| Trigger | Source | Target |
|---|---|---|
| Login/logout | JWT auth event | PostgreSQL + Redis + WS |
| Call connected | AMI `AgentConnect` | Redis (10s TTL) + WS publish |
| Call ended | AMI `AgentComplete` | Redis + WS publish |
| Manual break | API `POST /agents/me/state` | PostgreSQL + Redis + WS |
| Break timeout | Server-side timer (asyncio) | Auto-return to available |
| ACW (wrap-up) | Post-call timer | Redis + WS publish |

### Redis key per agent

```
cc:agent:{extension}:state → {state, reason, since, call_id}  TTL: 30s
```

Auto-expire is intentional — if the API node dies, agent states don't stay stale forever. Agents re-assert state on reconnect.

---

## Queue Architecture

### Queue strategies (Asterisk native)

| Strategy | When to use |
|---|---|
| `ringall` | Small teams, everyone hears every call |
| `leastrecent` | **Default for CCaaS** — routes to agent who answered least recently |
| `fewestcalls` | Load balance by raw call count |
| `rrmemory` | Round-robin with memory — fairest for equal-skill agents |
| `linear` | Priority queue — tries agents in order (overflow pattern) |
| `wrandom` | Weighted random — useful for penalty-based routing |

### Penalty-based skill routing

```sql
-- queue_members.penalty: 0 = primary, 1 = overflow, 2 = last resort
-- Asterisk tries penalty=0 agents first, escalates after timeout

-- Example: Billing queue
-- penalty 0: billing specialists
-- penalty 1: senior agents (cross-trained)
-- penalty 2: any available agent (never abandon)
INSERT INTO queue_members (queue_name, interface, penalty) VALUES
    ('billing', 'PJSIP/1001', 0),
    ('billing', 'PJSIP/1002', 0),
    ('billing', 'PJSIP/1005', 1),  -- cross-trained
    ('billing', 'PJSIP/1010', 2);  -- overflow
```

### SLA calculation

SLA = % of calls answered within threshold (e.g., 80% in 20 seconds). Calculate server-side:

```sql
SELECT
    queue_name,
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE wait_seconds <= 20 AND disposition = 'ANSWERED') AS within_sla,
    ROUND(
        COUNT(*) FILTER (WHERE wait_seconds <= 20 AND disposition = 'ANSWERED')::numeric
        / NULLIF(COUNT(*) FILTER (WHERE disposition IN ('ANSWERED','ABANDONED')), 0) * 100, 1
    ) AS sla_pct
FROM cdr
WHERE start_time >= NOW() - INTERVAL '1 day'
GROUP BY queue_name;
```

---

## IVR Design Principles

### Node types and their contracts

| Node | Inputs | Outputs | Errors |
|---|---|---|---|
| `start` | — | 1 exit | — |
| `play` | audio_key | 1 exit (on finish) | missing audio |
| `menu` | prompt, options[], timeout, max_attempts | N exits (by digit) + timeout + invalid | max attempts → hangup |
| `input` | prompt, min_digits, max_digits, timeout | 1 exit (digits in variable) | timeout, invalid |
| `condition` | variable, operator, value | true/false exits | — |
| `transfer` | type (queue/extension), target | 1 exit (if no answer) | unavailable |
| `webhook` | url, method, body_template | success/failure exits | timeout, HTTP error |
| `set_variable` | name, value | 1 exit | — |
| `voicemail` | mailbox | 1 exit | — |
| `hangup` | — | — | — |

### IVR flow validation rules

Before deploying a flow, validate:
- Every non-terminal node has at least one outgoing edge
- No unreachable nodes (all nodes reachable from start)
- No infinite loops without a hangup path
- All audio references exist in the audio library
- All transfer targets exist (queue or extension in DB)
- Webhook URLs are valid format (not validated live — just format)

### DTMF collection best practices

- **Single digit**: Wait max 5s, no confirmation, immediate branch
- **Multi-digit** (account number, extension): Confirm with read-back before action
- **Always announce timeout**: "I didn't receive your input. Please try again."
- **Max 3 attempts** before graceful hangup: "We're having trouble. Goodbye."
- **0 = escape hatch**: Always route `0` to agent (or announce if no agents available)

---

## Multi-Tenant Design

### Division = tenant boundary

```
┌─────────────────────────────────────────────┐
│                  Platform                    │
│  ┌──────────────┐    ┌──────────────────┐   │
│  │  Division A  │    │   Division B     │   │
│  │  agents      │    │   agents         │   │
│  │  queues      │    │   queues         │   │
│  │  DIDs        │    │   DIDs           │   │
│  │  recordings  │    │   recordings     │   │
│  └──────────────┘    └──────────────────┘   │
│                                              │
│  superadmin: sees all divisions              │
└─────────────────────────────────────────────┘
```

### Rules

- Every user belongs to exactly one division
- Every data query filters by division — no exceptions
- Superadmin can query across divisions (reporting, billing)
- Extensions are unique per division (not globally)
- Redis keys include division: `cc:queue:{division}:{name}:stats`
- WS pub/sub channels are per division: `cc:events:{division}`
- Audit log always records division

---

## Recording Pipeline

```
Asterisk MixMonitor (stereo WAV)
    │
    ▼ /var/spool/asterisk/monitor/{uniqueid}.wav
    │
FastAPI AMI event handler
    │
    ├─► INSERT into recordings table (path, duration, agent, queue, call_id)
    │
    └─► [optional] Background task: upload to S3/MinIO
             │
             ▼
         Update recordings.storage_url
         Delete local file after TTL
```

### Recording access control

- Agent: can only access own recordings
- Supervisor: can access all recordings in their division
- Admin: full access + bulk download
- Playback via Nginx X-Accel-Redirect — FastAPI validates permission, Nginx serves bytes
- Never expose recording file paths in API responses — use opaque recording IDs

### Retention

Configurable via `system_settings.recording_retention_days`. Background job runs nightly:

```sql
DELETE FROM recordings
WHERE created_at < NOW() - (
    SELECT (value::text)::int * INTERVAL '1 day'
    FROM system_settings WHERE key = 'recording_retention_days'
)
RETURNING storage_path;  -- delete local files for these paths
```

---

## Reporting Data Model

### The three reporting layers

```
Layer 1: Raw events (CDR table)
    — One row per call leg
    — Partitioned by month
    — Source of truth

Layer 2: Aggregated views (PostgreSQL views / materialized views)
    — current_queue_stats: live queue counters
    — agent_daily_summary: calls, AHT, SLA per agent per day
    — queue_hourly_trends: call volume by hour

Layer 3: API response models (FastAPI /stats/* endpoints)
    — Composed from Layer 2
    — Cached in Redis (10–60s TTL)
    — Served to Supervisor UI via polling (60s) or on-demand
```

### Key CCaaS metrics

| Metric | Formula | Good threshold |
|---|---|---|
| **SLA** | Answered in ≤N sec / (Answered + Abandoned) | ≥ 80% in 20s |
| **AHT** (Avg Handle Time) | AVG(talk_seconds + acw_seconds) | Queue-dependent |
| **Abandonment rate** | Abandoned / (Answered + Abandoned) | < 5% |
| **Occupancy** | Talk time / (Talk time + Idle time) | 75–85% |
| **FCR** (First Contact Resolution) | 1 - (callbacks within 24h) | > 80% |
| **CSAT** | Post-call survey score | > 4.0/5.0 |
| **ASA** (Avg Speed of Answer) | AVG(wait_seconds) for answered | < 30s |

---

## Outbound Campaign Architecture

### Campaign types

**Preview dialing**: Agent sees contact info, manually initiates call. Full control, lower volume.

```
1. Agent requests next contact: GET /api/campaigns/{id}/next
2. API: SELECT + UPDATE disposition='in_progress' WHERE disposition='pending' LIMIT 1
3. Returns contact data to agent
4. Agent reviews → clicks Call → AMI Originate
5. Disposition recorded (answered/no_answer/busy/callback)
```

**Progressive dialing**: System dials automatically when agent finishes ACW. Higher volume.

```
1. Agent completes ACW → state changes to available
2. API detects available agent + active campaign in their division
3. Checks contacts: SELECT next pending contact
4. AMI Originate: dial customer → if answered, bridge to agent
5. If no answer: update disposition, try next contact
```

### Attempt control

```sql
-- Never dial more than max_attempts times
-- Respect between-attempt delay
UPDATE contact_lists
SET disposition = 'failed'
WHERE attempts >= (
    SELECT (value->>'max_attempts')::int
    FROM campaigns WHERE id = campaign_id
);

-- Respect time-of-day rules (don't call at 3am)
-- Use schedule_id from campaigns → schedules table
```

---

## Security Model

### Authentication flow

```
POST /auth/login → JWT (access token, 60min) + refresh token (7 days)
All endpoints: Bearer {access_token}
Logout: jti added to Redis blacklist (TTL = remaining token lifetime)
Token refresh: POST /auth/refresh → new access token
```

### Permission matrix

| Action | Agent | Supervisor | Admin | Superadmin |
|---|---|---|---|---|
| Own calls/recordings | ✅ | ✅ | ✅ | ✅ |
| Division CDR | ❌ | ✅ | ✅ | ✅ |
| Spy/whisper/barge | ❌ | ✅ | ❌ | ✅ |
| Create extensions | ❌ | ❌ | ✅ | ✅ |
| Manage queues | ❌ | ❌ | ✅ | ✅ |
| system_settings | ❌ | ❌ | ✅ | ✅ |
| Cross-division data | ❌ | ❌ | ❌ | ✅ |
| API clients | ❌ | ❌ | ✅ | ✅ |

### API client credentials (integrations)

Separate from user accounts. `client_id` (plaintext, used as identifier) + `client_secret` (bcrypt hashed, never returned after creation). Used for webhook receivers, CRM integrations, wallboard apps.

---

## Webhook Architecture

Outbound webhooks for CRM/ticketing integration. Fired on call events.

```python
# Events: call.started, call.answered, call.ended, agent.state_changed
# Payload signed with HMAC-SHA256 using client's webhook_secret

import hmac, hashlib

def sign_payload(payload: str, secret: str) -> str:
    return hmac.new(secret.encode(), payload.encode(), hashlib.sha256).hexdigest()

# Header: X-CC-Signature: sha256={signature}
# Receiver validates: hmac.compare_digest(expected, received)
```

Delivery guarantees: at-least-once with retry (3 attempts, exponential backoff). Log all delivery attempts in `webhook_deliveries` table.

---

## Feature Parity Checklist vs Genesys Cloud

### Voice (Core)
- [x] Inbound ACD (skills-based via penalty)
- [x] Outbound (preview + progressive)
- [x] IVR with DTMF, TTS, conditional branching
- [x] Call recording (stereo MixMonitor)
- [x] Transfer (blind + attended)
- [x] Conference (via Asterisk bridge)
- [x] Voicemail with email notification
- [x] Queue callbacks (in-queue callback offer)
- [ ] Predictive dialing (future — requires AMD/answering machine detection)
- [ ] Post-call survey via IVR (future)

### Supervisor Tools
- [x] Live agent monitoring
- [x] Silent monitoring (ChanSpy)
- [x] Whisper coaching
- [x] Barge-in
- [x] Real-time queue dashboards
- [x] Historical reporting
- [ ] Screen recording (future — browser-based)
- [ ] Quality management scoring (future)

### Integrations
- [x] REST API for CRM integration
- [x] Outbound webhooks (HMAC signed)
- [x] LDAP authentication (via system_settings)
- [x] S3/MinIO for recording storage
- [ ] Native CRM connectors (Salesforce, HubSpot) — future
- [ ] Screen pop (via webhook + browser extension) — future

---

## Architecture Decision Records

### Why Kamailio as registrar, not Asterisk?
Asterisk's chan_pjsip WebSocket registration is fragile under load and requires TLS setup complexity. Kamailio is a purpose-built SIP proxy with robust WebSocket support, NAT handling, and anti-flood (pike). Separating registration from media processing also allows scaling each independently.

### Why psycopg2 sync + run_in_executor, not async SQLAlchemy?
The project uses Asterisk Realtime (ODBC via pgBouncer) which is inherently synchronous. Using the same psycopg2 pool for both API and ODBC-adjacent operations keeps the connection management consistent. Async SQLAlchemy adds complexity without benefit when pgBouncer transaction mode handles the concurrency.

### Why Redis pub/sub for WebSocket events instead of polling?
Contact center supervisors need sub-second latency for agent state changes. Polling at 1s intervals across 50 agents × 5 supervisors = 250 requests/second to the API. Redis pub/sub pushes events once per change, zero polling overhead.

### Why IVR as a separate container (webrtc-ivr)?
ARI maintains a persistent WebSocket connection to Asterisk. If the IVR engine crashes, it should not affect the API. Separate containers = separate crash domains, independent restarts, independent resource limits.

### Why JSONB for IVR flows?
IVR node graphs are schema-flexible — node types and their properties evolve as features are added. JSONB avoids migrations for every new node type while still enabling GIN index searches. The React Flow canvas maps directly to the JSON structure (nodes + edges arrays).
