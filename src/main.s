// ============================================================================
// Comparación de dos enteros de 128 bits en ARM64 afectando PSTATE
// ============================================================================

.global _start

.text
_start:
    // ------------------------------------------------------------------------
    // 1. Carga de datos de prueba (Simulando la entrada preexistente)
    // ------------------------------------------------------------------------
    // Número a: X1:X0
    movz    x0, #0x0006             // LSB de a = 6
    movz    x1, #0x0002             // MSB de a = 2

    // Número b: X3:X2
    mov     x2, #0xFFFFFFFFFFFFFFFF // LSB de b = 2^64 - 1 (Máximo valor de 64 bits)
    movz    x3, #0x0001             // MSB de b = 1

    // ------------------------------------------------------------------------
    // 2. Comparación de "a" contra "b" afectando el registro PSTATE
    // ------------------------------------------------------------------------

    // Paso A: Comparar LSB (X0 - X2).
    // Produce un prestamo (borrow) porque 6 < 0xFFFFFFFFFFFFFFFF.
    // Esto limpia el Carry Flag (C = 0) en PSTATE para indicar borrow.
    subs    xzr, x0, x2

    // Paso B: Comparar MSB considerando el préstamo (X1 - X3 - borrow).
    // Opera: 2 - 1 - 1 = 0.
    // Como el resultado final no requiere préstamo adicional, C se establece en 1
    // y determina que "a" es mayor que "b" (a > b).
    sbcs    xzr, x1, x3

    // ------------------------------------------------------------------------
    // 3. Verificación de banderas y salida del programa
    // ------------------------------------------------------------------------
    // Evaluamos el resultado de PSTATE con un salto condicional (b.hi -> Unsigned Higher)
    b.hi    a_es_mayor

a_es_menor_o_igual:
    mov     x0, #0                  // Retorna 0 en la terminal si a <= b
    b       exit_program

a_es_mayor:
    mov     x0, #1                  // Retorna 1 en la terminal si a > b

exit_program:
    mov     x8, #93                 // Syscall exit en Linux ARM64
    svc     #0