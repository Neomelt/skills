#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

exec python3 - "$REPO_ROOT" "$@" <<'PY'
import os
import re
import sys
from pathlib import Path

ALLOWED_KEYS = {
    "name",
    "description",
    "license",
    "compatibility",
    "metadata",
    "allowed-tools",
}
NAME_RE = re.compile(r"^[a-z0-9]+(?:-+[a-z0-9]+)*$")


def parse_frontmatter(text: str) -> tuple[dict | None, str | None]:
    if not text.startswith("---\n"):
        return None, "缺少开头的 YAML frontmatter (---)"
    match = re.match(r"^---\n(.*?)\n---(?:\n|$)", text, re.DOTALL)
    if not match:
        return None, "YAML frontmatter 未正常闭合 (---)"
    block = match.group(1)

    try:
        import yaml  # type: ignore

        data = yaml.safe_load(block)
        if not isinstance(data, dict):
            return None, "Frontmatter 必须是键值字典"
        return data, None
    except ImportError:
        pass
    except Exception as exc:
        return None, f"YAML 解析失败: {exc}"

    # Zero-dependency fallback parser for simple top-level YAML keys
    data: dict[str, object] = {}
    current_key: str | None = None
    for raw_line in block.splitlines():
        if not raw_line.strip() or raw_line.lstrip().startswith("#"):
            continue
        if not raw_line.startswith((" ", "\t")) and ":" in raw_line:
            k, v = raw_line.split(":", 1)
            k = k.strip()
            v = v.strip().strip('"').strip("'")
            data[k] = v
            current_key = k
        elif current_key and raw_line.startswith((" ", "\t")):
            prev = data.get(current_key, "")
            if isinstance(prev, str) and prev not in ("|", ">", ""):
                data[current_key] = f"{prev} {raw_line.strip()}"
            elif prev in ("|", ">"):
                data[current_key] = raw_line.strip()
    return data, None


def validate_skill_dir(skill_dir: Path) -> list[str]:
    errors: list[str] = []
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        return ["未找到 SKILL.md"]

    content = skill_md.read_text(encoding="utf-8")
    fm, err = parse_frontmatter(content)
    if err or fm is None:
        return [err or "Frontmatter 解析失败"]

    unexpected = set(fm.keys()) - ALLOWED_KEYS
    if unexpected:
        errors.append(
            f"包含未定义的 frontmatter 字段: {', '.join(sorted(unexpected))} "
            f"(允许: {', '.join(sorted(ALLOWED_KEYS))})"
        )

    name = str(fm.get("name", "")).strip()
    if not name:
        errors.append("缺少必填字段 'name'")
    else:
        if "--" in name or not NAME_RE.match(name):
            errors.append(
                f"name '{name}' 必须仅含小写字母、数字和单个连字符，且不能以连字符开头或结尾"
            )
        if len(name) > 64:
            errors.append(f"name 长度 ({len(name)}) 超过 64 字符上限")
        if name != skill_dir.name:
            errors.append(f"name '{name}' 必须与目录名 '{skill_dir.name}' 完全一致")

    desc = str(fm.get("description", "")).strip()
    if not desc:
        errors.append("缺少必填字段 'description'")
    else:
        if len(desc) > 1024:
            errors.append(f"description 长度 ({len(desc)}) 超过 1024 字符上限")
        if "<" in desc or ">" in desc:
            errors.append("description 不建议包含尖括号 (< 或 >)，否则 Codex 校验器会拒绝加载")
        if "__SKILL_" in desc or desc.startswith("[TODO:"):
            errors.append("description 仍包含未替换的模板占位符")

    if "__SKILL_NAME__" in content or "__SKILL_DESCRIPTION__" in content:
        errors.append("SKILL.md 正文仍包含未替换的模板占位符")

    return errors


def discover_skills(repo_root: Path) -> tuple[dict[str, tuple[Path, str]], list[str]]:
    skills: dict[str, tuple[Path, str]] = {}
    errors: list[str] = []

    public_root = repo_root / "skills"
    if public_root.is_dir():
        for category_dir in sorted(p for p in public_root.iterdir() if p.is_dir() and not p.name.startswith(".")):
            for skill_dir in sorted(p for p in category_dir.iterdir() if p.is_dir() and not p.name.startswith(".")):
                if not (skill_dir / "SKILL.md").exists():
                    continue
                rel = f"skills/{category_dir.name}/{skill_dir.name}"
                for e in validate_skill_dir(skill_dir):
                    errors.append(f"[{rel}] {e}")
                if skill_dir.name in skills:
                    prev_rel = skills[skill_dir.name][1]
                    errors.append(f"检测到重名 Skill ID '{skill_dir.name}': {prev_rel} 与 {rel}")
                else:
                    skills[skill_dir.name] = (skill_dir.resolve(), rel)

    private_root = repo_root / "private"
    if private_root.is_dir():
        for skill_dir in sorted(p for p in private_root.iterdir() if p.is_dir() and not p.name.startswith(".")):
            if not (skill_dir / "SKILL.md").exists():
                continue
            rel = f"private/{skill_dir.name}"
            for e in validate_skill_dir(skill_dir):
                errors.append(f"[{rel}] {e}")
            if skill_dir.name in skills:
                prev_rel = skills[skill_dir.name][1]
                errors.append(f"检测到重名 Skill ID '{skill_dir.name}': {prev_rel} 与 {rel}")
            else:
                skills[skill_dir.name] = (skill_dir.resolve(), rel)

    return skills, errors


def is_managed_link(link_path: Path, repo_root: Path) -> bool:
    if not link_path.is_symlink():
        return False
    raw_target = os.readlink(link_path)
    abs_target = (link_path.parent / raw_target).resolve(strict=False)
    try:
        abs_target.relative_to(repo_root.resolve())
        return True
    except ValueError:
        return False


def main() -> int:
    repo_root = Path(sys.argv[1]).resolve()
    args = set(sys.argv[2:])
    validate_only = "--validate-only" in args

    skills, errors = discover_skills(repo_root)
    if errors:
        print("❌ Skill 校验未通过：", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"✅ 已通过校验，共发现 {len(skills)} 个 Skill：")
    for name, (_, rel) in sorted(skills.items()):
        scope = "🔒 本地私有" if rel.startswith("private/") else "🌐 公开仓库"
        print(f"  - {name:<24} ({scope}: {rel})")

    if validate_only:
        return 0

    home = Path.home()
    targets = [
        ("Agent Skills 通用 / OpenCode", home / ".agents" / "skills"),
        ("Claude Code", home / ".claude" / "skills"),
        ("Codex", home / ".codex" / "skills"),
    ]

    print("\n🔗 正在同步软链接到本机各 Agent 目录：")
    for label, target_dir in targets:
        target_dir.mkdir(parents=True, exist_ok=True)
        linked = 0
        pruned = 0
        skipped: list[str] = []

        # Prune stale symlinks pointing into this repo
        for entry in sorted(target_dir.iterdir()):
            if is_managed_link(entry, repo_root) and entry.name not in skills:
                entry.unlink()
                pruned += 1

        # Create/update symlinks for active skills
        for name, (src_dir, _) in sorted(skills.items()):
            dest = target_dir / name
            if dest.is_symlink():
                if is_managed_link(dest, repo_root):
                    if dest.resolve(strict=False) != src_dir:
                        dest.unlink()
                        dest.symlink_to(src_dir)
                    linked += 1
                else:
                    skipped.append(f"{name} (指向外部软链接，已跳过)")
            elif dest.exists():
                skipped.append(f"{name} (已存在同名非软链接目录，已保护跳过)")
            else:
                dest.symlink_to(src_dir)
                linked += 1

        summary = f"  - {label:<28} -> {target_dir} (已挂载 {linked} 个"
        if pruned:
            summary += f"，清理失效链接 {pruned} 个"
        summary += ")"
        print(summary)
        for s in skipped:
            print(f"    ⚠️  {s}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
PY
