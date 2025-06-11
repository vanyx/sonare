package com.sonare.spring.exception;


public class AppExceptions {

    public static class AlertAlreadyExistsException extends RuntimeException {
        public AlertAlreadyExistsException(String message) {
            super(message);
        }
    }
}
