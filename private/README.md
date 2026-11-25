# 本地私有技能目录（Git 已忽略）

本目录用于存放**包含个人隐私、内网地址、特定账号习惯或暂不打算公开**的本地 Skill。

- `.gitignore` 已忽略 `private/*/`，这里的任何子目录都**不会**被提交或推送到公开 GitHub 仓库。
- 运行 `../scripts/sync.sh` 时，本目录下符合规范的 `<skill-name>/SKILL.md` 会与公开技能一样，自动通过软链接挂载到 `~/.agents/skills`、`~/.claude/skills` 与 `~/.codex/skills`。
- 快速新建私有技能：
  ```bash
  ./scripts/new-skill.sh private <skill-name> "一句话描述"
  ```
