"""Reproduce the range calculation from a publicly saved Fortune 2025 page.
Usage: python docs/fortune_ranges.py path/to/fortune2025.html
No authentication, scraping bypass, or full dataset redistribution.
"""
import json
import re
import sys
from pathlib import Path

html = Path(sys.argv[1]).read_text(encoding="utf-8-sig")
match = re.search(r'<script[^>]*id="__NEXT_DATA__"[^>]*>(.*?)</script>', html, re.S)
if not match:
    raise SystemExit("Public table data not found; page structure may have changed.")
rows = {}
def walk(value):
    if isinstance(value, dict):
        if isinstance(value.get("data"), dict) and "Employees" in value["data"]:
            rank = value.get("rank")
            if isinstance(rank, int) and 1 <= rank <= 500:
                rows[value["name"]] = value["data"]
        for child in value.values():
            walk(child)
    elif isinstance(value, list):
        for child in value:
            walk(child)
walk(json.loads(match.group(1)))
if len(rows) != 500:
    raise SystemExit(f"Expected 500 unique companies; found {len(rows)}. Inspect source.")
result = {"year": 2025, "count": len(rows), "ranges": {}}
for field in ["Employees", "Market Value ($M)"]:
    observations = []
    for name, row in rows.items():
        raw = str(row.get(field, "")).replace("$", "").replace(",", "").strip()
        try:
            observations.append((float(raw), name))
        except ValueError:
            pass  # Missing values are not zero.
    result["ranges"][field] = {"min": min(observations), "max": max(observations), "observed": len(observations)}
print(json.dumps(result, ensure_ascii=False, indent=2))
