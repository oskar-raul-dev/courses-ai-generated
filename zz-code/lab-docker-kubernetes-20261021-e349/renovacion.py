"""F19 §5.4: la renovación con tráfico. Cinco peticiones HTTPS por segundo a la puerta durante ocho minutos,
validando con la CA, y el serial del certificado servido cada vez que cambia. Uso: renovacion.py <ca.crt>"""
import socket, ssl, sys, time, http.client
ctx = ssl.create_default_context(cafile=sys.argv[1])
start, last, ok, bad = time.time(), None, 0, 0
while time.time() - start < 480:
    t = time.time()
    try:
        conn = http.client.HTTPSConnection("api.localhost", 8443, context=ctx, timeout=5)
        conn.request("GET", "/pricing/prices?store=DRO-007")
        resp = conn.getresponse(); resp.read()
        der = conn.sock.getpeercert(binary_form=True)
        from cryptography import x509
        serial = format(x509.load_der_x509_certificate(der).serial_number, "X")
        conn.close()
        if resp.status == 200: ok += 1
        else: bad += 1
        if serial != last:
            print(f"{t-start:7.1f}s {time.strftime('%H:%M:%S')} certificado servido: serial {serial[:16]}…", flush=True)
            last = serial
    except Exception as e:
        bad += 1; print(f"{t-start:7.1f}s fallo: {e}", flush=True)
    time.sleep(max(0, 0.2 - (time.time() - t)))
print(f"fin: {ok} bien, {bad} mal")
