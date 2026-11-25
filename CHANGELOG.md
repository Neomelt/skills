# Changelog

本仓库记录个人 Agent Skills 的新增与重要演进，格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。

## [0.1.0] - 2026-11-25

### Added

- 初始化个人多 Agent 互通技能仓库骨架（`skills/{meta,work,study,life}` + 本地 Git 忽略的 `private/`）。
- 新增 `distill-skill` 元技能：支持将工作、学习、生活中的实战经验提炼为标准 Skill，内置公开仓库隐私脱敏检查与多端同步流程。
- 新增 `scripts/sync.sh`（Frontmatter 校验 + OpenCode / Claude Code / Codex 软链接一键同步）与 `scripts/new-skill.sh` 脚手架脚本。
- 新增 `templates/SKILL.template.md` 标准模板与 `skills.sh.json` 分发分组配置。
