# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

courses-ia-generated is a collection of AI-assisted educational materials focused on teaching modern
software engineering paradigms.

Courses are **not** at the repository root: they live two levels down, grouped by subject family.
Each top-level `cursos-<familia>/` directory is a pure container — it has no README and no content of
its own — and each directory inside it is one course. A course may itself group a family of related
sub-courses in one more level of directories.

To find out which families and courses exist, list the directories; this file deliberately does not
enumerate them, because that inventory changes constantly.

Two top-level directories are **not** course families and follow different rules:

- **`propuestas-cursos/`** — the drafts workshop. Nothing here is a course yet; read its `README.md`
  before touching anything inside. The repo's editorial standards apply loosely here, and a proposal
  ends up promoted (moved into a `cursos-<familia>/` directory as a course of its own), absorbed into
  an existing course, or archived. Never link to a proposal from published course material.
- **`_oskar/`** — the author's personal scratch notes. Not course material; don't edit it unless
  asked, and don't apply editorial conventions to it.

A new course goes inside the family directory that matches its subject. If none fits, create a new
`cursos-<familia>/` directory rather than dropping the course at the root.

### Course Anatomy

A course directory holds the published material (lessons, appendices, structure documents), its
**README.md** with a brief overview of the course and its contents, and a **`prompts/` directory with
the machinery used to build it**. What lives in `prompts/` varies by course, but it generally
includes:

- The course's **lineamientos**: its style guide (`guia-de-estilo-y-convenciones.md`), its scope
  document, and any explicit divergence from this file's defaults.
- The **writing prompts** used to generate each lesson or appendix, split per block when a course has
  more than one track.
- **Templates and formats** for the recurring pieces of that course (chapter template, exercise or
  incident formats).
- Occasional **helper scripts** that check the course's integrity or conventions
  (e.g. `check-course.sh`).
- Throwaway material from the conversations that produced the course, prefixed `_desechable-`. It is
  historical record: don't cite it and don't keep it in sync.

Read a course's `prompts/` before writing or editing anything inside it. Older courses may keep these
documents at the course root instead; the role is the same.

A course that ships runnable code keeps it in a **`src/` directory** next to the lessons, in one of
two shapes: a subdirectory per lesson or appendix, named exactly like the document it belongs to
(`02-nombre/`, `a10-nombre/`), or a single project directory when the whole course builds one
artifact. Prose lives in the lesson; `src/` holds what the reader actually executes, and the two must
stay consistent.

## Editorial Standards

> **Precedence — the course's own guidance wins.** Everything in this section is the repository
> *default*. The lineamientos in a course's `prompts/` **override any rule below for that course** —
> whether they tighten it, loosen it, or replace it outright.

Two conditions keep that from turning into drift:

- **The override must be explicit.** The course guide names the default it is replacing and why, so
  the divergence is a documented decision. Silence means the default applies.
- **Order of authority:** (1) the course's own guide and lineamientos, (2) this file, (3) the
  course's already published documents.

The defaults follow, and they hold wherever a course has not said otherwise:

- **Language:** neutral Latin American Spanish, tuteo (no "vos", no "vosotros"), no peninsular terms
  like "ordenador" or "vale".
- **Source code is in English** (identifiers, APIs, comments inside code blocks). All narrative,
  exercise text and UI text is in Spanish.
- **Audience:** IT people — mostly developers with some software engineering background and at least
  one language — unless the course's README states otherwise.
- Lessons or phases with detailed explanations and **external references**: courses, YouTube
  tutorials, books, essays.
- **20–30 exercises per section** across difficulty levels, from very easy to mini-project. A course
  may narrow that range or replace the exercise apparatus with another assessment format, as long as
  it says so and says why.

### Tone

- **Semiformal and collegial** — senior engineer to senior engineer. Assumes the reader understands
  their origin paradigm; don't explain basics like indexes or transactions.
- **Honest about trade-offs** — every option wins somewhere and loses somewhere. Losses are stated
  with numbers, never glossed over.
- **Measured over narrative** — "X is better for Y" requires benchmark data, never anecdote.
- Moderate emoji: one per major section, the occasional 😉 to defuse.

### Content Philosophy (The Core Principle)

> "Teach models of access, not products. Measure with a consistent harness against real competitors.
> Close every course with an honest verdict: *when NOT to use what you just learned.*"

Every course answers one central question — "what **access model** does my domain have?" — because
the answer is what determines which technology family is appropriate.

### Recurring Content Structures

- 🪞 **"Tu instinto [del paradigma de origen] dice… y esta vez se equivoca"** — recalibrate the
  reader's intuition; honor their prior knowledge while showing where it breaks down
- 🩻 **"Esto sí funciona igual"** — what carries over from the origin paradigm unchanged
- ⚰️ **Anti-pattern autopsy** — a recurring misuse, with its cost in before/after numbers
- 📖 **Translation dictionary** — map concepts in *both* directions (origin → new model, and back)
- ⚖️ **Honest verdict tree** — decision tree for when NOT to use what the course teaches
- 🧪 **Exercises** — graduated 🟢🟡🟠🔴, each with clear success criteria

### Markdown Conventions

- **Headings with emoji** — one per major section, sparingly in subsections
- **Prose before lists** — reason in paragraphs unless it's genuinely a parallel list of items or steps
- **Tables only for comparison or mapping** — decision matrices, translation tables, version maps;
  never for narration
- **Callouts:** 📝 context note · 🧭 guiding principle · 🧠 mental model · ⚠️ pitfall · 💡 design insight

## Common Editorial Tasks

### Creating a New Course

1. Pick the `cursos-<familia>/` directory that matches the subject (create one if none fits), and
   inside it create the course directory and its `prompts/` directory. A course that is still an
   idea starts in `propuestas-cursos/` instead, and moves here when it gets promoted.
2. **Start with the style guide** (`prompts/guia-de-estilo-y-convenciones.md`), derived from a sibling
   course's guide and tailored to the new content. It is where any divergence from the defaults above
   gets declared.
3. Write the scope and structure document (`0-ESTRUCTURA-CURSO.md`) **before** any lesson.
4. Write the chapter template and the per-lesson prompts, then the lessons.
5. Default lesson shape: setup → concepts → anti-patterns → translation → exercises → honest verdict.

### Editing Existing Content

- **Check consistency** against the course's own style guide (tone, terminology, translation dictionary).
- **Verify every "better than" claim** against `BENCHMARKS.md`; add the benchmark if it's missing.
- **Anti-patterns need before/after numbers**, not just description.
- **Translation dictionaries map both directions.**
- Update the course's insight document (e.g. `INSTINTOS.md`) when you find a new recurring insight.

### Adding Benchmarks

Benchmarks live in `BENCHMARKS.md` in the course directory and run through that course's consistent
harness. Each one states a **clear hypothesis** ("Redis handles 50k concurrent connections at
sub-millisecond latency"), its **test conditions** (hardware, concurrency, data size), its
**results**, and a **verdict** phrased as guidance. Always test every competitor the course mentions,
not just the primary product.

### Adding Exercises

- 🟢 Foundational — "follow the example exactly"
- 🟡 Apply the pattern to a new domain; some generalization required
- 🟠 Combine several patterns; mild debugging or design thinking
- 🔴 Open-ended or adversarial ("this anti-pattern will tank your app — measure the cost")

Every exercise needs **clear success criteria** (not "build a thing", but "your query returns in
<Xms" or "your schema enforces this constraint"), starter code or setup when needed, and a reference
solution or rubric.

## File Naming Conventions

Every file follows the same shape: `<prefix>-<number>-<topic>`, lowercase, hyphenated, zero-padded.

- **Lessons / phases** — `00-name.md`, `01-name.md`, …
- **Appendices** — `a01-topic.md`, `a02-topic.md`, … (older courses may use `A1-topic.md`; don't mix
  the two styles inside one course)
- **Structure and roadmap documents** — `0-ESTRUCTURA-CURSO.md`, `0-FASES.md` (zero prefix, caps)
- **Master guides** — `<COURSE>-GUIA-ESTILO.md`, `INSTINTOS.md`, `BENCHMARKS.md`
- **Optional tracks** — a course with an optional track sharing the same directory prefixes its files
  with a short track token: phases `beNN-name.md`, appendices `bea-NN-name.md`. The prefix keeps the
  blocks sorted and separated without subdirectories. Everything the track needs of its own carries
  the same suffix — its incident notebook, its templates, its prompts
  (`prompts/prompts-backend-fase.md`) — as **new files, never additions to the base track's**, so a
  base-track session never drags in context it doesn't need. Its git tags live in their own
  `be-fase-<slug>` namespace, keeping `git tag -l 'fase-*'` a clean index of the base track.
  > 🧭 These names are **repo-wide, not per-course**. Where a local variant would rhyme better with a
  > course's other files, the shared name still wins, and the course's style guide records the
  > trade-off explicitly.

## Git Workflow

- **Commit messages** reference the course and topic (e.g. "ruta-nosql: Add MongoDB benchmarks
  against Couchbase").
- **One commit per lesson or significant edit**, not per paragraph.
- **Content lock:** once a course is published, breaking changes (renamed lessons, restructured
  chapters) should be rare. Plan the structure carefully before creating lessons.

## When You're Unsure

1. **Tone or style?** → the course's own style guide in `prompts/`. It overrides this file.
2. **Course structure?** → `0-ESTRUCTURA-CURSO.md`; it's the source of truth.
3. **A claim?** → verify it in `BENCHMARKS.md`, or add the benchmark before stating it.
4. **Translation between paradigms?** → the course's translation dictionary (first lesson or style guide).
5. **What matters for students?** → they decide architecture, measure trade-offs, and defend
   decisions. Everything else is secondary.
