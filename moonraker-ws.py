#!/usr/bin/env python3
import asyncio, os, json, signal, sys
import websockets

UDS_PATH = "/tmp/moonraker_ws.sock"          # The local Unix socket your client will use
MOONRAKER_WS = "ws://127.0.0.1:7125/websocket"  # Moonraker WebSocket

# Framing:
# - Many Klipper/Moonraker UDS clients use ETX (0x03) as a frame terminator.
# - Some use newline '\n'. We'll accept either, and always send ETX back.
ETX = b"\x03"

async def client_to_ws(reader: asyncio.StreamReader, ws: websockets.WebSocketClientProtocol):
    """Read framed JSON from UDS client; forward JSON text to Moonraker WS"""
    try:
        while True:
            # Prefer ETX framing; fallback to newline if ETX never arrives.
            try:
                raw = await reader.readuntil(ETX)
                data = raw[:-1]  # strip ETX
            except asyncio.IncompleteReadError as e:
                if e.partial:
                    data = e.partial
                else:
                    break
            except asyncio.LimitOverrunError:
                # If no ETX in buffer, try a line
                data = await reader.readline()
                if not data:
                    break
                data = data.rstrip(b"\r\n")

            if not data:
                break

            # Validate it's JSON; if not, just forward as-is text
            try:
                obj = json.loads(data.decode("utf-8", errors="replace"))
                await ws.send(json.dumps(obj))
            except Exception:
                await ws.send(data.decode("utf-8", errors="replace"))
    except (asyncio.CancelledError, websockets.ConnectionClosed):
        pass

async def ws_to_client(writer: asyncio.StreamWriter, ws: websockets.WebSocketClientProtocol):
    """Read messages from Moonraker WS; write JSON + ETX to UDS client"""
    try:
        async for msg in ws:
            if isinstance(msg, bytes):
                payload = msg
            else:
                payload = msg.encode("utf-8", errors="replace")
            writer.write(payload + ETX)  # always delimit with ETX toward client
            await writer.drain()
    except (asyncio.CancelledError, websockets.ConnectionClosed):
        pass
    finally:
        try:
            writer.close()
            await writer.wait_closed()
        except Exception:
            pass

async def handle_client(reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
    peer = "uds-client"
    try:
        async with websockets.connect(MOONRAKER_WS, ping_interval=20, ping_timeout=20) as ws:
            to_ws = asyncio.create_task(client_to_ws(reader, ws))
            to_cli = asyncio.create_task(ws_to_client(writer, ws))
            done, pending = await asyncio.wait({to_ws, to_cli}, return_when=asyncio.FIRST_COMPLETED)
            for t in pending:
                t.cancel()
    except Exception as e:
        # Bubble an error back to the client as a JSON-RPC error frame
        err = {"jsonrpc":"2.0","error":{"code":-32000,"message":f"Proxy error: {e.__class__.__name__}: {e}"}}
        try:
            writer.write(json.dumps(err).encode() + ETX)
            await writer.drain()
        except Exception:
            pass
        try:
            writer.close()
            await writer.wait_closed()
        except Exception:
            pass

async def main():
    # Clean up any stale socket
    try:
        if os.path.exists(UDS_PATH):
            os.remove(UDS_PATH)
    except Exception:
        pass

    server = await asyncio.start_unix_server(handle_client, path=UDS_PATH, limit=1024*1024)
    os.chmod(UDS_PATH, 0o666)  # relax permissions if multiple users need it
    print(f"[proxy] listening on {UDS_PATH}, bridging to {MOONRAKER_WS}", file=sys.stderr)

    # Graceful shutdown
    stop = asyncio.Future()
    for sig in (signal.SIGINT, signal.SIGTERM):
        asyncio.get_running_loop().add_signal_handler(sig, stop.set_result, None)
    await stop
    server.close()
    await server.wait_closed()
    try:
        os.remove(UDS_PATH)
    except Exception:
        pass

if __name__ == "__main__":
    asyncio.run(main())
