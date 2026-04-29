---
name: invert
description: Stress-test a goal, plan, strategy, decision, artifact, or prompt by reasoning backwards from failure. Use whenever the user says "invert", "/invert", "pre-mortem", "stress-test this", "what could go wrong", "red-team this", "steelman the failure case", or asks you to critique a plan/OKR/strategy/prompt by finding how it breaks before improving it. Also trigger when the user shares a strategy doc, OKR set, plan, or prompt and asks for risks, holes, or blind spots — even if they don't use the word "invert".
---

# /invert

Treat the user input as something to debug through inversion. **Do not begin by improving it. Begin by identifying how it fails.** The goal is to surface failure modes, hidden assumptions, and second-order effects the user hasn't already considered — not to give motivational advice or a polished rewrite.

## Why inversion

People overweight the path-to-success and underweight the ways a plan quietly breaks. Inversion forces the opposite: start from "this failed" and work backward. It surfaces Goodhart traps, misaligned incentives, selection bias, and unowned dependencies that forward-planning misses. Even when the plan survives, the user leaves with a concrete list of leading indicators and guardrails — not just a feeling that "it's a good plan."

## Workflow

1. **Restate the objective** in one sentence. If the input is ambiguous, state the interpretation you're running with — don't ask a clarifying question unless the objective is genuinely unrecoverable.
2. **Define failure concretely:**
   - what failure looks like (observable end-state)
   - who experiences the failure (which stakeholder feels the pain)
   - what evidence would show failure happened (the disconfirming data)
3. **Identify failure modes** across these categories. Not every category will apply to every input — skip ones that don't, rather than padding:
   - strategy
   - execution
   - incentives / stakeholder alignment
   - assumptions / missing information
   - timing / sequencing
   - behavioral biases
4. **Rank the top failure modes** by likelihood × severity × detectability. The most dangerous modes are high-likelihood, high-severity, *low-detectability* — they're the ones that silently accumulate.
5. **For each major failure mode**, give:
   - why it is plausible (concrete mechanism, not generic worry)
   - early warning signs (what you'd see weeks before the failure manifests)
   - prevention (what stops it from starting)
   - mitigation (what limits damage if it starts anyway)
6. **Extract critical assumptions** that must be tested before proceeding. Each assumption should be falsifiable — if you can't imagine evidence that would disprove it, rewrite it.
7. **Convert the analysis into an action checklist** (Do / Avoid / Verify).
8. **If the input is a prompt or artifact, rewrite it in a stronger form** after the critique — informed by the failure modes you just surfaced.

## Output structure

Follow this structure exactly. Use **one H1** at the top (the document title); every other section is H2 or deeper. Multiple H1s break downstream renderers and document outlines — never emit more than one `#` heading.

```markdown
# Inversion: [short name of the thing being stress-tested]

## Objective
[one sentence]

## Failure definition
[concrete description: what failure looks like, who experiences it, evidence of failure]

## Top failure modes

### 1. [failure mode — short, specific, verb-led]
- **Category:**
- **Why plausible:**
- **Early warnings:**
- **Prevention:**
- **Mitigation:**

### 2. [...]

[continue — aim for 4-7 modes; fewer if the plan is small, more only if genuinely distinct]

## Critical assumptions to test
1. ...
2. ...
3. ...

## Do / Avoid / Verify checklist

### Do
1. ...

### Avoid
1. ...

### Verify
1. ...

## Bottom line
[one short paragraph: proceed, revise, or stop — and the single most important thing to fix first]
```

If the input was a prompt or artifact, append a **`## Rewritten version`** section after the bottom line with the stronger form.

## Writing rules

- **Be specific, not motivational.** "The team might lose focus" is useless. "Volume KR will incentivize lowering the signal threshold, which will degrade IC conversion within one quarter" is useful.
- **Prefer concrete mechanisms over abstract advice.** Every failure mode should name a causal chain.
- **Surface hidden incentives and second-order effects.** Who benefits from gaming each metric? What does the plan *reward* that it didn't intend to reward?
- **State assumptions explicitly** when context is incomplete. Don't stall asking for more info — run the analysis on your best interpretation and flag the assumption.
- **Goodhart is the default failure mode** for any plan with a numeric target. Always check whether the metric can be gamed without achieving the underlying goal.
- **Distinguish what the owner controls from what they don't.** A failure mode that depends on someone else's behavior is a stakeholder-alignment risk, not an execution risk — categorize accordingly.
- **Name specific people / teams / systems** from the user's context when the input gives them. Generic "the team" loses signal.

## Anti-patterns to avoid

- Opening with a summary of what's good about the plan. The user asked for inversion — skip the compliment sandwich.
- Listing failure modes that reduce to "you might not execute well." That's not a failure mode, it's a tautology.
- Writing prevention steps that are just "communicate more" or "align stakeholders." Name the specific artifact, cadence, or decision rule.
- Producing a checklist so long it's unreadable. Aim for 4-7 items per section; cut the weakest.
- Forgetting the bottom line. The user needs a judgment — proceed, revise, or stop — not just analysis.

## Examples of strong vs weak failure modes

**Weak:** "The team might not adopt the new process."
**Strong:** "Adoption metric is engineering-owned but depends on investor behavior. Engineering ships tooling; investors default to ChatGPT on the side; adoption stays flat; engineering's OKR suffers for a variable they don't control."

**Weak:** "The timeline might slip."
**Strong:** "Q2 baselines for four of seven KRs are currently 'TBD.' If they stay TBD past week 3, targets become fiction — the OKR review will have nothing to grade against and will silently get reframed as 'directional.'"

**Weak:** "Stakeholders might disagree."
**Strong:** "The plan assumes Hendrik cares about meetings-to-IC as the proxy, but this was never confirmed. If he actually cares about term sheets or IRR, the entire reporting layer is aimed at the wrong audience."
