# Changelog

本仓库记录个人 Agent Skills 的新增与重要演进，格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [0.6.0] - 2026-11-25

### Changed

- `deep-reading` 升级至 `0.3.0`：新增人机边界与个人文风保护铁律——所有 AI 生成/整理的笔记在顶部 YAML 单独开一行标注 `by: "AI生成"`，严禁触碰不含该标记的用户亲笔手稿，`[!quote]` 区块要求 100% 零润色保留用户的真实口语与文风。

## [0.5.0] - 2026-11-25

### Changed

- `deep-reading` 升级至 `0.2.0`：
  - 目录升级为 `读书/<书名>/` 文件夹层级（支持按章节、高门槛简短随笔命题、纯日期三档命名，严禁章节档与随笔档同义复写）。
  - 确立“先碰撞深挖、再静默落盘”的深度准入红线，去除模板示例锚定词句，禁写浅层科普套话。
  - 采用 Obsidian 原生四色语义 Callout + 默认折叠（`-`）+ `==高亮==` 排版，并附带与个人博客配色对齐的 [`assets/editorial-reading.css`](skills/life/deep-reading/assets/editorial-reading.css) 样式片段。
  - 补充终端沙盒遮蔽 `~/Documents` 时优先使用 Agent 原生文件工具读写的踩坑记录。
- `distill-skill`（`0.3.1`）的 `references/agent-compatibility.md` 新增各客户端原生 `Auto` 模式沙盒与跨工作区目录白名单协同守则。

## [0.4.0] - 2026-11-25

### Added

- `skills/life/` 新增 [`deep-reading`](skills/life/deep-reading/SKILL.md) 深度共读与博客灵感捕手技能（支持思辨追问、原话质感保留及 Obsidian `读书/` 母本 + `思考/` 博客选题卡双层静默沉淀）。

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
