"""Fase 16 · el web service fiscal, simulado (D45).

Imita lo que del WSFEv1 importa para numerar: el organismo guarda el último comprobante autorizado por
punto de venta y tipo, y rechaza con el código 10016 todo número que no sea ese más uno. Tres métodos,
con los nombres del manual del desarrollador:

    last_authorized(pos, kind)        FECompUltimoAutorizado
    request_cae(pos, kind, number)    FECAESolicitar, de a un comprobante
    query(pos, kind, number)          FECompConsultar: el CAE de un número, si se autorizó

Lo que simplifica, dicho: no hay SOAP, ni certificado, ni token, ni fechas, ni importes; un pedido es un
solo comprobante; la latencia es un `sleep` configurable, la mitad a la ida y la mitad a la vuelta. El
registro del organismo vive en el esquema `fiscal` de la misma base, con su propia conexión: la
transacción de la caja no lo alcanza, igual que no alcanza a la base de AFIP.

`lose_next_response()` arma la falla que el manual describe en "Operatoria con errores de comunicación":
el organismo autoriza, y la respuesta no vuelve (`Timeout`).
"""

import random
import threading
import time

from lab.race import connect


class Rejected(Exception):
    def __init__(self, code: int, message: str):
        super().__init__(f"{code} {message}")
        self.code, self.message = code, message


class Timeout(Exception):
    """La respuesta no llegó. El organismo puede haber autorizado o no: hay que preguntarle."""


class FiscalService:
    def __init__(self, latency: float = 0.0):
        self.latency = latency
        self.conn = connect("postgres")
        self.lock = threading.Lock()          # el organismo atiende de a un pedido por vez
        self.lose = 0
        self.rng = random.Random(2015)

    def _last(self, pos: int, kind: str) -> int:
        row = self.conn.execute("""
            SELECT coalesce((SELECT max(number) FROM fiscal.authorized WHERE point_of_sale = %(p)s AND kind = %(k)s),
                            (SELECT last_number FROM fiscal.start WHERE point_of_sale = %(p)s AND kind = %(k)s), 0)""",
                                {"p": pos, "k": kind}).fetchone()
        return row[0]

    def last_authorized(self, pos: int, kind: str) -> int:
        time.sleep(self.latency)
        with self.lock:
            return self._last(pos, kind)

    def request_cae(self, pos: int, kind: str, number: int) -> str:
        time.sleep(self.latency / 2)                                  # la ida
        with self.lock:
            expected = self._last(pos, kind) + 1
            if number != expected:
                raise Rejected(10016, f"comp. {number} no coincide con el próximo a autorizar")
            cae = str(self.rng.randrange(10**13, 10**14))
            self.conn.execute("INSERT INTO fiscal.authorized (point_of_sale, kind, number, cae) VALUES (%s, %s, %s, %s)",
                              (pos, kind, number, cae))
            lost = self.lose > 0
            if lost:
                self.lose -= 1
        time.sleep(self.latency / 2)                                  # la vuelta
        if lost:
            raise Timeout(f"sin respuesta para el comprobante {number}")
        return cae

    def query(self, pos: int, kind: str, number: int) -> str | None:
        time.sleep(self.latency)
        with self.lock:
            row = self.conn.execute("SELECT cae FROM fiscal.authorized WHERE point_of_sale = %s AND kind = %s AND number = %s",
                                    (pos, kind, number)).fetchone()
        return row[0] if row else None

    def lose_next_response(self, n: int = 1) -> None:
        self.lose += n

    def reset(self) -> None:
        """Vuelve el organismo al punto de partida de la caja."""
        with self.lock:
            self.conn.execute("TRUNCATE fiscal.authorized")

    def close(self) -> None:
        self.conn.close()
