#!/usr/bin/env python3
from pathlib import Path

from lupa import LuaRuntime


def main() -> None:
    lua = LuaRuntime()
    errors = []

    for path in sorted(Path(".").rglob("*.lua")):
        if "lib/anim8" in str(path) or "lib/bump" in str(path):
            continue

        source = path.read_text()
        try:
            lua.eval(f'(load)([[{source}]], "{path}")')
        except Exception as exc:  # noqa: BLE001
            errors.append(f"{path}: {exc}")

    if errors:
        print("Lua syntax check failed:")
        for error in errors:
            print(error)
        raise SystemExit(1)

    print("Lua syntax check passed.")


if __name__ == "__main__":
    main()
