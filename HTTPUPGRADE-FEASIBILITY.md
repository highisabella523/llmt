# HTTPUpgrade feasibility — 2026-09-18

## Result: not runnable in the current native data plane

HTTPUpgrade is a real Xray transport: it uses an HTTP/1.1 `Upgrade` request/response carrying raw VLESS bytes, not WebSocket framing. Xray's official transport reference documents support for it, but the current Lumen server is a FastAPI/Uvicorn ASGI application whose only bidirectional upgrade surface is a WebSocket handler. It has no Xray inbound, raw HTTP connection hijack, or HTTPUpgrade parser/listener.

The existing `vless-httpupgrade` capability gate is therefore correct to remain unavailable. Changing the URI serializer or setting `available=True` would produce client profiles that the deployed server cannot accept, which would be a false implementation.

## What an actual implementation requires

A production implementation would require a separately supervised HTTPUpgrade-capable inbound (for example, a pinned Xray Core process), a same-container reverse-proxy/router that directs the upgrade path to it, authenticated runtime configuration generation/reload from the Lumen ownership state, traffic/quota accounting integration, lifecycle health checks, and a real Railway staging deployment using a compatible Xray client. It cannot be added safely as a small FastAPI route or serializer edit.

The current code deliberately does not bundle or execute such a new data-plane runtime. No removed transport was reintroduced.

## Verification performed

- Reviewed current `transports.py`: HTTPUpgrade is present as a capability but explicitly unavailable because the installed runtime is FastAPI/Uvicorn WebSocket-only.
- Reviewed the current relay: the public data plane exposes only a WebSocket route and no raw HTTP upgrade ingress.
- Checked Xray official transport documentation: HTTPUpgrade is a valid Xray transport, but requires a matching inbound implementation.
- No Railway deployment credentials or isolated staging service were available, so no live Railway protocol test was performed.

## References

- https://xtls.github.io/en/config/transports/httpupgrade.html
- https://xtls.github.io/en/config/transport.html
