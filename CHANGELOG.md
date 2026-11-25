# Changelog

本仓库记录个人 Agent Skills 的新增与重要演进，格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [0.3.0] - 2026-11-25

### Added

- 新增 `skills/general/` 跨场景通用分类，沉淀首个通用协作技能 [`todo-board`](skills/general/todo-board/SKILL.md)（个人看板任务登记、进度同步、阻塞汇报与 `kanban-skip` 守门放行）。
- 新增 [`global/AGENTS.md`](global/AGENTS.md) 作为跨客户端轻量全局规则唯一真源，并在 `scripts/sync.sh` 中支持自动挂载至 Antigravity、Gemini CLI、OpenCode、Claude Code、Codex 与 Pi 全局规则目录（支持 `--force-global-rules` 自动备份旧文件后迁移）。

### Changed

- `distill-skill` 升级至 `0.3.0`，同步支持 `general/` 分类路由与 `global/AGENTS.md` 维护说明。
- `scripts/new-skill.sh` 与 `skills.sh.json` 新增 `general` 分组支持。

## [0.2.0] - 2026-11-25

### Added

- `scripts/sync.sh` 扩展为 27 个主流 Agent 生态自动检测适配器（新增 Google Antigravity / AGY CLI `~/.gemini/config/skills`、Gemini CLI `~/.gemini/skills`、OpenCode `~/.config/opencode/skills`、Cursor、Windsurf、GitHub Copilot、Trae / Trae CN、Qoder / Qoder CN、JetBrains Junie、Roo / Kilo / Kiro / Continue、Qwen Code / 通义灵码 / CodeBuddy、Goose / Amp / OpenHands / OpenClaw 等），并支持 `--list-agents`、`--agents`、`--all-agents` 参数。
- 仓库根目录新增 `GEMINI.md -> AGENTS.md` 软链接，打通 Antigravity / Gemini CLI / Claude Code / Codex / OpenCode 规则文件入口。
- `distill-skill` 升级至 `0.2.0`：新增 [`references/agent-compatibility.md`](skills/meta/distill-skill/references/agent-compatibility.md) 主流客户端发现路径矩阵与跨端“最大公约数”编写规范。
- `AGENTS.md` 明确英文 Conventional Commits 提交信息规范。

## [0.1.0] - 2026-11-25

### Added

- 初始化个人多 Agent 互通技能仓库骨架（`skills/{meta,work,study,life}` + 本地 Git 忽略的 `private/`）。
- 新增 `distill-skill` 元技能：支持将工作、学习、生活中的实战经验提炼为标准 Skill，内置公开仓库隐私脱敏检查与多端同步流程。
- 新增 `scripts/sync.sh` 与 `scripts/new-skill.sh` 脚手架脚本。
- 新增 `templates/SKILL.template.md` 标准模板与 `skills.sh.json` 分发分组配置。
