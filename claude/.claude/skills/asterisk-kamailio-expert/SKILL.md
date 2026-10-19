---
name: asterisk-kamailio-expert
description: >
  Expert-level guidance on Asterisk PBX, Kamailio SIP proxy, WebRTC/WSS integration, PJSIP, ARA (Asterisk Realtime Architecture), ARI (Asterisk REST Interface), AMI (Asterisk Manager Interface), dialplan, SIP call flows, IVR design, and contact center telephony infrastructure. Trigger this skill whenever the user asks about SIP configuration, Asterisk setup, Kamailio routing, WebRTC softphone connectivity, WSS transport, PJSIP endpoints, ARA table schemas, realtime config, IVR flows, call queues, voicemail, media handling, RTP, SRTP, DTLS, ICE, or any VoIP/telephony topic. Also trigger for debugging call flow issues, SIP traces, Asterisk CLI analysis, or Kamailio config review.
---

# Asterisk + Kamailio Expert

## Stack Context

This skill is tuned for a **contact center** deployment with:

- **Kamailio** as WSS/SIP proxy (WebRTC clients + SIP trunks)
- **Asterisk** as PBX/media server (PJSIP, ARI, AMI)
- **ARA** (Asterisk Realtime Architecture) — all PJSIP entities, queues, voicemail, MoH, DID routing stored in PostgreSQL
- **FastAPI** middleware integrating AMI + ARI
- **React WebRTC softphone** connecting via WSS → Kamailio → Asterisk

---

## Kamailio

### Core Responsibilities

- Terminate WSS (TLS + WebSocket upgrade) from browser clients
- Route SIP trunks inbound to Asterisk
- Handle NAT traversal for SIP UA clients
- Active-active HA via DMQ module
- Load-balance to multiple Asterisk nodes via `dispatcher`

### WSS Configuration (kamailio.cfg essentials)

```
#!define WITH_TLS
#!define WITH_WEBSOCKETS

loadmodule "tls.so"
loadmodule "websocket.so"
loadmodule "nathelper.so"
loadmodule "rtpengine.so"  # or rtpproxy.so

modparam("tls", "config", "/etc/kamailio/tls.cfg")

# TLS config (tls.cfg)
[server:default]
method = TLSv1.2+
verify_certificate = no  # for internal/self-signed; yes for prod with proper certs
require_certificate = no
certificate = /etc/kamailio/certs/server.pem
private_key = /etc/kamailio/certs/server.key
```

### WebSocket Routing Block

```
request_route {
    if (is_method("OPTIONS")) {
        sl_send_reply("200", "OK");
        exit;
    }

    if (nat_uac_test("19")) {
        force_rport();
        fix_nated_contact();
    }

    if (is_WS() || is_WSS()) {
        route(WEBSOCKET_ROUTE);
    } else {
        route(SIP_ROUTE);
    }
}

route[WEBSOCKET_ROUTE] {
    if (is_method("REGISTER")) {
        route(REGISTRAR);
        exit;
    }
    # Forward INVITE to Asterisk via TCP/TLS
    $du = "sip:asterisk-internal:5060;transport=tcp";
    forward();
}
```

### NAT Handling (critical for WebRTC)

```
# Always needed for browser clients behind NAT
modparam("nathelper", "received_avp", "$avp(RECEIVED)")
modparam("nathelper", "natping_interval", 30)

# In request_route
if (has_body("application/sdp")) {
    rtpengine_manage("replace-origin replace-session-connection ICE=force direction=pub direction=sub");
}
```

### Dispatcher (load balance to Asterisk nodes)

```
modparam("dispatcher", "db_url", "DBURL")
modparam("dispatcher", "ds_ping_method", "OPTIONS")
modparam("dispatcher", "ds_ping_interval", 10)
modparam("dispatcher", "ds_probing_threshold", 2)
modparam("dispatcher", "ds_inactive_threshold", 3)

# dispatcher_groups table:
# setid=1 → Asterisk node 1 (sip:ast1:5060;transport=tcp)
# setid=1 → Asterisk node 2 (sip:ast2:5060;transport=tcp)

route[TO_ASTERISK] {
    if (!dispatcher_select(1, 4, 0)) {  # algo 4 = round-robin
        send_reply("503", "No Asterisk available");
        exit;
    }
    t_relay();
}
```

### DMQ (active-active HA)

```
loadmodule "dmq.so"
modparam("dmq", "server_address", "sip:kamailio1:5090")
modparam("dmq", "notification_address", "sip:kamailio2:5090")
modparam("dmq", "multi_notify", 1)

# Replicate usrloc, dialog, htable across nodes
modparam("dmq_usrloc", "enable", 1)
```

---

## Asterisk — PJSIP

### Channel Driver Choice

**Use PJSIP, not chan_sip.** chan_sip is deprecated and does not support WebRTC properly. Period.

### Key pjsip.conf static settings (minimum for ARA)

```ini
; pjsip.conf — only global and transport, rest is in DB via ARA
[global]
type=global
endpoint_identifier_order=ip,username,anonymous

[transport-tcp]
type=transport
protocol=tcp
bind=0.0.0.0:5060

[transport-tls]
type=transport
protocol=tls
bind=0.0.0.0:5061
cert_file=/etc/asterisk/keys/asterisk.pem
priv_key_file=/etc/asterisk/keys/asterisk.key
method=tlsv1_2
```

### ARA PJSIP Table Schema

The following tables must exist for full PJSIP realtime:

```sql
-- ps_endpoints
CREATE TABLE ps_endpoints (
    id VARCHAR(40) PRIMARY KEY,           -- extension number e.g. "1001"
    transport VARCHAR(40),                 -- "transport-tcp"
    aors VARCHAR(200),                     -- same as id
    auth VARCHAR(200),                     -- same as id
    context VARCHAR(40) DEFAULT 'from-internal',
    disallow VARCHAR(200) DEFAULT 'all',
    allow VARCHAR(200) DEFAULT 'ulaw,alaw,opus',
    webrtc VARCHAR(3) DEFAULT 'no',       -- 'yes' for browser clients
    dtls_verify VARCHAR(40) DEFAULT 'no',
    dtls_setup VARCHAR(40) DEFAULT 'actpass',
    ice_support VARCHAR(3) DEFAULT 'no',  -- 'yes' for WebRTC
    use_avpf VARCHAR(3) DEFAULT 'no',     -- 'yes' for WebRTC
    media_encryption VARCHAR(40) DEFAULT 'no', -- 'dtls' for WebRTC
    rtp_symmetric VARCHAR(3) DEFAULT 'yes',
    force_rport VARCHAR(3) DEFAULT 'yes',
    rewrite_contact VARCHAR(3) DEFAULT 'yes',
    callerid VARCHAR(40),
    mailboxes VARCHAR(200),
    outbound_auth VARCHAR(40),
    direct_media VARCHAR(3) DEFAULT 'no'
);

-- ps_auths
CREATE TABLE ps_auths (
    id VARCHAR(40) PRIMARY KEY,
    auth_type VARCHAR(40) DEFAULT 'userpass',
    password VARCHAR(80),
    username VARCHAR(40)
);

-- ps_aors
CREATE TABLE ps_aors (
    id VARCHAR(40) PRIMARY KEY,
    max_contacts INTEGER DEFAULT 1,
    remove_existing VARCHAR(3) DEFAULT 'yes',
    qualify_frequency INTEGER DEFAULT 60
);

-- ps_registrations (for outbound SIP trunk registration)
CREATE TABLE ps_registrations (
    id VARCHAR(40) PRIMARY KEY,
    transport VARCHAR(40),
    outbound_auth VARCHAR(40),
    server_uri VARCHAR(256),
    client_uri VARCHAR(256),
    retry_interval INTEGER DEFAULT 60,
    expiration INTEGER DEFAULT 3600
);
```

### extconfig.conf (ARA mapping)

```ini
[settings]
ps_endpoints => pgsql,asterisk,ps_endpoints
ps_auths => pgsql,asterisk,ps_auths
ps_aors => pgsql,asterisk,ps_aors
ps_registrations => pgsql,asterisk,ps_registrations
ps_domain_aliases => pgsql,asterisk,ps_domain_aliases
queues => pgsql,asterisk,queues
queue_members => pgsql,asterisk,queue_members
voicemail => pgsql,asterisk,voicemail
extensions => pgsql,asterisk,extensions  ; for realtime dialplan
```

### WebRTC Endpoint Creation (atomic)

When provisioning a WebRTC extension via API, always write all three rows in a single transaction:

```python
async def provision_webrtc_extension(db: AsyncSession, ext: str, password: str):
    async with db.begin():
        db.add(PsEndpoint(
            id=ext, transport="transport-tcp", aors=ext, auth=ext,
            context="from-internal", disallow="all", allow="ulaw,opus",
            webrtc="yes", dtls_verify="no", dtls_setup="actpass",
            ice_support="yes", use_avpf="yes", media_encryption="dtls",
            rtp_symmetric="yes", force_rport="yes", rewrite_contact="yes",
        ))
        db.add(PsAuth(id=ext, auth_type="userpass", username=ext, password=password))
        db.add(PsAor(id=ext, max_contacts=1, remove_existing="yes", qualify_frequency=60))
    # Then reload PJSIP via AMI — outside transaction
    await ami.send_action({"Action": "PJSIPShowEndpoints"})
    await ami.send_action({"Action": "UpdateConfig", "SrcFilename": "pjsip", "DstFilename": "pjsip", "Reload": "yes"})
```

---

## ARI (Asterisk REST Interface)

### Use ARI for

- IVR flow execution (play, gather DTMF, bridge)
- Real-time call control (hold, transfer, conference)
- Custom call recording logic
- Originating calls programmatically

### ARI Architecture Pattern

```
FastAPI ──HTTP──▶ ARI REST (port 8088)
                       │
FastAPI ◀──WS Events── ARI WebSocket (/ari/events?app=cc)
```

### Core ARI Operations

```python
class AriClient:
    def __init__(self, base_url: str, user: str, secret: str):
        self.base = base_url
        self.auth = aiohttp.BasicAuth(user, secret)
        self.session: aiohttp.ClientSession = None

    async def answer(self, channel_id: str):
        await self.post(f"/channels/{channel_id}/answer")

    async def play(self, channel_id: str, media: str) -> str:
        """Returns playback ID for control/cancellation."""
        r = await self.post(f"/channels/{channel_id}/play",
                           json={"media": f"sound:{media}"})
        return r["id"]

    async def get_variable(self, channel_id: str, var: str) -> str:
        r = await self.get(f"/channels/{channel_id}/variable", params={"variable": var})
        return r["value"]

    async def bridge_add(self, bridge_id: str, channel_id: str):
        await self.post(f"/bridges/{bridge_id}/addChannel",
                       json={"channel": channel_id})
```

### IVR FSM via ARI

Model IVR as an explicit state machine. Don't implement it as tangled event callbacks.

```python
@dataclass
class IvrContext:
    channel_id: str
    state: str  # "greeting" | "menu" | "routing" | "agent_wait"
    digit_buffer: str = ""
    attempt: int = 0

async def handle_dtmf(ctx: IvrContext, digit: str, ari: AriClient):
    if ctx.state == "menu":
        ctx.digit_buffer += digit
        if len(ctx.digit_buffer) >= 1:
            await transition(ctx, ari, ctx.digit_buffer)

async def transition(ctx: IvrContext, ari: AriClient, selection: str):
    match selection:
        case "1":
            ctx.state = "agent_wait"
            await ari.post(f"/channels/{ctx.channel_id}/continue",
                          json={"context": "from-ivr", "extension": "sales_queue"})
        case "2":
            ctx.state = "agent_wait"
            await ari.post(f"/channels/{ctx.channel_id}/continue",
                          json={"context": "from-ivr", "extension": "support_queue"})
        case _:
            ctx.attempt += 1
            if ctx.attempt >= 3:
                await ari.play(ctx.channel_id, "vm-goodbye")
                await ari.post(f"/channels/{ctx.channel_id}/hangup")
            else:
                await ari.play(ctx.channel_id, "invalid")
```

---

## AMI (Asterisk Manager Interface)

### Use AMI for

- Triggering module reloads after ARA changes
- Monitoring channel/queue events (as supplement to ARI)
- Originating calls (simpler than ARI for basic cases)
- Getting queue member status

### AMI Action patterns

```
Action: PJSIPShowEndpoints\r\n
\r\n

Action: QueueAdd\r\n
Queue: support\r\n
Interface: PJSIP/1001\r\n
MemberName: Agent 1001\r\n
\r\n

Action: Originate\r\n
Channel: PJSIP/1001\r\n
Exten: s\r\n
Context: from-internal\r\n
Priority: 1\r\n
CallerID: "Click2Call" <0000>\r\n
Async: yes\r\n
\r\n
```

---

## Dialplan (extensions.conf / Realtime)

### Static dialplan for ARI-controlled calls

When using ARI for IVR, the dialplan hands off to the ARI app — keep it minimal:

```ini
[from-internal]
exten => _XXXX,1,NoOp(Extension ${EXTEN})
 same => n,Dial(PJSIP/${EXTEN},30,Ttr)
 same => n,Goto(vm,${EXTEN},1)

[from-did]
exten => _.,1,NoOp(Inbound DID ${EXTEN})
 same => n,AGI(did_router.py,${EXTEN})   ; AGI resolves DID → context/extension from DB
 same => n,Hangup()

[cc-ivr]
exten => s,1,NoOp(IVR Entry)
 same => n,Stasis(cc)                     ; Hand off to ARI app "cc"
 same => n,Hangup()
```

### AGI for dynamic DID routing

```python
#!/usr/bin/env python3
# did_router.py — resolves inbound DID to queue/IVR via PostgreSQL
import sys
import psycopg2

def agi_send(cmd): sys.stdout.write(cmd + "\n"); sys.stdout.flush()
def agi_read(): return sys.stdin.readline().strip()

# Read AGI environment
env = {}
while True:
    line = agi_read()
    if not line: break
    k, _, v = line.partition(": ")
    env[k] = v

did = sys.argv[1]
conn = psycopg2.connect(DSN)
cur = conn.cursor()
cur.execute("SELECT destination_context, destination_exten FROM did_routing WHERE did = %s", (did,))
row = cur.fetchone()

if row:
    agi_send(f"SET CONTEXT {row[0]}")
    agi_send(f"SET EXTENSION {row[1]}")
    agi_send("SET PRIORITY 1")
else:
    agi_send("SET CONTEXT default")
    agi_send("SET EXTENSION s")
    agi_send("SET PRIORITY 1")
```

---

## Debugging

### Kamailio

```bash
# Live SIP trace (careful in production — verbose)
kamctl fifo ps
sngrep -I /var/log/kamailio/sipcapture.pcap  # best tool for SIP trace analysis
tail -f /var/log/kamailio/kamailio.log | grep -E "ERROR|WARNING"
```

### Asterisk

```
# Asterisk CLI
asterisk -rvvvvv

# PJSIP endpoint status
pjsip show endpoints
pjsip show aors
pjsip show auths

# Active channels
core show channels

# Queue status
queue show

# SIP debug (use sparingly — logs everything)
pjsip set logger on

# ARI connectivity
curl -u ari_user:ari_pass http://localhost:8088/ari/applications
```

### Common failure modes

| Symptom | Likely cause |
|---|---|
| WebRTC client registers but no audio | ICE failure — check rtpengine/rtpproxy config in Kamailio |
| PJSIP endpoint shows "Unavailable" | AOR not qualifying — check qualify_frequency and ps_aors row |
| ARA changes not taking effect | Missed `pjsip reload` via AMI after DB write |
| One-way audio on SIP trunk | NAT — `rtp_symmetric=yes`, `force_rport=yes` on trunk endpoint |
| ARI events stop arriving | WebSocket consumer died silently — add reconnect loop |
| Calls drop after ~90s | Missing SIP re-INVITE handling or RTP timeout |

---

## Security Checklist

- [ ] WSS only (port 443 via Nginx → Kamailio). No plain WS in production.
- [ ] SRTP/DTLS enforced for WebRTC endpoints (`media_encryption=dtls`).
- [ ] AMI bound to localhost only (`[general] bindaddr=127.0.0.1`).
- [ ] ARI bound to localhost only (`[general] bindaddr=127.0.0.1` in ari.conf).
- [ ] Strong AMI/ARI passwords — not the defaults.
- [ ] SIP trunk IPs whitelisted in Kamailio (`permissions` module or `ip_allow`).
- [ ] `fail2ban` monitoring Asterisk security log for auth failures.
- [ ] SRTP key rotation handled by DTLS handshake — not manual.
