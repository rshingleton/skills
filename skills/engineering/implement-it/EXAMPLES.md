# Implement Skill — Examples

Self-contained examples for each workflow step. Replace placeholder values
(`{Widget}`, `{methodName}`, etc.) with your project's actual names.

---

## TDD Loop — Red → Green → Refactor

**Scenario:** Implement a `WidgetParser` that extracts a name from a string.

### Red — Write a failing test first

```python
# tests/test_widget_parser.py
from widget_parser import WidgetParser

def test_parse_name():
    parser = WidgetParser()
    result = parser.parse("NAME:gizmo")
    assert result.name == "gizmo"
```

Run: `pytest tests/test_widget_parser.py` → FAILS (`ModuleNotFoundError`)

### Green — Write minimal production code

```python
# widget_parser.py
class WidgetParser:
    def parse(self, raw: str):
        return ParseResult(name=raw.split(":")[1])

class ParseResult:
    def __init__(self, name: str):
        self.name = name
```

Run: `pytest tests/test_widget_parser.py` → PASSES

### Refactor — Clean up without changing behavior

```python
# widget_parser.py
from dataclasses import dataclass

@dataclass
class ParseResult:
    name: str

class WidgetParser:
    SEPARATOR = ":"

    def parse(self, raw: str) -> ParseResult:
        _, name = raw.split(self.SEPARATOR)
        return ParseResult(name=name.strip())
```

Run: `pytest` + `ruff check .` → all green

---

## Diagnosis Loop — Bug Fix

**Scenario:** `parse()` crashes on malformed input `"gizmo"` (no colon).

### Reproduce
```python
def test_parse_malformed():
    parser = WidgetParser()
    result = parser.parse("gizmo")
    assert result.name == "gizmo"
```
Run → `ValueError: not enough values to unpack`

### Minimize
```python
# Smallest input: any string without ":"
WidgetParser().parse("gizmo")
```

### Hypothesize
`str.split(":")` returns `["gizmo"]` — unpacking to two variables fails.

### Fix
```python
def parse(self, raw: str) -> ParseResult:
    parts = raw.split(self.SEPARATOR, maxsplit=1)
    name = parts[1].strip() if len(parts) > 1 else parts[0].strip()
    return ParseResult(name=name)
```

### Regression-test
```bash
pytest && ruff check .
```

---

## Pre-handoff — Standards self-check

Before signaling phase complete, verify (see [STANDARDS.md](STANDARDS.md) §3):

```
[ ] ai-prompt acceptance criteria met
[ ] No scope beyond ai-prompt / ADR
[ ] pytest + ruff check green
[ ] No secrets or .env in diff
```

Fix any failure before handoff.

---

## Handoff — mid-plan (more phases remain)

```
Phase 2 Complete.

Next: /implement-it on docs/planning/widget-parser/phase-3/ai-prompt.md
```

## Handoff — last implementation phase

```
Phase 3 Complete. All implementation phases done.

Next: /audit-it, then /verify-it

Self-check summary:
- WidgetParser supports NAME: and bare-name formats
- 12 tests passing (3 new)
- ruff check clean
```

Do not update ADR status or changelog — audit-it and verify-it handle that.
