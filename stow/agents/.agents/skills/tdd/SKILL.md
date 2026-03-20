---
name: tdd
description: Test-driven development — vertical slices, integration tests, deep modules. Use when building features, fixing bugs, or refactoring with test-first approach.
---

# Test-Driven Development

TDD is a design tool. Writing the test first forces you to think about what your code should do before thinking about how. The result is better interfaces, fewer bugs, and code you can refactor with confidence.

## Philosophy

**Tests capture expectations and outcomes, not implementation details.** A test should describe what the system does through its public interface. If you refactor internals and a test breaks — but behavior hasn't changed — that test was wrong.

**Good tests** are integration-style: exercise real code paths through public APIs. They read like specifications. "user can checkout with valid cart" tells you exactly what capability exists. These tests survive refactors because they don't care about internal structure.

**Bad tests** mock internal collaborators, test private methods, or verify through back-channels (querying a database directly instead of using the interface). Warning sign: test breaks on refactor, but behavior is fine.

**Deep modules over shallow ones.** Small interfaces hiding complex implementations. TDD naturally pushes you here — when you test through the public interface, you're free to change everything behind it.

See [tests.md](tests.md) for examples, [mocking.md](mocking.md) for mocking guidelines, [deep-modules.md](deep-modules.md) for module design.

## Vertical Slices, Not Horizontal

**Never write all tests first, then all implementation.** That's horizontal slicing — it produces bad tests:

- Tests written in bulk test *imagined* behavior, not *actual* behavior
- You commit to test structure before understanding the implementation
- Tests become insensitive to real changes

**One test, one implementation, repeat.** Each test responds to what you learned from the previous cycle. This is the tracer bullet approach.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED->GREEN: test1->impl1
  RED->GREEN: test2->impl2
  RED->GREEN: test3->impl3
```

## Workflow

### 1. Plan

Before writing any code:

- [ ] Confirm with user what interface changes are needed
- [ ] Confirm which behaviors to test (you can't test everything — prioritize)
- [ ] Identify opportunities for [deep modules](deep-modules.md)
- [ ] Design interfaces for [testability](interface-design.md)
- [ ] List behaviors to verify (not implementation steps)
- [ ] Get user approval on the plan

Ask: "What should the public interface look like? Which behaviors matter most?"

### 2. Red

Write ONE test for ONE behavior. Run it. Watch it fail.

**The failure matters.** If you didn't see it fail, you don't know it tests the right thing. Confirm:

- Test *fails* (not errors from typos/imports)
- Failure message makes sense
- It fails because the feature is missing

Test passes immediately? You're testing existing behavior. Fix the test.

### 3. Green

Write the simplest code that makes the test pass. Nothing more.

- Don't add features the test doesn't require
- Don't refactor yet
- Don't anticipate future tests

Run the test. Confirm it passes. Confirm other tests still pass.

**Test fails? Fix the code, not the test.**

### 4. Refactor

After green, clean up. See [refactoring.md](refactoring.md).

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Improve names
- [ ] Run tests after each change

**Never refactor while red.** Get to green first.

### 5. Repeat

Next behavior, next test, next implementation.

## When to Use

- New features
- Bug fixes (write a test that reproduces the bug first)
- Refactoring (add missing tests, then refactor)
- Behavior changes

Exceptions exist (throwaway prototypes, config files, generated code) — but they're exceptions, not the norm. When in doubt, test first.

## Why Test-First

Tests written after code pass immediately. That proves nothing — the test might verify the wrong thing, test implementation instead of behavior, or miss edge cases.

Test-first forces you to see the failure, proving the test actually catches the bug. Tests-first answer "what *should* this do?" Tests-after answer "what *does* this do?" — biased by your implementation.

## Per-Cycle Checklist

```
[ ] Test describes behavior, not implementation
[ ] Test uses public interface only
[ ] Test would survive internal refactor
[ ] Watched it fail before writing code
[ ] Code is minimal for this test
[ ] No speculative features added
[ ] All tests pass
```

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write the API you wish existed. Assertion first. Ask user. |
| Test too complicated | Design too complicated. Simplify the interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup huge | Extract helpers. Still big? Simplify the design. |
| Hard to test | Listen to the test. Hard to test = hard to use. |
