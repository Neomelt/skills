# 官方与社区优秀 Skill 参考索引

在设计复杂技能或寻找成熟轮子时，可按需查阅以下权威规范与标杆仓库，避免闭门造车。

## 1. 格式规范与校验工具

- **Agent Skills 官方规范活索引**：`https://agentskills.io/llms.txt`
  - 格式规范：`https://agentskills.io/specification.md`
  - 编写最佳实践：`https://agentskills.io/skill-creation/best-practices.md`
  - 触发率优化（调优 `description`）：`https://agentskills.io/skill-creation/optimizing-descriptions.md`
- **校验命令**：
  - 本仓库内置多端兼容校验与挂载：`~/skills/scripts/sync.sh --validate-only`
  - 官方 CLI 校验：`uvx --from skills-ref agentskills validate ./skills/<分类>/<skill-name>`（注：PyPI 包名为 `skills-ref`，其提供的可执行命令为 `agentskills`）

## 2. 值得借鉴的标杆仓库

| 仓库 | 定位与亮点 | 代表性 Skill 参考 |
|---|---|---|
| [`anthropics/skills`](https://github.com/anthropics/skills) | Anthropic 官方示例与生产级文档技能库，展示了 `SKILL.md` + `scripts/` 处理复杂文件格式的工业级范式 | `docx`、`pdf`、`pptx`、`xlsx`、`mcp-builder`、`frontend-design`、`webapp-testing`、`doc-coauthoring` |
| [`openai/skills`](https://github.com/openai/skills) | OpenAI Codex 官方技能集合，指令克制精炼，强调渐进式披露与最小范围约束 | `skill-creator`、`openai-docs` |
| [`DBinK/dbk-skills`](https://github.com/DBinK/dbk-skills) | 个人工程安全与协作规则集标杆：明确人机权责边界、不可逆操作熔断、语言门禁与 PR 评审闭环 | `dbk-agent-rules`、`dbk-ask`、`dbk-skill-dev`、`dbk-rust-gates`、`dbk-python-style`、`dbk-git-worktree` |
| [`skills.sh`](https://skills.sh) | 社区通用 Agent Skills 索引与 CLI 分发平台 | 支持按热度检索并通过 `npx skills add <owner>/<repo> --skill <id> -g` 按需安装 |

## 3. 按需查阅远端标杆 Skill 的快捷命令

本机已配置 `gh` CLI，想借鉴某个公开仓库的具体写法时，无需整库克隆，可直接只读拉取对应 `SKILL.md`：

```bash
# 查看仓库技能目录树
gh api 'repos/<owner>/<repo>/git/trees/HEAD?recursive=1' --jq '.tree[] | select(.path | endswith("SKILL.md")) | .path'

# 直接查看某个标杆技能的正文
gh api repos/DBinK/dbk-skills/contents/skills/base/dbk-ask/SKILL.md -H "Accept: application/vnd.github.raw"
gh api repos/anthropics/skills/contents/skills/mcp-builder/SKILL.md -H "Accept: application/vnd.github.raw"
```
