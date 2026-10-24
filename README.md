| Nombre | Carnet     |
|--------|------------|
| Wilson Wilfredo Pérez Otzoy | 202300697 |
---
# Comparación de Enteros de 128 Bits en ARM64

Este ejecicion contiene una implementación en lenguaje ensamblador **ARM64** pura para realizar la comparación de dos enteros no asignados (o asignados) de 128 bits, afectando directamente los flags de condición del registro **PSTATE** sin modificar los valores almacenados en los registros originales.

---

## 📌 Descripción del Problema

Se requiere comparar dos números de 128 bits, denominados **$a$** y **$b$**, cuya estructura en registros de 64 bits está definida de la siguiente manera:

* **Número $a$ (128 bits):**
  * `X0`: 64 bits menos significativos (LSB)
  * `X1`: 64 bits más significativos (MSB)
* **Número $b$ (128 bits):**
  * `X2`: 64 bits menos significativos (LSB)
  * `X3`: 64 bits más significativos (MSB)

El programa debe efectuar la comparación $a - b$ afectando el registro **PSTATE** para permitir la toma de decisiones mediante saltos condicionales (`b.hi`, `b.lo`, `b.eq`, `b.gt`, `b.lt`, etc.).

---

## 🛠️ Fundamento Teórico

En arquitectura ARM64 no existen instrucciones directas de comparación para operandos de 128 bits. Por ello, la operación se divide en dos etapas utilizando las instrucciones de resta con préstamo (*carry/borrow*):

1. **`subs xzr, x0, x2`**:
   Resta los 64 bits menos significativos ($X0 - X2$) descartando el resultado mediante el registro cero (`xzr`). Actualiza los flags de **PSTATE** y genera un flag de *Carry* ($C = 0$ si hubo préstamo/*borrow*, $C = 1$ si no lo hubo).
2. **`sbcs xzr, x1, x3`**:
   Resta los 64 bits más significativos considerando el préstamo acumulado ($X1 - X3 - \text{borrow}$). El estado final del registro **PSTATE** reflejará con precisión la relación lógica entre los dos enteros de 128 bits.

---

## 💻 Código Fuente (`main.s`)

```assembly
// ============================================================================
// Comparación de dos enteros de 128 bits en ARM64 afectando PSTATE
// ============================================================================

.global _start

.text
_start:
    // ------------------------------------------------------------------------
    // 1. Carga de datos de prueba (Simulación de entrada en registros)
    // ------------------------------------------------------------------------
    // Número a (128 bits): 0x0000000000000002_0000000000000006
    movz    x0, #0x0006             // LSB de a = 6
    movz    x1, #0x0002             // MSB de a = 2

    // Número b (128 bits): 0x0000000000000001_FFFFFFFFFFFFFFFF
    mov     x2, #0xFFFFFFFFFFFFFFFF // LSB de b = 2^64 - 1
    movz    x3, #0x0001             // MSB de b = 1

    // ------------------------------------------------------------------------
    // 2. Comparación de 128 bits (a - b) afectando PSTATE
    // ------------------------------------------------------------------------
    subs    xzr, x0, x2             // Comparar LSBs y generar Carry/Borrow
    sbcs    xzr, x1, x3             // Comparar MSBs con Carry/Borrow en PSTATE

    // ------------------------------------------------------------------------
    // 3. Evaluación de Banderas en PSTATE
    // ------------------------------------------------------------------------
    b.hi    a_es_mayor              // Salto si a > b (Unsigned Higher)

a_es_menor_o_igual:
    mov     x0, #0                  // Retorna 0 en la terminal si a <= b
    b       exit_program

a_es_mayor:
    mov     x0, #1                  // Retorna 1 en la terminal si a > b

exit_program:
    mov     x8, #93                 // Syscall exit (Linux ARM64)
    svc     #0
```