// ============================================================================
// Comparación de dos enteros de 128 bits (a vs b)
// ============================================================================
// Entradas:
//   - Número "a" (128 bits): X0 (LSB 64 bits), X1 (MSB 64 bits)
//   - Número "b" (128 bits): X2 (LSB 64 bits), X3 (MSB 64 bits)
//
// Salida:
//   - El registro PSTATE queda actualizado con los flags de la condición
//     de la comparación de 128 bits (a - b).
// ============================================================================

.global _start

.text
_start:
    // 1. Comparar los 64 bits menos significativos (LSB)
    //    subs actualiza los flags del PSTATE (N, Z, C, V) basándose en (X0 - X2).
    //    Esto genera/limpia el flag C (carry/borrow) necesario para la parte alta.
    subs    xzr, x0, x2

    // 2. Comparar los 64 bits más significativos (MSB) con el préstamo
    //    sbcs descuenta el borrow generado por la parte baja y calcula (X1 - X3 - borrow).
    //    El resultado se descarta usando 'xzr' (zero register), afectando finalmente a PSTATE.
    sbcs    xzr, x1, x3

    // ========================================================================
    // En este punto, PSTATE contiene el resultado de la comparación (a vs b).
    // ========================================================================
    // A partir de aquí se pueden utilizar saltos condicionales estándar de ARM64:
    //
    // Para enteros SIN SIGNO (Unsigned):
    //   b.eq  es_igual         // Si a == b
    //   b.hi  a_es_mayor_uns   // Si a > b (Unsigned Higher)
    //   b.lo  a_es_menor_uns   // Si a < b (Unsigned Lower)
    //   b.hs  a_mayor_o_igual  // Si a >= b (Unsigned Higher or Same)
    //   b.ls  a_menor_o_igual  // Si a <= b (Unsigned Lower or Same)
    //
    // Para enteros CON SIGNO (Signed):
    //   b.eq  es_igual         // Si a == b
    //   b.gt  a_es_mayor_sig   // Si a > b (Signed Greater Than)
    //   b.lt  a_es_menor_sig   // Si a < b (Signed Less Than)
    //   b.ge  a_mayor_o_igual  // Si a >= b (Signed Greater or Equal)
    //   b.le  a_menor_o_igual  // Si a <= b (Signed Less or Equal)
    // ========================================================================

    // Finalizar el programa mediante la syscall exit (264)
    mov     x0, #0              // Código de retorno 0
    mov     x8, #93             // Syscall exit en Linux ARM64 (o #264 según entorno)
    svc     #0