package com.meridian.clearinghouse;

/**
 * La regla contable del duelo, idéntica a la de la versión Go: void no genera asientos;
 * el resto, caja de la tienda contra ventas (sale, refund) o bancos (deposit, withdrawal).
 */
final class Ledger {

    record Pair(String debit, String credit, long signed) {
    }

    private Ledger() {
    }

    static Pair of(String store, String type, long amount) {
        return switch (type) {
            case "sale" -> new Pair("caja:" + store, "ventas", amount);
            case "refund" -> new Pair("caja:" + store, "ventas", -amount);
            case "deposit" -> new Pair("caja:" + store, "bancos", amount);
            case "withdrawal" -> new Pair("caja:" + store, "bancos", -amount);
            default -> null;
        };
    }
}
