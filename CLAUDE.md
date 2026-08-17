# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

**courses-ia-generated** is a collection of AI-assisted educational course materials focused on teaching modern software engineering paradigms. The repository currently contains:

1. **ruta-no-sql** — A comprehensive NoSQL learning path that teaches **data access models** (not products). Each course covers one NoSQL family and measures it against real competitors using benchmarks in `scripts/vs.ts`.

2. **vue2-legacy-for-backend-devs** — A Vue 2 learning course for backend developers, including a MongoDB backend integration complement. Structured as a tronco (core) followed by optional routes (Quasar, Vuetify, Nuxt).

3. **maestria-ia** and **tutorial-rag** — Empty directories reserved for future course content.

## Content Structure and Navigation

### Ruta NoSQL Organization

The ruta-no-sql directory contains:

- **01-ruta-nosql.md** — Master index and roadmap of all planned NoSQL courses (9 families planned, with project names and product comparisons)
- **02-ruta-nosql-fundamentos.md** — Foundational concepts shared across all courses in the ruta
- **guia-estilo-base-ruta-nosql.md** — Editorial standards, tone, and conventions that govern all ruta content

Each individual course (when created) will include:
- `00-setup.md` — Installation and environment setup
- Numbered lesson files (01, 02, etc.)
- Appendices (A1, A2, etc.) for deep dives or reference material
- `ESTRUCTURA-CURSO.md` — Course roadmap and lesson dependencies
- `INSTINTOS.md` — Accumulated insights from the course
- `BENCHMARKS.md` — Measured comparisons against competing products

### Vue 2 Legacy Course Organization

The vue2-legacy-for-backend-devs directory contains:

- **01-vue2-legacy/** — Core tronco (12 lessons, F0–F11) covering Vue 2 fundamentals from setup through testing
- **02-complement-mongodb-backend/** — Complementary MongoDB backend integration lessons
- **0-ESTRUCTURA-CURSO.md** — Dependency graph and optional routes (Quasar Q, Vuetify VU, Nuxt NX)
- **0-plan-del-curso.md** — Detailed learning objectives and pacing

Lesson structure:
- F0–F11 form the mandatory core (tronco)
- After F11, learners choose one optional route (Q, VU, or NX)
- Each lesson builds on prior lessons; dependencies are hard (must complete F3 before F5)

## Editorial Standards

**All content in this repository follows the standards defined in `GUIA-ESTILO-BASE-RUTA-NOSQL.md`.** These are non-negotiable across courses:

### Language and Code

- **Source code is in English** (identifiers, APIs, comments in code blocks)
- **All narrative, explanations, exercise text, and UI text is in neutral Latin American Spanish with informal address (tuteo)**
- No regional Spanish (España) terms like "ordenador" or "vale"
- No "vos" (Argentine Spanish) or "vosotros" (Spain); use "tú" for second person

### Tone

- **Semiformal and collegial** — senior engineer to senior engineer
- Assumes the reader already understands their origin paradigm (usually relational); don't explain basic concepts like indexes or transactions
- **Honest about trade-offs** — every family wins somewhere and loses somewhere. Losses are stated with numbers, never glossed over.
- **Measured over narrative** — claims of "X is better for Y" require benchmark data in `BENCHMARKS.md`, never anecdotal evidence
- Moderate use of emoji (one per major section, occasional 😉 for desdramatization)

### Content Philosophy (The Core Principle)

> "Teach models of access, not products. Measure with a consistent harness against real competitors. Close every course with an honest verdict: *when NOT to use what you just learned.*"

Every course answers one central question: "What **access model** does my domain have?" The answer determines which family is appropriate.

### Recurring Content Structures

- 🪞 **"Tu instinto [from origin paradigm] dice… y esta vez se equivoca"** — Recalibrate reader intuition; honor their prior knowledge while showing where it breaks down
- 🩻 **"Esto sí funciona igual"** — Show what carries from the origin paradigm unchanged
- ⚰️ **Anti-pattern autopsy** — Identify a recurring misuse pattern (e.g., "using Redis as primary store") and show the cost with before/after numbers
- 📖 **Translation dictionary** — Map concepts from the origin paradigm to the new model (e.g., "a SQL VIEW becomes a $lookup aggregation stage")
- ⚖️ **Honest verdict tree** — Decision tree for when NOT to use this family
- 🧪 **Exercises** — 30–40 graduated by phase (🟢🟡🟠🔴) with clear success criteria

### Markdown Conventions

- **Headings with emoji** — one per major section (more sparingly in subsections)
- **Prose before lists** — reason in paragraphs unless it's genuinely a parallel list of items or steps
- **Tables only for comparison/mapping** — "When to use X vs Y", decision matrices, translation tables, version maps. Not for narration.
- **Callouts and notes:**
  - 📝 — Context note (history, why this pattern exists)
  - 🧭 — Key guiding principle or rule
  - 🧠 — Key insight or mental model
  - ⚠️ — Warning or common pitfall
  - 💡 — Design insight

## Common Editorial Tasks

### Creating a New Course

1. Create a new directory under the relevant category (e.g., `ruta-no-sql/CURSO-NAME/`)
2. Copy the template structure from an existing course (start with lesson numbering, appendices structure)
3. **Always start with `<COURSE-NAME>-GUIA-ESTILO.md`** — derived from `GUIA-ESTILO-BASE-RUTA-NOSQL.md`, changing only:
   - The **anti-pattern villain** specific to this course (e.g., "using MongoDB where relational makes more sense")
   - The **translation dictionary** from the origin paradigm to this model
   - Domain-specific vocabulary
   - Domain-specific callout types if needed
4. Write the course structure document (`0-ESTRUCTURA-CURSO.md`) **before** lessons
5. Follow the lesson template: setup → concepts → anti-patterns → translation → exercises → honest verdict

### Editing Existing Content

- **Check for consistency** with the course's own `<COURSE>-GUIA-ESTILO.md` (tone, terminology, translation dictionary)
- **Verify all "better than" claims** are backed by `BENCHMARKS.md` measurements, never anecdotal
- **Ensure anti-patterns** include before/after numbers, not just description
- **Update `INSTINTOS.md`** when you discover a new recurring insight
- **Translation dictionaries** should map both directions (origin → new model, new model → origin thinking)

### Adding Benchmarks

1. Benchmarks live in `BENCHMARKS.md` in the course directory
2. Use a consistent harness (e.g., `scripts/vs.ts` for ruta-no-sql courses)
3. Format: **clear hypothesis** ("Redis handles 50k concurrent connections at sub-millisecond latency"), **test conditions**, **results**, **verdict** ("use Redis when you need sub-ms latency and horizontal sharding of sessions")
4. Always test against all mentioned competitors, not just the primary product
5. Include hardware specs, concurrency levels, and data size in the benchmark description

### Adding Exercises

- 🟢 **Green exercises** — Foundational, "follow the example exactly"
- 🟡 **Yellow exercises** — Apply the pattern to a new domain, some generalization required
- 🟠 **Orange exercises** — Combine multiple patterns, mild debugging or design thinking
- 🔴 **Red exercises** — Open-ended or adversarial (e.g., "this anti-pattern will tank your app—measure the cost")

Every exercise needs:
- Clear success criteria (not "build a thing", but "your query should return in <Xms" or "your schema should enforce this constraint")
- Starter code or clear setup if needed
- Reference solution or detailed rubric

## File Naming Conventions

- **Course lesson files** — `00-name.md`, `01-name.md`, etc. (zero-padded, lowercase with hyphens)
- **Appendix files** — `A1-topic.md`, `A2-topic.md`, etc.
- **Structure/roadmap files** — `0-ESTRUCTURA-CURSO.md`, `0-plan-del-curso.md`, `0-FASES.md` (zero prefix, all caps with hyphens)
- **Master guides** — `<COURSE>-GUIA-ESTILO.md`, `INSTINTOS.md`, `BENCHMARKS.md` (all caps where appropriate)

## Git Workflow

- **Commit messages** should reference the course and topic (e.g., "ruta-nosql: Add MongoDB benchmarks against Couchbase")
- **One commit per lesson or significant edit**, not per paragraph
- **Content lock:** Once a course is published/distributed, breaking changes (renamed lessons, restructured chapters) should be rare. Plan structure carefully in `0-ESTRUCTURA-CURSO.md` before creating lessons.

## When You're Unsure

1. **About tone or style?** → Check the relevant `<COURSE>-GUIA-ESTILO.md` or `GUIA-ESTILO-BASE-RUTA-NOSQL.md`
2. **About course structure?** → Read `0-ESTRUCTURA-CURSO.md` first; it's the source of truth
3. **About a claim?** → Verify it in `BENCHMARKS.md` or add a benchmark before stating it
4. **About translation between paradigms?** → Consult the course's translation dictionary section (usually in the first lesson or in the style guide)
5. **About what's important for students?** → Default to: decides architecture, measures trade-offs, defends decisions. Everything else is secondary.
