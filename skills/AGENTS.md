# Regenerating Nim Skills from the Style Guide

This document describes how to regenerate the skills in this directory from the source style guide chapters.

## Skill-to-Guide Mapping

Each skill corresponds to a specific set of guide chapters:

| Skill | Guide Source Files |
|-------|-------------------|
| `nim-code` | `src/formatting.md`, `src/formatting.style.md`, `src/formatting.naming.md`, `src/language.proc.md`, `src/language.result.md`, `src/language.vardecl.md`, `src/language.varinit.md`, `src/language.objconstr.md`, `src/language.memory.md`, `src/language.refobject.md`, `src/language.converters.md`, `src/language.finalizers.md`, `src/language.integers.md`, `src/language.binary.md`, `src/language.string.md`, `src/language.macros.md`, `src/language.inline.md`, `src/language.range.md`, `src/language.methods.md`, `src/language.proctypes.md`, `src/libraries.hex.md` |
| `nim-errors` | `src/errors.md`, `src/errors.result.md`, `src/errors.exceptions.md`, `src/errors.status.md`, `src/libraries.results.md` |
| `nim-interop` | `src/interop.md`, `src/interop.c.md`, `src/interop.go.md`, `src/interop.rust.md` |
| `nim-tooling` | `src/tooling.md`, `src/tooling.nim.md`, `src/tooling.compiler.md`, `src/tooling.build.md`, `src/tooling.deps.md`, `src/tooling.debugging.md`, `src/tooling.profiling.md`, `src/tooling.editors.md`, `src/tooling.tricks.md`, `src/formatting.md` |

## Skill File Format

Each skill is a single `SKILL.md` inside its own directory with this structure:

```markdown
---
name: <skill-name>
description: <one-line summary>
paths:
  - "<glob patterns that trigger this skill>"
---

# <Skill Name>

## When to Use

<one or two sentences on when to activate this skill>

## Judicious Application

<judgment notes — see below>

## <Section 1>
...

## <Section 2>
...
```

## Regeneration Process

### 1. Read the source chapters

Read all guide source files listed in the mapping table above. Read the full content — pros, cons, and practical notes sections all inform the skill content.

### 2. Extract actionable conventions, not just summaries

The guide is written as a discussion with pros/cons/rationale. Skills must be **imperative instructions** — what to do, what to avoid, with short examples.

Transform the guide's prose into:
- **Bolded directives** for strong recommendations ("Avoid `result`", "Prefer `func`")
- **Code examples** extracted directly from the guide's snippets
- **Named exceptions** for the "except for..." cases
- **Practical notes** collapsed into bullet points

### 3. Structure each skill

Every skill must have:
1. A `## When to Use` header
2. A `## Judicious Application` section
3. Thematic sections (e.g. `### Return Values`, `### Variable Declaration`)
4. Code examples where the guide provides them
5. An `## Avoid` section for features to skip
6. An `## Verification` section for commands (nim-code skill only)

### 4. Include the judicious application principle

Every skill must include a section noting that these rules are defaults, not absolute mandates. Add this block right after the "When to Use" section:

```markdown
## Judicious Application

These rules are strong defaults, not absolute mandates. Apply them with judgment:

- If a rule produces compiler errors requiring complex workarounds, do not follow it. Write the more readable code instead.
- If following a rule significantly hurts readability, prefer readability.
- If a rule conflicts with the specific requirements of a function or module, the local context wins.
- If a deviation is necessary, add a brief comment explaining why the rule was bent.
```

### 5. Deduplicate cross-cutting concerns

Some topics appear in multiple skills. Deduplicate:
- **Formatting** (nph, 2-space indent, naming conventions) appears in both nim-code and nim-tooling. Put the **coding conventions** (indent, naming, line length) in nim-code. Put the **tooling** (how to run nph, CI config, editor setup) in nim-tooling.
- **Callbacks/proc types** appears in nim-code (annotation pragmas) and nim-interop (callbacks across FFI boundaries). Keep FFI-specific callback patterns in nim-interop, general proc-type annotation in nim-code.

### 6. Write the SKILL.md

Create (or overwrite) `skills/<name>/SKILL.md` with the generated content. Follow the exact frontmatter format. Use `*` for bullet points. Use ` ```nim ` for code blocks.

### 7. Validate

- The skill file parses as valid markdown.
- No sections reference guide-specific prose like "this section discusses" — the skill stands alone.
- All code examples compile conceptually (follow Nim syntax).
- The `paths` glob patterns are broad enough to cover the skill's domain.

## Updating Existing Skills

When a guide chapter changes:
1. Read the changed chapter.
2. Find the affected skill by consulting the mapping table.
3. Read the current `SKILL.md` for that skill.
4. Update only the sections affected by the change.
5. Check that cross-cutting concerns still align with the sibling skill.

## Adding New Skills

If a new topical area emerges that needs its own skill:
1. Determine which guide chapters feed into it.
2. Add the mapping entry to the table above.
3. Create the directory: `skills/<new-name>/`
4. Create `SKILL.md` following the format, including the judicious application section.
5. Update this mapping table.
