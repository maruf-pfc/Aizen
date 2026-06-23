# Scientific Calculator Module (v1.4.2)

The Scientific Calculator is a robust, low-RAM math evaluation engine designed with native Material 3 Expressive aesthetics. It utilizes a custom recursive descent parser that parses mathematical expressions in a single pass without using complex regular expressions or external heavy dependencies.

## Key Features

1. **State-aware Trig Engine**:
   - High-precision calculation in both Degree (DEG) and Radian (RAD) modes.
   - Built-in floating-point safety: detects invalid trigonometry operations (e.g. `tan(90°)` or `tan(270°)` in DEG mode) and triggers domain errors rather than producing near-infinite float values.

2. **Shift Mode (2nd)**:
   - A toggle state swaps trigonometric keys to their inverse counterparts (`sin` → `asin`, `cos` → `acos`, `tan` → `atan`) and standard functions to hyperbolic equivalents (`sinh`, `cosh`, `tanh` and their inverses).

3. **Expanded Math Function Library**:
   - **Trigonometric**: `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `atan2`.
   - **Hyperbolic**: `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh`.
   - **Logarithmic & Exponential**: `log` (base-10), `log2` (base-2), `ln` (natural log), `exp`.
   - **Roots & Powers**: `sqrt`, `cbrt`, `sq` (x²), `rec` (1/x), `^` (xʸ).
   - **Integers & Stats**: `fact` (factorial up to 170!), `gcd` (greatest common divisor), `lcm` (least common multiple), `abs`, `sign`.
   - **Rounding**: `round`, `floor`, `ceil`, `trunc`.
   - **Constants**: `pi` ($\pi$), `e`, `phi` ($\phi$), `tau` ($\tau$).

4. **AMOLED-Optimized Layout**:
   - Portrait-only 5-column grid mapping all essential scientific functions.
   - Status badges display active configuration (DEG/RAD, memory registers, active Shift mode).
   - Visual result preview calculated on the fly as the user types.

5. **Memory Registers & Tape History**:
   - Traditional calculator memory operations: Clear Memory (`MC`), Recall Memory (`MR`), Add to Memory (`M+`), and Subtract from Memory (`M-`).
   - Dynamic persistent calculation tape recording up to the last 20 operations with instant tap-to-recall actions.

## Architecture

- **`lib/features/calculator/domain/engine/calculator_engine.dart`**: Pure Dart mathematical tokenizer and parser. Contains all trigonometry scaling logic and constant values.
- **`lib/features/calculator/presentation/pages/calculator_page.dart`**: The grid layout UI utilizing custom `AizenPressable` scaling buttons, haptic callbacks, and a persistent history sheet.
