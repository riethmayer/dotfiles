# Reference

Assumes the vocabulary in [LANGUAGE.md](LANGUAGE.md) — **module**, **interface**, **seam**, **adapter**, **leverage**, **locality**.

## Dependency Categories

When assessing a candidate for deepening, classify its dependencies. The category determines how the deepened module is tested across its seam.

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — merge the modules and test through the new interface directly. No adapter needed.

### 2. Local-substitutable

Dependencies that have local test stand-ins (PGLite for Postgres, in-memory filesystem). Deepenable if the stand-in exists. The deepened module is tested with the stand-in running in the test suite. The seam is internal; no port at the module's external interface.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). Define a **port** (interface) at the seam. The deep module owns the logic; the transport is injected as an **adapter**. Tests use an in-memory adapter. Production uses an HTTP/gRPC/queue adapter.

Recommendation shape: *"Define a port at the seam, implement an HTTP adapter for production and an in-memory adapter for testing, so the logic sits in one deep module even though it's deployed across a network."*

### 4. True external (Mock)

Third-party services (Stripe, Twilio, etc.) you don't control. The deepened module takes the external dependency as an injected port; tests provide a mock adapter.

## Seam Discipline

- **One adapter means a hypothetical seam. Two adapters means a real one.** Don't introduce a port unless at least two adapters are justified (typically production + test). A single-adapter seam is just indirection.
- **Internal seams vs external seams.** A deep module can have internal seams (private to its implementation, used by its own tests) as well as the external seam at its interface. Don't expose internal seams through the interface just because tests use them.

## Testing Strategy: Replace, Don't Layer

- Old unit tests on shallow modules become waste once tests at the deepened module's interface exist — delete them.
- Write new tests at the deepened module's interface. The **interface is the test surface**.
- Tests assert on observable outcomes through the interface, not internal state.
- Tests should survive internal refactors — they describe behaviour, not implementation. If a test has to change when the implementation changes, it's testing past the interface.

## Issue Template

<issue-template>

## Problem

Describe the architectural friction using [LANGUAGE.md](LANGUAGE.md) vocabulary:

- Which modules are **shallow** (interface nearly as complex as implementation)
- Where the **seams** are misplaced or missing
- Why **locality** is poor (changes ripple across callers)

## Proposed Interface

The chosen interface design:

- Interface signature (types, methods, params) plus invariants, ordering, error modes
- Usage example showing how callers use it
- What the implementation hides behind the seam
- The **leverage** callers get per unit of interface they learn

## Dependency Strategy

Which category applies and how dependencies are handled:

- **In-process**: merged directly
- **Local-substitutable**: tested with [specific stand-in]
- **Ports & adapters**: port definition, production adapter, test adapter
- **Mock**: mock boundary for external services

## Testing Strategy

- **New interface tests to write**: describe the behaviours to verify at the **seam**
- **Old tests to delete**: list the shallow-module tests that become redundant
- **Test environment needs**: any local stand-ins or adapters required

## Implementation Recommendations

Durable architectural guidance that is NOT coupled to current file paths:

- What the module should own (responsibilities)
- What it should hide (implementation details behind the seam)
- What it should expose (the interface contract)
- How callers should migrate to the new interface

</issue-template>
