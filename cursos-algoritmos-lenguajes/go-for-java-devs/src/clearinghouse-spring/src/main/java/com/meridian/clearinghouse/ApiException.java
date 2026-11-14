package com.meridian.clearinghouse;

import org.springframework.http.HttpStatus;

/** Un error de la API con su código estable: el contrato se apoya en {@code code}. */
public class ApiException extends RuntimeException {

    private final HttpStatus status;
    private final String code;

    public ApiException(HttpStatus status, String code, String message) {
        super(message);
        this.status = status;
        this.code = code;
    }

    public HttpStatus status() { return status; }
    public String code() { return code; }
}
