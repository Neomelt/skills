# skills 仓库维护指南

本仓库是 Neomelt 的个人 Agent Skills 集合，遵循 [agentskills.io](https://agentskills.io) 规范，通过 `scripts/sync.sh` 自动检测并软链接同步到本机主流 Agent（Antigravity、Gemini CLI、OpenCode、Claude Code、Codex、Cursor、Windsurf、GitHub Copilot、Pi、Trae、Qoder、Junie、Roo Code 等 27 个生态适配器），同时统一维护各端轻量级全局规则入口 `global/AGENTS.md`，并兼容 `npx skills add Neomelt/skills -g` 跨设备分发。

## 动手前必读

1. **先加载元技能**：在本仓库新增、修改或迭代任何 Skill 前，先阅读 `skills/meta/distill-skill/SKILL.md`（及多端细节参考 `skills/meta/distill-skill/references/agent-compatibility.md`）并按其工作流执行。
2. **公开仓库隐私红线**：本仓库关联 **GitHub 公开仓库（`Neomelt/skills`）**。
   - 严禁将任何 API Key、Token、密码、私人服务器 IP/域名、学号/手机号或敏感个人信息写入受 Git 跟踪的文件。
   - 包含不便公开的个人环境细节的技能，一律放入 Git 已忽略的 `private/<skill-name>/`。

## 目录结构与约定

```text
~/skills/
├── skills/                  # 公开技能根目录（兼容 npx skills 与 skills.sh）
│   ├── general/             # 跨领域通用协作机制、个人看板与基础效率流
│   ├── work/                # 工程开发、排障调试与工具链工作流
│   ├── study/               # 课程学习、论文精读、概念拆解与实验复现
│   ├── life/                # 日常规划、阅读思考、音乐制作与生活流
│   └── meta/                # 元技能：经验提炼与仓库自维护
├── global/
│   └── AGENTS.md            # 本机各端全局规则唯一真源（极简路由指针，由 sync.sh 挂载至各客户端全局配置）
├── private/                 # 本地私有技能目录（.gitignore 忽略子目录，仅本机同步）
├── templates/
│   └── SKILL.template.md    # 新建技能模板（避开 SKILL.md 命名，防止被误识别加载）
├── scripts/
│   ├── new-skill.sh         # 一键生成新技能骨架
│   └── sync.sh              # 跨端兼容校验 + 27 个主流 Agent 软链接与全局规则同步
├── AGENTS.md                # 本仓库内开发维护规范唯一真源
├── CLAUDE.md                # -> AGENTS.md 软链接（适配 Claude Code）
├── GEMINI.md                # -> AGENTS.md 软链接（适配 Gemini CLI；Antigravity 按真实路径自动去重）
├── skills.sh.json           # skills.sh 分组展示配置
├── CHANGELOG.md             # 版本变更记录
└── README.md                # 仓库文档与索引
```

命名与跨端格式硬约束：
- Frontmatter 顶层统一使用跨端通用五字段：`name`、`description`、`license`、`metadata`、`allowed-tools`。
- Skill 目录名必须与 `name` 完全一致（仅限小写字母、数字和单连字符，`<=64` 字符，跨分类全局唯一）。
- `description` 是唯一自动触发依据：必须同时说明**做什么**和**何时触发**（`<=1024` 字符），且**不含 `<` 或 `>`**（保证 Codex 严格校验器通过）。

## 校验与联动检查

本仓库是纯文本工程，新增、改名、移动或删除任何公开 Skill 后，必须手动完成以下联动更新：

1. 更新 `README.md` 中的分类技能表。
2. 更新 `skills.sh.json` 对应分组的 `skills` 列表。
3. 按变更幅度更新 `SKILL.md` 的 `metadata.version` 与根目录 `CHANGELOG.md`。
4. 执行跨端校验与挂载同步：
   ```bash
   ./scripts/sync.sh
   ```
   可选用官方参考工具复检单个技能：
   ```bash
   uvx --from skills-ref agentskills validate ./skills/<分类>/<skill-name>
   ```

## Git 与提交规范

- **授权边界**：日常维护时只修改文件并运行 `./scripts/sync.sh` 验证；除非用户在当次对话中明确要求，不自动执行 `git commit` 或 `git push`。
- **Commit Message 规范**：统一使用英文 **Conventional Commits**，格式为 `<type>(<scope>): <imperative lowercase summary>`（首字母小写、祈使语气、结尾不加句号）：
  - `feat(general): add todo-board skill and unify global rules`
  - `feat(work): add rust-embedded-debug skill`
  - `fix(distill-skill): strip angle brackets from template descriptions`
  - `docs: refresh skill index and compatibility matrix`
