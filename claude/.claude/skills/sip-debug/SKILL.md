---
name: sip-debug
description: "Diagnoses SIP/VoIP call failures from traces, pcaps, or logs. Invoked when: a call fails, drops, has one-way/no audio, registration fails, or a SIP trace/pcap/sngrep capture needs analysis. Covers: reading the SIP ladder, mapping response codes to causes, NAT/RTP issues, codec mismatches, and Asterisk/Kamailio log correlation."
---

<skill>
Diagnose the SIP/call failure by following this checklist in order. Report findings as: symptom → evidence in the trace → root cause → fix. Never guess a cause without pointing at the message or log line that proves it.

## 1. Capture (if no trace provided yet)

- Live signaling view: `sngrep -d any port 5060` (add `-r` to see RTP streams).
- Full capture for offline analysis: `tcpdump -i any -w /tmp/call.pcap port 5060 or portrange 10000-20000`.
- Asterisk: `pjsip set logger on` then check `/var/log/asterisk/full`; Kamailio: raise `debug=` or use `siptrace` module.
- In Docker, capture on the host or with `docker exec` inside the container — capturing on the wrong side of the NAT hides the actual packets on the wire.

## 2. Read the ladder

- Identify the legs: who sends the INVITE, what proxies/B2BUAs are in the path (`Via` and `Record-Route` headers), where the final response comes from.
- Find the first message that deviates from a normal flow (INVITE → 100 → 180 → 200 → ACK → RTP → BYE). Everything after the first anomaly is usually noise.
- Compare `Contact`, `Via`, and SDP `c=` addresses against real routable IPs — private IPs (10.x, 192.168.x) leaking into public-facing messages mean broken NAT handling.

## 3. Response code → usual suspects

| Code | Usual cause |
|---|---|
| 401/407 loop | Wrong password/realm; check the second request has a valid `Authorization` header |
| 403 | Auth OK but blocked by ACL/permissions, IP not allowed on trunk, or fraud filter |
| 404 | Routing: number not matching the dialplan/dispatcher; check normalization (E.164 vs national) |
| 408 / no response | Packet never arrived: firewall, wrong transport (UDP vs TCP/TLS), DNS, or NAT dropping replies |
| 480/486/600 | Callee side: unregistered, busy, or DND — check registration state |
| 488 | SDP/codec mismatch — compare `m=`/`a=rtpmap` in offer vs what the endpoint allows |
| 5xx from own server | Read the server log at that timestamp — dialplan error, DB down, or resource exhaustion |

## 4. Audio problems (call connects, media broken)

- One-way audio: nearly always NAT/firewall on one leg. Check SDP `c=` on each side, confirm RTP is flowing both directions (`sngrep` RTP view, or filter the pcap by the negotiated ports).
- No audio at all: RTP port range not open/mapped (Docker port mapping vs `rtp.conf` range, security group, rtpengine not engaged).
- Choppy/robotic audio: packet loss or jitter — check with Wireshark RTP stream analysis; if only under load, suspect CPU (transcoding) before network.
- Dead air after ~30s then disconnect: ACK never arrived (NAT again) — session times out.

## 5. Registration failures

- Confirm the REGISTER reaches the server (capture on the server side, not just the client).
- 401 then success is normal (digest challenge); 401 loop is credentials; timeout is transport/firewall.
- Check expiry handling: re-REGISTER must happen before `expires`; NAT keepalives needed for UDP clients behind NAT.

## 6. Report

- Deliver: one-line root cause, the evidence (message/log line), the fix, and how to verify it (place a test call, `sipp` scenario, or re-capture).
- If the fix touches RTP ports, NAT config, or transports, explicitly list what else could break and must be retested.
- Sanitize before sharing: strip passwords from `Authorization` headers and real phone numbers from any trace pasted into docs or tickets.
</skill>
