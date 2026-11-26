---
name: git-workflow
description: 规范 Git 原子提交、Conventional Commits 提交信息、分支合并策略以及 git worktree 并行隔离开发流程。当用户要求提交代码、拆分 commit、同步分支、或为新任务/高风险重构开独立分支与 worktree 隔离环境时使用；普通只读查看 git 状态或日志不强制触发。
license: MIT
metadata:
  author: Neomelt
  version: "0.1.0"
---

# Git Workflow（原子提交、分支规范与 Worktree 隔离）

保持提交历史清晰可回溯、并行开发互不污染，同时严守不可逆操作的人工授权边界。

## 一、不可逆操作熔断（最高优先级）

- **未经用户在当次对话明确要求，禁止执行 `git add`、`git commit`、`git push`**。改动类任务默认只修改工作区文件，提交时机由用户拍板。
- **破坏性命令二次确认**：执行 `git reset --hard`、`git clean -fd`、`git push --force`、`git branch -D`、`git stash drop/clear` 前，必须先列出完整命令、受影响文件/提交与不可恢复风险，等用户明确确认后再执行。

## 二、原子提交与 Commit Message 规范

获准提交前，按以下顺序整理：

1. **审视变更与拆分为原子提交**：
   - 运行 `git status` 与 `git diff --stat` 检查全部改动。
   - 若工作区混杂了多组独立意图（例如修了一个 bug 又顺手改了文档或另一模块），按逻辑域分批 `git add` 拆成多个原子提交，每个提交只做一件事且能独立通过检查。
   - 核查绝不误提交 `.env`、密钥、大体积临时构建产物或调试垃圾。
2. **对齐提交信息风格**：
   - 先运行 `git log -n 10 --oneline` 观察当前仓库既有提交格式与语言，**优先遵循仓库既有约定**。
   - 仓库无明确约定时，默认采用英文祈使句 **Conventional Commits**：
     - 格式：`<type>(<scope>): <imperative lowercase summary>`（`scope` 可选，首字母小写，结尾不加句号）。
     - 常用 `type`：`feat`、`fix`、`refactor`、`perf`、`docs`、`test`、`chore`、`build`、`ci`。
     - 示例：`feat(fx): tear the agent card open like a card pack`、`fix(agent): never leave the slider stuck at the end`。
     - 改动较复杂时，用空行后的简短要点 body 说明“为什么这样改”，不流水账复述 diff。

## 三、分支同步策略

- **Merge 优先**：同步上游主分支或集成分支时，默认使用 `git merge`，不擅自 `rebase` 改写历史。
- **允许 Rebase 的例外**：用户明确要求 rebase、目标开源仓库强制线性历史，或仅整理自己尚未推送到远端的本地私人草稿提交。

## 四、Worktree 并行隔离开发

当需要并行处理两项任务、做高风险重构或多方案对比，不想污染当前分支工作区时启用：

### Step 0：先检测是否已在隔离环境

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
SUPER=$(git rev-parse --show-superproject-working-tree 2>/dev/null || true)
```

- 若 `GIT_DIR != GIT_COMMON` 且 `SUPER` 为空，说明当前**已经在一个 linked worktree 中**，直接汇报所在分支与路径，绝不套娃新建。

### Step 1：先提议分支名并确认

- 先查看 `git branch -a --format='%(refname:short)' | head -30` 对齐命名风格。
- 提议一个简短清晰的分支名（两段式 `<type>/<short-slug>`，末段控制在 2–3 个英文词以内，如 `feat/sidebar-nav`、`fix/slider-lock`），**等用户确认后再创建**。

### Step 2：按优先级创建（不与宿主工具打架）

1. **优先使用当前 Agent 宿主自带的原生 worktree 工具**（如 OpenCode 的 `worktree_create` / `session_move`、Claude Code 的 `EnterWorktree`），避免手动建出宿主无法感知和清理的幽灵目录。
2. **无原生工具时**：
   - 若本机已安装 Worktrunk（`command -v wt` 存在），优先用 `wt switch --create <branch>`（支持 CoW 快速复用依赖构建目录）。
   - 否则使用标准命令建到同级目录，避免污染当前仓库根目录：
     ```bash
     REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
     git worktree add "../${REPO_NAME}.worktrees/<short-slug>" -b "<branch>"
     ```
   - 若仓库已有项目内 `.worktrees/` 目录并沿用它，创建前**必须**执行 `git check-ignore -q .worktrees` 确认已被 `.gitignore` 忽略，防止把整个 worktree 误提交进主仓。

### Step 3：冷启动提示与基线验证

- 新 worktree 与主仓共享 `.git` 但不共享 `node_modules/`、`target/` 等构建产物，首次进入后按需安装依赖并跑一次基线测试，确认起点干净再开始改动；汇报新建目录路径与进入方式。
