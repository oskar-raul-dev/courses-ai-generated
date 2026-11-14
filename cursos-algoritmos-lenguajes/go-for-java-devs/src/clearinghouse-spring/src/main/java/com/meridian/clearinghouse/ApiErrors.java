package com.meridian.clearinghouse;

import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/** Traduce excepciones al cuerpo {error, code} que comparten las dos implementaciones. */
@RestControllerAdvice
public class ApiErrors {

    @ExceptionHandler(ApiException.class)
    ResponseEntity<Map<String, String>> api(ApiException e) {
        return body(e.status(), e.code(), e.getMessage());
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    ResponseEntity<Map<String, String>> unreadable(HttpMessageNotReadableException e) {
        return body(HttpStatus.BAD_REQUEST, "bad_request", "el cuerpo no es JSON válido");
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<Map<String, String>> invalid(MethodArgumentNotValidException e) {
        return body(HttpStatus.BAD_REQUEST, "validation_failed", "movimiento inválido");
    }

    @ExceptionHandler(MissingServletRequestParameterException.class)
    ResponseEntity<Map<String, String>> missing(MissingServletRequestParameterException e) {
        return body(HttpStatus.BAD_REQUEST, "validation_failed", "el parámetro " + e.getParameterName() + " es obligatorio");
    }

    private static ResponseEntity<Map<String, String>> body(HttpStatus status, String code, String message) {
        return ResponseEntity.status(status).body(Map.of("error", message, "code", code));
    }
}
