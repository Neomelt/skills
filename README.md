# skills

[![skills.sh](https://skills.sh/b/Neomelt/skills)](https://skills.sh/Neomelt/skills)
[![Specification](https://img.shields.io/badge/spec-agentskills.io-black)](https://agentskills.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

个人跨场景 Agent Skills 仓库，用来持续沉淀在**工程开发、课程科研与日常生活**中验证过的工作流、排障经验与协作方法论。

设计目标只有两个：
1. **经验不随单次对话归零**：把真正踩过的坑、跑通的链路和个人偏好固化成可复用的 `SKILL.md`，让后续任务直接站在前一次的结论上起步。
2. **一次沉淀，全端互通**：严格遵循 [agentskills.io](https://agentskills.io) 开放规范，同时兼容本机 **OpenCode**、**Claude Code** 与 **Codex**，并支持跨设备通过 `skills` CLI 按需拉取。

---

## 目录与技能索引

| 分类 | Skill | 用途 |
|---|---|---|
| `meta/` | [`distill-skill`](skills/meta/distill-skill/) | 经验提炼与归档元技能：把刚跑通的方案、排障记录或方法论提炼为标准 Skill，自动完成脱敏检查、索引联动与多端同步 |
| `work/` | *持续沉淀中* | 软件工程、嵌入式 / Rust / Python / Web 开发规范、排障流程与自动化工具链 |
| `study/` | *持续沉淀中* | 课程复习、论文精读、概念拆解、实验复现与学术写作 |
| `life/` | *持续沉淀中* | 个人规划、阅读笔记、音乐制作与日常效率工作流 |

> **本地私有技能分流（`private/`）**：本仓库为公开仓库。若某项个人技能包含不便公开的内网地址或私人上下文，可直接放入本地 `private/<skill-name>/`（已由 `.gitignore` 忽略），运行 `./scripts/sync.sh` 同样会自动挂载到本机各 Agent，但不会进入 Git 历史。

---

## 快速上手

### 1. 本机多 Agent 实时接入（推荐开发/主力机使用）

克隆仓库后运行同步脚本，会自动校验所有 `SKILL.md` 并通过符号链接挂载到 `~/.agents/skills`（OpenCode / 通用规范）、`~/.claude/skills`（Claude Code）与 `~/.codex/skills`（Codex），后续修改即时生效：

```bash
git clone git@github.com:Neomelt/skills.git ~/skills
cd ~/skills
./scripts/sync.sh
```

仅执行格式与重名校验（不改软链接）：

```bash
./scripts/sync.sh --validate-only
```

### 2. 跨设备快速安装（基于 `skills` CLI）

在其他机器上无需手动维护软链接，可直接通过 [skills CLI](https://github.com/vercel/skills) 安装：

```bash
# 全局安装全部公开技能
npx skills add Neomelt/skills -g

# 仅安装指定技能
npx skills add Neomelt/skills --skill distill-skill -g
```

---

## 日常如何沉淀新 Skill

### 方式 A：让 Agent 自动提炼（最常用）

在任意工作、学习或日常会话结束时，直接对 Agent 说：

```text
帮我把刚才这套做法提炼成 skill 收进 ~/skills
```

或显式点名调用 `@distill-skill`（OpenCode）/ `$distill-skill`（Codex）。Agent 会自动提取关键步骤与踩坑点、检查隐私脱敏、落位分类并同步软链接。

### 方式 B：命令行脚手架手动新建

```bash
cd ~/skills
./scripts/new-skill.sh work my-workflow "一句话说明做什么，以及何时触发"
# 编辑生成的 SKILL.md 后同步挂载
./scripts/sync.sh
```

---

## 生态参考与推荐外部 Skill 源

遇到通用需求（如 Office/PDF 文档处理、MCP 开发、工程门禁）时，可以先借力社区与官方成熟轮子，再把自己的个性化工作流沉淀进本仓库：

- **规范文档**：[agentskills.io](https://agentskills.io)（机器可读活索引：[`llms.txt`](https://agentskills.io/llms.txt)）
- **[`DBinK/dbk-skills`](https://github.com/DBinK/dbk-skills)**：人机权责边界、咨询防误改锁（`dbk-ask`）、Rust/Python 质量门禁与 Git Worktree / PR 闭环工作流（本仓库结构的重要参考灵感来源）
- **[`anthropics/skills`](https://github.com/anthropics/skills)**：Anthropic 官方技能集，含 `pdf`、`docx`、`pptx`、`xlsx`、`mcp-builder`、`frontend-design`、`webapp-testing` 等高质量参考实现
- **[`openai/skills`](https://github.com/openai/skills)**：OpenAI Codex 官方精选技能库
- **[`skills.sh`](https://skills.sh)**：社区公开技能检索排行与分发平台

安装外部单个优秀技能到全局（不会污染本仓库，本仓库的 `sync.sh` 会自动保护非本仓库管理的外部技能）：

```bash
npx skills add anthropics/skills --skill pdf -g
npx skills add DBinK/dbk-skills --skill dbk-ask -g
```
