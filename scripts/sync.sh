#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

exec python3 - "$REPO_ROOT" "$@" <<'PY'
import os
import re
import shutil
import sys
import time
from dataclasses import dataclass
from pathlib import Path

UNIVERSAL_KEYS = {
    "name",
    "description",
    "license",
    "metadata",
    "allowed-tools",
}
EXTENDED_KEYS = {
    "compatibility": "agentskills.io 标准字段（Antigravity/OpenCode/Claude 支持，但 Codex 官方 quick_validate.py 未收录）",
    "disable-model-invocation": "仅 OpenCode / Claude Code 识别；建议同时配置或了解目标端策略",
    "user-invocable": "Claude Code 扩展字段，其他 Agent 会忽略或由严格校验器告警",
    "context": "Claude Code 扩展字段（如 context: fork），其他 Agent 不支持",
    "hooks": "仅 Claude Code / Cline / Kiro 支持",
}
NAME_RE = re.compile(r"^[a-z0-9]+(?:-+[a-z0-9]+)*$")


@dataclass
class AgentAdapter:
    id: str
    name: str
    skills_dir: Path
    detect_paths: list[Path]
    always_enable: bool = False
    note: str = ""

    def is_installed(self) -> bool:
        if self.always_enable:
            return True
        return any(p.exists() for p in self.detect_paths)


@dataclass
class GlobalRuleTarget:
    id: str
    name: str
    dest_file: Path
    detect_paths: list[Path]

    def is_installed(self) -> bool:
        return any(p.exists() for p in self.detect_paths)


def build_adapters() -> list[AgentAdapter]:
    home = Path.home()
    xdg_config = Path(os.environ.get("XDG_CONFIG_HOME", "").strip() or (home / ".config"))
    claude_home = Path(os.environ.get("CLAUDE_CONFIG_DIR", "").strip() or (home / ".claude"))
    codex_home = Path(os.environ.get("CODEX_HOME", "").strip() or (home / ".codex"))

    return [
        AgentAdapter(
            id="universal",
            name="Agent Skills 通用标准 (Pi / Cline / Kimi / Warp / Zed 等)",
            skills_dir=home / ".agents" / "skills",
            detect_paths=[home / ".agents", home / ".pi" / "agent", home / ".cline", home / ".kimi"],
            always_enable=True,
        ),
        AgentAdapter(
            id="antigravity",
            name="Google Antigravity / AGY CLI",
            skills_dir=home / ".gemini" / "config" / "skills",
            detect_paths=[
                home / ".gemini" / "antigravity-cli",
                home / ".gemini" / "antigravity",
                xdg_config / "antigravity",
                home / ".gemini" / "config",
            ],
            note="Antigravity 全局仅扫描 ~/.gemini/config/skills，不读 ~/.agents/skills",
        ),
        AgentAdapter(
            id="gemini-cli",
            name="Gemini CLI",
            skills_dir=home / ".gemini" / "skills",
            detect_paths=[home / ".gemini"],
        ),
        AgentAdapter(
            id="opencode",
            name="OpenCode",
            skills_dir=xdg_config / "opencode" / "skills",
            detect_paths=[xdg_config / "opencode"],
        ),
        AgentAdapter(
            id="claude-code",
            name="Claude Code",
            skills_dir=claude_home / "skills",
            detect_paths=[claude_home],
        ),
        AgentAdapter(
            id="codex",
            name="OpenAI Codex",
            skills_dir=codex_home / "skills",
            detect_paths=[codex_home, Path("/etc/codex")],
        ),
        AgentAdapter(
            id="cursor",
            name="Cursor",
            skills_dir=home / ".cursor" / "skills",
            detect_paths=[home / ".cursor", xdg_config / "Cursor"],
        ),
        AgentAdapter(
            id="windsurf",
            name="Windsurf",
            skills_dir=home / ".codeium" / "windsurf" / "skills",
            detect_paths=[home / ".codeium" / "windsurf"],
        ),
        AgentAdapter(
            id="github-copilot",
            name="GitHub Copilot",
            skills_dir=home / ".copilot" / "skills",
            detect_paths=[home / ".copilot"],
        ),
        AgentAdapter(
            id="trae",
            name="Trae",
            skills_dir=home / ".trae" / "skills",
            detect_paths=[home / ".trae"],
        ),
        AgentAdapter(
            id="trae-cn",
            name="Trae CN",
            skills_dir=home / ".trae-cn" / "skills",
            detect_paths=[home / ".trae-cn"],
        ),
        AgentAdapter(
            id="qoder",
            name="Qoder",
            skills_dir=home / ".qoder" / "skills",
            detect_paths=[home / ".qoder"],
        ),
        AgentAdapter(
            id="qoder-cn",
            name="Qoder CN",
            skills_dir=home / ".qoder-cn" / "skills",
            detect_paths=[home / ".qoder-cn"],
        ),
        AgentAdapter(
            id="junie",
            name="JetBrains Junie",
            skills_dir=home / ".junie" / "skills",
            detect_paths=[home / ".junie"],
        ),
        AgentAdapter(
            id="roo",
            name="Roo Code",
            skills_dir=home / ".roo" / "skills",
            detect_paths=[home / ".roo"],
        ),
        AgentAdapter(
            id="kilo",
            name="Kilo Code",
            skills_dir=home / ".kilo" / "skills",
            detect_paths=[home / ".kilo", home / ".kilocode"],
        ),
        AgentAdapter(
            id="kiro-cli",
            name="Kiro CLI",
            skills_dir=home / ".kiro" / "skills",
            detect_paths=[home / ".kiro"],
        ),
        AgentAdapter(
            id="continue",
            name="Continue",
            skills_dir=home / ".continue" / "skills",
            detect_paths=[home / ".continue"],
        ),
        AgentAdapter(
            id="qwen-code",
            name="Qwen Code",
            skills_dir=home / ".qwen" / "skills",
            detect_paths=[home / ".qwen"],
        ),
        AgentAdapter(
            id="lingma",
            name="通义灵码 (Lingma)",
            skills_dir=home / ".lingma" / "skills",
            detect_paths=[home / ".lingma"],
        ),
        AgentAdapter(
            id="codebuddy",
            name="CodeBuddy",
            skills_dir=home / ".codebuddy" / "skills",
            detect_paths=[home / ".codebuddy"],
        ),
        AgentAdapter(
            id="goose",
            name="Goose",
            skills_dir=xdg_config / "goose" / "skills",
            detect_paths=[xdg_config / "goose"],
        ),
        AgentAdapter(
            id="amp",
            name="Amp / Replit",
            skills_dir=xdg_config / "agents" / "skills",
            detect_paths=[xdg_config / "amp"],
        ),
        AgentAdapter(
            id="openhands",
            name="OpenHands",
            skills_dir=home / ".openhands" / "skills",
            detect_paths=[home / ".openhands"],
        ),
        AgentAdapter(
            id="openclaw",
            name="OpenClaw",
            skills_dir=home / ".openclaw" / "skills",
            detect_paths=[home / ".openclaw", home / ".clawdbot", home / ".moltbot"],
        ),
        AgentAdapter(
            id="augment",
            name="Augment",
            skills_dir=home / ".augment" / "skills",
            detect_paths=[home / ".augment"],
        ),
        AgentAdapter(
            id="crush",
            name="Crush",
            skills_dir=xdg_config / "crush" / "skills",
            detect_paths=[xdg_config / "crush"],
        ),
    ]


def build_global_rule_targets() -> list[GlobalRuleTarget]:
    home = Path.home()
    xdg_config = Path(os.environ.get("XDG_CONFIG_HOME", "").strip() or (home / ".config"))
    claude_home = Path(os.environ.get("CLAUDE_CONFIG_DIR", "").strip() or (home / ".claude"))
    codex_home = Path(os.environ.get("CODEX_HOME", "").strip() or (home / ".codex"))

    return [
        GlobalRuleTarget(
            id="antigravity",
            name="Google Antigravity / AGY CLI",
            dest_file=home / ".gemini" / "config" / "rules" / "global.md",
            detect_paths=[
                home / ".gemini" / "antigravity-cli",
                home / ".gemini" / "antigravity",
                xdg_config / "antigravity",
                home / ".gemini" / "config",
            ],
        ),
        GlobalRuleTarget(
            id="gemini-cli",
            name="Gemini CLI",
            dest_file=home / ".gemini" / "GEMINI.md",
            detect_paths=[home / ".gemini"],
        ),
        GlobalRuleTarget(
            id="opencode",
            name="OpenCode",
            dest_file=xdg_config / "opencode" / "AGENTS.md",
            detect_paths=[xdg_config / "opencode"],
        ),
        GlobalRuleTarget(
            id="claude-code",
            name="Claude Code",
            dest_file=claude_home / "CLAUDE.md",
            detect_paths=[claude_home],
        ),
        GlobalRuleTarget(
            id="codex",
            name="OpenAI Codex",
            dest_file=codex_home / "AGENTS.md",
            detect_paths=[codex_home, Path("/etc/codex")],
        ),
        GlobalRuleTarget(
            id="pi",
            name="Pi",
            dest_file=home / ".pi" / "agent" / "AGENTS.md",
            detect_paths=[home / ".pi" / "agent"],
        ),
    ]


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
            if isinstance(prev, str) and prev not in ("|", ">", ">-", ""):
                data[current_key] = f"{prev} {raw_line.strip()}"
            elif prev in ("|", ">", ">-"):
                data[current_key] = raw_line.strip()
    return data, None


def validate_skill_dir(skill_dir: Path) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        return ["未找到 SKILL.md"], []

    content = skill_md.read_text(encoding="utf-8")
    fm, err = parse_frontmatter(content)
    if err or fm is None:
        return [err or "Frontmatter 解析失败"], []

    allowed_all = UNIVERSAL_KEYS | set(EXTENDED_KEYS.keys())
    unexpected = set(fm.keys()) - allowed_all
    if unexpected:
        errors.append(
            f"包含未知的 frontmatter 字段: {', '.join(sorted(unexpected))} "
            f"(跨端通用字段: {', '.join(sorted(UNIVERSAL_KEYS))})"
        )

    for ext_key in sorted(set(fm.keys()) & set(EXTENDED_KEYS.keys())):
        warnings.append(f"使用了扩展字段 '{ext_key}': {EXTENDED_KEYS[ext_key]}")

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
            errors.append("description 不应包含尖括号 (< 或 >)，否则 Codex 严格校验器会拒绝加载")
        if "__SKILL_" in desc or desc.startswith("[TODO:"):
            errors.append("description 仍包含未替换的模板占位符")

    if "__SKILL_NAME__" in content or "__SKILL_DESCRIPTION__" in content:
        errors.append("SKILL.md 正文仍包含未替换的模板占位符")

    return errors, warnings


def discover_skills(repo_root: Path) -> tuple[dict[str, tuple[Path, str]], list[str], list[str]]:
    skills: dict[str, tuple[Path, str]] = {}
    errors: list[str] = []
    warnings: list[str] = []

    public_root = repo_root / "skills"
    if public_root.is_dir():
        for category_dir in sorted(p for p in public_root.iterdir() if p.is_dir() and not p.name.startswith(".")):
            for skill_dir in sorted(p for p in category_dir.iterdir() if p.is_dir() and not p.name.startswith(".")):
                if not (skill_dir / "SKILL.md").exists():
                    continue
                rel = f"skills/{category_dir.name}/{skill_dir.name}"
                errs, warns = validate_skill_dir(skill_dir)
                errors.extend(f"[{rel}] {e}" for e in errs)
                warnings.extend(f"[{rel}] {w}" for w in warns)
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
            errs, warns = validate_skill_dir(skill_dir)
            errors.extend(f"[{rel}] {e}" for e in errs)
            warnings.extend(f"[{rel}] {w}" for w in warns)
            if skill_dir.name in skills:
                prev_rel = skills[skill_dir.name][1]
                errors.append(f"检测到重名 Skill ID '{skill_dir.name}': {prev_rel} 与 {rel}")
            else:
                skills[skill_dir.name] = (skill_dir.resolve(), rel)

    return skills, errors, warnings


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


def sync_global_rules(repo_root: Path, force_replace: bool) -> None:
    global_rule_src = (repo_root / "global" / "AGENTS.md").resolve()
    if not global_rule_src.is_file():
        return

    targets = [t for t in build_global_rule_targets() if t.is_installed()]
    if not targets:
        return

    backup_root: Path | None = None
    stamp = time.strftime("%Y%m%d-%H%M%S")

    print("\n📜 正在同步全局协作规则入口 (global/AGENTS.md)：")
    for target in targets:
        dest = target.dest_file
        dest.parent.mkdir(parents=True, exist_ok=True)

        if dest.is_symlink():
            if is_managed_link(dest, repo_root):
                if dest.resolve(strict=False) != global_rule_src:
                    dest.unlink()
                    dest.symlink_to(global_rule_src)
                print(f"  - [{target.id:<14}] {dest} -> 已挂载")
            elif force_replace:
                if backup_root is None:
                    backup_root = Path.home() / ".config-backups" / f"agent-global-rules-{stamp}"
                    backup_root.mkdir(parents=True, exist_ok=True)
                bak = backup_root / f"{target.id}-{dest.name}"
                shutil.copy2(dest, bak, follow_symlinks=False)
                dest.unlink()
                dest.symlink_to(global_rule_src)
                print(f"  - [{target.id:<14}] {dest} -> 已备份至 {bak} 并替换为软链接")
            else:
                print(f"  - [{target.id:<14}] ⚠️  {dest} 指向外部软链接，已保护跳过（可用 --force-global-rules 备份替换）")
        elif dest.exists():
            if force_replace:
                if backup_root is None:
                    backup_root = Path.home() / ".config-backups" / f"agent-global-rules-{stamp}"
                    backup_root.mkdir(parents=True, exist_ok=True)
                bak = backup_root / f"{target.id}-{dest.name}"
                shutil.move(str(dest), str(bak))
                dest.symlink_to(global_rule_src)
                print(f"  - [{target.id:<14}] {dest} -> 已备份原文件至 {bak} 并挂载软链接")
            else:
                print(f"  - [{target.id:<14}] ⚠️  {dest} 已存在非软链接文件，已保护跳过（可用 --force-global-rules 自动备份替换）")
        else:
            dest.symlink_to(global_rule_src)
            print(f"  - [{target.id:<14}] {dest} -> 已挂载")


def print_help() -> None:
    print(
        """用法:
  ./scripts/sync.sh [选项]

选项:
  (无参数)                校验全部 Skill，自动检测本机已安装的主流 Agent 并同步软链接与全局规则入口
  --validate-only         仅执行跨 Agent 兼容性与格式校验，不修改任何软链接
  --list-agents           列出内置支持的全部主流 Agent 适配器及本机检测状态
  --agents <id1,id2,...>  仅向指定的 Agent ID 同步 Skill
  --all-agents            强制向内置支持的全部主流 Agent 目录挂载 Skill
  --skip-global-rules     跳过 global/AGENTS.md 全局规则文件同步
  --force-global-rules    若目标全局规则文件已存在独立文件，自动备份至 ~/.config-backups/ 后替换为软链接
  -h, --help              显示此帮助信息"""
    )


def main() -> int:
    repo_root = Path(sys.argv[1]).resolve()
    raw_args = sys.argv[2:]

    validate_only = False
    list_agents = False
    all_agents = False
    skip_global_rules = False
    force_global_rules = False
    selected_ids: list[str] = []

    i = 0
    while i < len(raw_args):
        arg = raw_args[i]
        if arg in ("-h", "--help"):
            print_help()
            return 0
        elif arg == "--validate-only":
            validate_only = True
        elif arg == "--list-agents":
            list_agents = True
        elif arg == "--all-agents":
            all_agents = True
        elif arg == "--skip-global-rules":
            skip_global_rules = True
        elif arg == "--force-global-rules":
            force_global_rules = True
        elif arg == "--agents":
            if i + 1 >= len(raw_args):
                print("❌ --agents 需要提供逗号分隔的 Agent ID 列表", file=sys.stderr)
                return 1
            selected_ids.extend(x.strip() for x in raw_args[i + 1].split(",") if x.strip())
            i += 1
        elif arg.startswith("--agents="):
            selected_ids.extend(x.strip() for x in arg.split("=", 1)[1].split(",") if x.strip())
        else:
            print(f"❌ 未知参数: {arg}（使用 --help 查看用法）", file=sys.stderr)
            return 1
        i += 1

    adapters = build_adapters()
    adapter_map = {a.id: a for a in adapters}

    if list_agents:
        print(f"📋 内置支持 {len(adapters)} 个主流 Agent 生态适配器：\n")
        for a in adapters:
            installed = a.is_installed()
            badge = "🟢 已就绪" if installed else "⚪ 未检测"
            line = f"  {badge}  {a.id:<16} {a.name:<46} -> {a.skills_dir}"
            print(line)
            if a.note:
                print(f"{'':28}💡 {a.note}")
        return 0

    if selected_ids:
        unknown = [aid for aid in selected_ids if aid not in adapter_map]
        if unknown:
            print(
                f"❌ 未知的 Agent ID: {', '.join(unknown)}\n"
                f"   可用 ID: {', '.join(adapter_map.keys())}",
                file=sys.stderr,
            )
            return 1

    skills, errors, warnings = discover_skills(repo_root)
    if warnings:
        print("⚠️  跨 Agent 兼容提示：")
        for w in warnings:
            print(f"  - {w}")
        print()

    if errors:
        print("❌ Skill 校验未通过：", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1

    print(f"✅ 已通过跨端兼容校验，共发现 {len(skills)} 个 Skill：")
    for name, (_, rel) in sorted(skills.items()):
        scope = "🔒 本地私有" if rel.startswith("private/") else "🌐 公开仓库"
        print(f"  - {name:<24} ({scope}: {rel})")

    if validate_only:
        return 0

    if selected_ids:
        active_adapters = [adapter_map[aid] for aid in dict.fromkeys(selected_ids)]
    elif all_agents:
        active_adapters = adapters
    else:
        active_adapters = [a for a in adapters if a.is_installed()]

    skipped_count = len(adapters) - len(active_adapters)
    print(f"\n🔗 正在同步软链接到 {len(active_adapters)} 个目标目录（另有 {skipped_count} 个未安装的 Agent 自动跳过，可用 --list-agents 查看）：")

    for adapter in active_adapters:
        target_dir = adapter.skills_dir
        target_dir.mkdir(parents=True, exist_ok=True)
        linked = 0
        pruned = 0
        skipped: list[str] = []

        for entry in sorted(target_dir.iterdir()):
            if is_managed_link(entry, repo_root) and entry.name not in skills:
                entry.unlink()
                pruned += 1

        for name, (src_dir, _) in sorted(skills.items()):
            dest = target_dir / name
            if dest.is_symlink():
                if is_managed_link(dest, repo_root):
                    if dest.resolve(strict=False) != src_dir:
                        dest.unlink()
                        dest.symlink_to(src_dir)
                    linked += 1
                else:
                    skipped.append(f"{name} (指向外部软链接，已保护跳过)")
            elif dest.exists():
                skipped.append(f"{name} (已存在同名非软链接目录，已保护跳过)")
            else:
                dest.symlink_to(src_dir)
                linked += 1

        summary = f"  - [{adapter.id:<14}] {adapter.name:<44} -> {target_dir} (挂载 {linked}"
        if pruned:
            summary += f"，清理 {pruned}"
        summary += ")"
        print(summary)
        for s in skipped:
            print(f"    ⚠️  {s}")

    if not skip_global_rules and not selected_ids:
        sync_global_rules(repo_root, force_global_rules)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
PY
