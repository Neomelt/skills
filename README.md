# skills

[![skills.sh](https://skills.sh/b/Neomelt/skills)](https://skills.sh/Neomelt/skills)
[![Specification](https://img.shields.io/badge/spec-agentskills.io-black)](https://agentskills.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

个人跨场景 Agent Skills 仓库，用来持续沉淀在**工程开发、课程科研与日常生活**中验证过的工作流、排障经验与协作方法论。

设计目标只有两个：
1. **经验不随单次对话归零**：把真正踩过的坑、跑通的链路和个人偏好固化成可复用的 `SKILL.md`，让后续任务直接站在前一次的结论上起步。
2. **一次沉淀，全端互通**：严格遵循 [agentskills.io](https://agentskills.io) 开放规范与跨端最大公约数约束，自动检测并适配挂载 **Antigravity、Gemini CLI、OpenCode、Claude Code、Codex、Cursor、Windsurf、GitHub Copilot、Pi、Trae、Qoder、Junie** 等主流 Agent，同时统一维护各端轻量级全局规则入口（`global/AGENTS.md`）。

---

## 目录与技能索引

| 分类 | Skill | 用途 |
|---|---|---|
| `general/` | [`todo-board`](skills/general/todo-board/) | 个人看板任务跟踪：在较大任务动手前通过 `todo` CLI 查重认领或新建立项、同步进度与决策阻塞，并配合 `kanban-skip` 守门放行 |
| `meta/` | [`distill-skill`](skills/meta/distill-skill/) | 经验提炼与归档元技能：把刚跑通的方案、排障记录或方法论提炼为标准 Skill，自动完成脱敏检查、索引联动与全主流 Agent 同步 |
| `work/` | *持续沉淀中* | 软件工程、嵌入式 / Rust / Python / Web 开发规范、排障流程与自动化工具链 |
| `study/` | *持续沉淀中* | 课程复习、论文精读、概念拆解、实验复现与学术写作 |
| `life/` | [`deep-reading`](skills/life/deep-reading/) | 深度共读与博客灵感捕手：陪做书籍/议题思辨碰撞，并在对话中静默将用户的独到洞察与真问题归档至 Obsidian Vault（`读书/` 与 `思考/` 选题池） |

> **本地私有技能分流（`private/`）**：本仓库为公开仓库。若某项个人技能包含不便公开的内网地址或私人上下文，可直接放入本地 `private/<skill-name>/`（已由 `.gitignore` 忽略），运行 `./scripts/sync.sh` 同样会自动挂载到本机各 Agent，但不会进入 Git 历史。

---

## 已适配的主流 Agent 矩阵

`./scripts/sync.sh` 内置 27 个主流 Agent 适配器，运行时会自动检测本机已安装的客户端，同步挂载 **Skills 目录** 与 **全局规则入口（[`global/AGENTS.md`](global/AGENTS.md)）**：

| Agent / 生态 | 全局 Skills 挂载路径 | 全局规则挂载路径 |
|---|---|---|
| **Google Antigravity / AGY CLI** | `~/.gemini/config/skills/` | `~/.gemini/config/rules/global.md` |
| **Gemini CLI** | `~/.gemini/skills/` | `~/.gemini/GEMINI.md` |
| **OpenCode** | `~/.config/opencode/skills/` | `~/.config/opencode/AGENTS.md` |
| **Claude Code** | `~/.claude/skills/` | `~/.claude/CLAUDE.md` |
| **OpenAI Codex** | `~/.codex/skills/` | `~/.codex/AGENTS.md` |
| **Pi** | `~/.agents/skills/` | `~/.pi/agent/AGENTS.md` |
| **Universal 通用组** | `~/.agents/skills/` | 原生覆盖 **Cline、Kimi Code CLI、Warp、Zed、Droid** 等 |
| **AI IDE 与插件生态** | 各自全局 `skills/` 目录 | 自动检测支持 **Cursor、Windsurf、GitHub Copilot、Trae / Trae CN、Qoder / Qoder CN、JetBrains Junie、Roo Code、Kilo Code、Kiro CLI、Continue、Qwen Code、通义灵码、CodeBuddy、Goose、Amp、OpenHands、OpenClaw、Augment、Crush** |

完整跨端差异与编写规范详见 [`agent-compatibility.md`](skills/meta/distill-skill/references/agent-compatibility.md)。

---

## 快速上手

### 1. 本机多 Agent 实时接入（主力开发机推荐）

克隆仓库后运行同步脚本，会自动完成跨端格式校验、检测本机已安装的全部 Agent 并建立符号链接，后续修改即时生效：

```bash
git clone git@github.com:Neomelt/skills.git ~/skills
cd ~/skills
./scripts/sync.sh
```

常用管理参数：

```bash
./scripts/sync.sh --list-agents               # 查看 27 个主流 Agent 适配器的本机检测状态与路径
./scripts/sync.sh --force-global-rules        # 自动备份各客户端原有独立全局规则文件至 ~/.config-backups/ 并统一挂载为软链接
./scripts/sync.sh --agents antigravity,cursor # 仅向指定 Agent 挂载
./scripts/sync.sh --validate-only             # 仅执行跨端兼容性与重名校验，不改软链接
```

### 2. 跨设备快速安装（基于 `skills` CLI）

在其他机器上也可直接通过 [skills CLI](https://github.com/vercel/skills) 按需拉取：

```bash
# 全局安装全部公开技能（自动识别目标机器已安装的 Agent）
npx skills add Neomelt/skills -g

# 指定安装到特定客户端（如 Antigravity 或 Claude Code）或只装单个技能
npx skills add Neomelt/skills --agent antigravity -g
npx skills add Neomelt/skills --skill todo-board -g
```

---

## 日常如何沉淀新 Skill

### 方式 A：让 Agent 自动提炼（最常用）

在任意工作、学习或日常会话结束时，直接对当前使用的任意 Agent 说：

```text
帮我把刚才这套做法提炼成 skill 收进 ~/skills
```

或按客户端习惯显式点名（OpenCode `@distill-skill` / Claude Code `/distill-skill` / Codex `$distill-skill` / Antigravity 直接点名 `distill-skill`）。Agent 会自动提取关键步骤与踩坑点、检查隐私脱敏、落位分类并同步到本机全部已安装客户端。

### 方式 B：命令行脚手架手动新建

```bash
cd ~/skills
./scripts/new-skill.sh general my-workflow "一句话说明做什么，以及何时触发"
# 编辑生成的 SKILL.md 后同步挂载
./scripts/sync.sh
```

---

## 生态参考与推荐外部 Skill 源

遇到通用需求（如 Office/PDF 文档处理、MCP 开发、工程门禁）时，可以先借力社区与官方成熟轮子，再把自己的个性化工作流沉淀进本仓库：

- **规范文档**：[agentskills.io](https://agentskills.io)（机器可读活索引：[`llms.txt`](https://agentskills.io/llms.txt)）
- **[`DBinK/dbk-skills`](https://github.com/DBinK/dbk-skills)**：人机权责边界、咨询防误改锁（`dbk-ask`）、Rust/Python 质量门禁与 Git Worktree / PR 闭环工作流
- **[`anthropics/skills`](https://github.com/anthropics/skills)**：Anthropic 官方技能集，含 `pdf`、`docx`、`pptx`、`xlsx`、`mcp-builder`、`frontend-design`、`webapp-testing` 等参考实现
- **[`openai/skills`](https://github.com/openai/skills)**：OpenAI Codex 官方精选技能库
- **[`skills.sh`](https://skills.sh)**：社区公开技能检索排行与分发平台

安装外部单个优秀技能到全局（`sync.sh` 会自动保护非本仓库管理的外部技能不被覆盖或清理）：

```bash
npx skills add anthropics/skills --skill pdf -g
npx skills add DBinK/dbk-skills --skill dbk-ask -g
```
