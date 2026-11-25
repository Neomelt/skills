---
name: distill-skill
description: 将实际工作、学习或生活中的解决方案、排障经验、复盘方法论提炼沉淀为标准 Agent Skill，归档到 ~/skills 个人技能仓库并自动适配同步到 Antigravity、Gemini CLI、OpenCode、Claude Code、Codex、Cursor 等本机主流 Agent。当用户要求把刚做完的事总结成 skill、沉淀工作流到技能库、或新增与迭代 ~/skills 中的个人技能时使用；仅调用其他现成技能完成普通任务时不使用。
license: MIT
metadata:
  author: Neomelt
  version: "0.3.1"
---

# Distill Skill（个人经验提炼与技能归档）

将真实任务中跑通的步骤、纠错结论、领域上下文提炼为高信噪比的标准 Skill，归入 `~/skills` 并自动同步到本机已安装的各主流 Agent。

## 核心原则

1. **只沉淀“非显而易见”的实战信息**：
   - 重点提取：本次真正奏效的操作序列、用户纠正过的误区（Gotchas）、特定工具参数/环境约束、固定输入输出模板。
   - 果断删减：大模型原本就会的通用背景解释、空泛套话（如“注意错误处理”“遵循最佳实践”）。判断标准：**“删掉这句话，下次 Agent 会不会做错或绕弯路？”** 不会就删掉。
2. **公开仓库隐私脱敏红线（最高优先级）**：
   - `~/skills` 绑定了 **GitHub 公开仓库（`Neomelt/skills`）**。
   - 归入 `skills/{general,work,study,life,meta}/` 前，**必须清查并脱敏**一切密钥、Token、密码、私人服务器 IP/内网域名、学号/手机号、私人账号路径等敏感信息，统一替换为环境变量或清晰占位符。
   - 若某个技能高度依赖不便公开的私人环境信息，直接将其归入 Git 自动忽略的 `~/skills/private/` 目录——照常享受本机全 Agent 软链接同步，但绝不进入版本库。
3. **全主流 Agent 最大公约数兼容**：
   - 对 `SKILL.md` 格式规范拿不准时，先拉取 `https://agentskills.io/llms.txt` 及 `specification.md` 核实；遇到特定客户端发现路径或语法差异时，查阅 [references/agent-compatibility.md](references/agent-compatibility.md)。
   - 硬约束：
     - Frontmatter 顶层仅使用跨端通用五字段：`name`、`description`、`license`、`metadata`、`allowed-tools`（避免 `context: fork` 等单一客户端私有字段导致严格校验器报错）。
     - `name` 必须与目录名完全一致（仅小写字母、数字、单连字符，`<=64` 字符）。
     - `description` 必须同时写清**做什么**与**何时触发**（`<=1024` 字符），且**不含英文尖括号 `<` 或 `>`**（兼容 Codex 严格校验器）。
     - 正文保持客户端中立，不把 `@skill`、`/skill`、`$skill` 等单一客户端召唤语法写成唯一入口；内部文件统一用相对 `SKILL.md` 目录的相对路径引用。

## 提炼与入库工作流

- [ ] **1. 盘点现有技能与生态参考**
  - 先检查 `~/skills/skills/` 与 `~/skills/private/`，判断是**迭代更新已有技能**（优先把新踩的坑追加进既有技能的 `踩坑记录`），还是**新建独立技能**。
  - 若需参考官方或社区成熟写法，按需查阅 [references/ecosystem.md](references/ecosystem.md)。

- [ ] **2. 选定分类与命名**
  - 按用途落位目录：
    - `skills/general/`：跨领域通用协作规则、任务跟踪（如个人看板）、基础效率工具流
    - `skills/work/`：软件工程、嵌入式/Rust/Python/Web 开发、排障与工具链
    - `skills/study/`：课程学习、论文精读、概念拆解、实验复现与写作
    - `skills/life/`：日常规划、阅读笔记、音乐制作、生活效率流
    - `skills/meta/`：专门管理 Skill 本身生命周期与仓库维护的元技能
    - `private/`：含个人隐私或内部地址、仅限本机使用的私有技能
  - 可用脚手架快速生成骨架：
    ```bash
    ~/skills/scripts/new-skill.sh <分类> <skill-name> "<一句话描述>"
    ```
  - 若某项通用技能需要在每次新会话都做极简提示路由，可同步维护 `~/skills/global/AGENTS.md`（保持几行以内的轻量指针，详细规程留在 `SKILL.md` 内）。

- [ ] **3. 编写精炼的技能内容（渐进式披露）**
  - 主 `SKILL.md` 控制在精悍易读的篇幅（通常 200 行以内），直接给出核心流程、判断条件与踩坑记录。
  - 只有在确实能减少重复造轮子或隔离大段参考资料时，才按需建立子目录：
    - `scripts/`：每次都会重复手写的确定性脚本（写完实际跑通验证）。
    - `references/`：仅在特定分支/模式下才需要按需读取的详细规范或示例，并在 `SKILL.md` 中指明何时读取。
    - `assets/`：需要原样复制或填充的输出模板、静态资源。

- [ ] **4. 联动更新仓库索引（仅限公开技能）**
  - 若新增、改名或删除了 `skills/{general,work,study,life,meta}/` 下的公开技能，同步更新 `~/skills/` 根目录的：
    1. `README.md` 对应分类技能表
    2. `skills.sh.json` 对应分组的 `skills` 数组
    3. `CHANGELOG.md`（新增标 `0.1.0`，行为变更 bump `metadata.version` 的 minor，微调 bump patch）

- [ ] **5. 校验并同步到本机全部已安装 Agent**
  - 运行仓库同步脚本完成跨端格式校验与自动检测挂载：
    ```bash
    ~/skills/scripts/sync.sh
    ```
  - 如需运行官方参考校验器二次确认，可执行 `uvx --from skills-ref agentskills validate <skill目录路径>`。

- [ ] **6. 汇报结果并等待 Git 授权**
  - 向用户展示新建/修改的技能路径、核心要点及脱敏检查结果。
  - **未经用户在当次对话明确要求，不自动执行 `git commit` 或 `git push`**；获准提交时遵循 `AGENTS.md` 中的英文 Conventional Commits 规范。
