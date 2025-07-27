---
layout: post
# author: "Epy Blog"
title: "Same Input, Different Output: How LLM Drift Silently Broke Our Production Pipeline"
tags:
  - LLMs
  - GPT
usemathjax:     true
more_updates_card: true
excerpt_separator: <!--more-->
---
A user asked our assistant:

> “List all customers who placed orders in the last 30 days.”

The backend used GPT to generate the SQL:

```sql
SELECT * FROM orders WHERE order_date >= '2024-04-01';
```

It worked.

The next day, the same prompt returned:

```sql
SELECT * FROM orders WHERE order_date >= '2024-04-01' AND status = 'shipped';
```

No warning. No error. Just a new condition the user never asked for.<!--more-->

The dashboard started showing fewer rows.
Nobody noticed — until someone downstream questioned why monthly revenue looked off.

It was the same input.
But GPT made a different decision.

This wasn’t a bug.
It was the model behaving as expected: **making plausible guesses** based on training, context, and randomness.

And unless your system is **explicitly engineered for consistency**, this kind of drift — silent, confident, invisible — will leak into production.



## **1. Inconsistent Q\&A Output Even With the Same Prompt**

Let’s say your assistant supports engineers with technical answers.

Here’s a prompt:

```text
What are the assumptions behind the incompressible Navier–Stokes equations?
```

Seems deterministic, right?

On first run, GPT responds:

* Newtonian fluid
* Constant viscosity
* Incompressibility
* Continuum hypothesis
* Isotropic stress tensor

But in a separate session, same model, same prompt:

* Newtonian fluid
* Thermodynamic equilibrium
* Laminar flow
* No body forces
* Smooth fields

What changed?

Nothing visible.
No prompt mutation. No context shift. Just **an ambiguous request**.

The word “assumptions” isn’t formally defined in GPT’s world. The model sees related words in its training corpus — consequences, constraints, flow regimes — and merges them.

Even at `temperature=0`, there's enough freedom in token ranking for subtle semantic drift.

In our systems, the same drift appeared in other factual queries:

* “List assumptions of linear elasticity” → sometimes gave small strain, sometimes missed isotropy
* “What is divergence theorem?” → sometimes returned surface integrals, sometimes flipped the directionality

Only after restructuring prompts like this:

```text
List exactly 5 **core assumptions** behind the **incompressible** Navier–Stokes equations.
Do not include derived consequences.
Each point must be under 15 words.
```

…did we achieve consistent response.

What stabilized it wasn’t magic — it was:

* **Explicit scope narrowing**
* **Format constraints**
* **Token space limitation**

In LLMs, open-ended prompts yield generative behavior — not database behavior. The more formal your request, the more reproducible the outcome.



## **2. Code Editing Often Rewrites More Than You Asked**

We had a function:

```python
def process_data():
    response = requests.post(url, json=payload)
    if response.status_code == 200:
        return response.json()
    return None
```

User prompt:

> “Add a logging line after the API call.”

In one session, GPT added:

```python
logging.info("POST request sent.")
```

But in another:

* It renamed `response` to `result`
* Changed the error return to `None, None`
* Removed an unrelated comment line

Even with temperature = 0, GPT doesn’t "insert" — it **regenerates**.

LLMs don’t think like patch editors. Unless you explicitly constrain their editing behavior, they reconstruct entire blocks, interpreting your instruction semantically instead of surgically.

This was dangerous for us in real pipelines.
One generation silently removed a retry block. Another disabled an exception handler.

We made 3 architectural changes:

* Extract only the function-level scope, not the full file
* Mark exact anchor points using inline comments like `# INSERT LOG HERE`
* Request output in diff format (only changed lines)

Once the prompt was transformed from:

```text
Add logging to this function.
```

…to:

```text
Only insert one line after `requests.post(...)`. Do not change anything else. Return only inserted lines.
```

…we achieved stable behavior across sessions.

And to protect against GPT still getting creative, we validated diffs using `difflib`, and flagged any token change outside marked scope.



## **3. Generated SQL is Unstable Without Output Normalization**

Auto-generating SQL is a common GPT use case.

A user prompt:

```text
Show me all orders from customer 12345 in the last 60 days.
```

We expect:

```sql
SELECT * FROM orders WHERE customer_id = 12345 AND order_date >= '2024-03-01';
```

But GPT sometimes gave:

* `BETWEEN '2024-03-01' AND CURRENT_DATE`
* Added `AND status = 'shipped'`
* Used `LIMIT 100`
* Reordered WHERE clauses

Each variation still ran. But:

* Some returned fewer records
* Others failed downstream joins
* A few broke test case expectations in CI

We traced this to model behavior:

* Inferring extra filters from similar queries in its training data
* Using date logic variations it learned from informal datasets
* Structuring clauses differently based on hidden positional biases

What worked consistently:

* Feeding GPT a **strict SQL contract template** with hardcoded table, column, and clause positions
* Predefining allowed logic insertions and constraints
* Parsing generated output via `sqlparse` and normalizing clause order
* Saving a **hash of every unique query output** and alerting on new ones

By reducing GPT’s job to filling in safe blanks — not generating full queries — and validating outputs post-generation, we made SQL predictable and auditable.

We also added semantic unit tests to check:

* Are all filters present?
* Is the customer ID unmodified?
* Are extra clauses (LIMIT, JOIN, GROUP BY) added without being asked?

This made the difference between a "chatty assistant" and a reliable code generation engine.



## **4. Chat Memory Causes Cross-Turn Leakage**

A session starts:

```text
Explain Galerkin projection in finite elements.
```

GPT correctly describes:

* Weighted residuals
* Test functions
* Integral formulation

A few turns later:

```text
Can this be used in nonlinear systems?
```

GPT starts referencing:

* Neural networks
* Variational autoencoders
* Auto-diff frameworks

None of which were mentioned.

This isn’t hallucination — it’s context blending.

In memory-enabled chat sessions, GPT integrates recent tokens to influence answer likelihood. Without scope boundaries, domain contamination creeps in.

In our knowledge assistant, this caused:

* Context leakage from earlier unrelated questions
* Irrelevant academic concepts being added
* Mixing of FEM and ML vocabularies

We restructured factual flows as:

* Stateless LLM calls with no prior turns
* Embedding-matched semantic retrieval (RAG) using FAISS
* Injected only 2-3 chunks of verified text into the prompt
* Instruction: *“Use only the provided context. Do not reference previous conversation unless explicitly instructed.”*

This gave us traceable, scope-bound answers, where every token had a source.



## **5. Logic Insertion Creeps In Uninvited**

A user asks:

```text
Generate code to read a CSV and call an API for each row.
```

GPT responds with:

* `try`/`except` blocks
* Retry logic with exponential backoff
* Hardcoded headers
* Logging configuration
* Progress bar via `tqdm`

The output is *correct*, but it includes business logic no one asked for.

If your system executes, validates, or audits GPT-generated code, these "enhancements" break alignment.

This was especially critical for us in compliance workflows. One generation added:

```python
verify=False
```

…to a `requests.post()` call to “fix” a certificate error it hallucinated.

We mitigated this by:

* Wrapping all GPT code generation in template scaffolds
* Annotating safe insertion zones via comments
* Asking for outputs without enhancements unless explicitly required
* Running all code through `black`, `flake8`, and a set of custom linters for unexpected imports or logic blocks

GPT’s job shifted from "write code" to "complete this pre-defined code frame, only inside marked blocks."

This eliminated drift without sacrificing the model’s utility.



## **Closing Thoughts**

Large language models are powerful — but power isn’t the problem.

**Behavioral consistency is**.

What we learned is simple: GPT isn’t unreliable — it’s unconstrained.

If you let it choose the structure, scope, and tone of the output, it will.
If you define the rails it must follow, it often complies.

Every inconsistency we experienced — from hallucinated filters to overwritten code — was a signal that we hadn’t designed the system boundary tightly enough.

In production, consistency is not an AI feature.
It’s a **system-level guarantee**.

And the way to get there isn’t better prompting.
It’s:

* Structured input contracts
* Canonicalized, testable output
* Strict model roles and scopes
* Downstream validators and drift monitors
* Retrieval-injected grounding when memory isn’t enough

You don’t need to fine-tune GPT.
You need to wrap it in guardrails.

Only then does it behave like a dependable part of your stack.

---
> **Note:**  
> This post was developed with structured human domain expertise, supported by AI for clarity and organization.  
> Despite careful construction, subtle errors or gaps may exist. If you spot anything unclear or have suggestions, please reach out via our members-only chat — your feedback helps us make this resource even better for everyone!

