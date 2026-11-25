# 主流 Agent 发现路径与跨端兼容指南

本仓库旨在做到**“写一次 `SKILL.md`，在所有主流编程与通用 Agent 中无缝运行”**。编写或排查多端兼容问题时查阅本表。

## 1. 主流 Agent 发现路径矩阵

`~/skills/scripts/sync.sh` 会自动检测本机已安装的客户端并建立软链接；项目级路径通常用于单项目独立配置。

| Agent / 生态 | 全局 Skills 路径（`sync.sh` 自动挂载目标） | 项目级 Skills 路径 | 项目级规则文件 | 关键差异与注意事项 |
|---|---|---|---|---|
| **Google Antigravity / AGY CLI** | `~/.gemini/config/skills/` | `.agents/skills/`（兼容 `.agent/skills/`） | `GEMINI.md`、`AGENTS.md` | **重点坑**：Antigravity IDE / `agy` CLI 全局**只扫 `~/.gemini/config/skills/`**，在工作区外不会读取 `~/.agents/skills/`；同路径规则文件会按真实路径自动去重 |
| **Gemini CLI** | `~/.gemini/skills/` | `.agents/skills/` | `GEMINI.md` | 全局路径在 `~/.gemini/skills/`，与 Antigravity 的 `~/.gemini/config/skills/` 不同，本机共存时两边都要挂 |
| **OpenCode** | `~/.config/opencode/skills/`（同时兼容读 `~/.agents/skills/`、`~/.claude/skills/`） | `.opencode/skills/`、`.agents/skills/` | `AGENTS.md` | 多来源出现同 ID 时按优先级覆盖去重；支持在提示词里用 `@skill-id` 显式点名 |
| **Claude Code** | `~/.claude/skills/` | `.claude/skills/` | `CLAUDE.md` | 支持 `/skill-id` 斜杠命令显式调用；其私有扩展 `context: fork`、`hooks` 在其他 Agent 中无效 |
| **OpenAI Codex** | `~/.codex/skills/` 与 `~/.agents/skills/` | `.agents/skills/` | `AGENTS.md` | 支持 `$skill-id` 显式调用；内置校验器最严格：**`description` 禁含 `<` 或 `>`**，且只认 `name`/`description`/`license`/`metadata`/`allowed-tools` 五个顶层字段 |
| **Cursor** | `~/.cursor/skills/` | `.agents/skills/`、`.cursor/skills/` | `AGENTS.md`、`.cursor/rules/` | 全局路径独立在 `~/.cursor/skills/` |
| **Windsurf** | `~/.codeium/windsurf/skills/` | `.windsurf/skills/` | `AGENTS.md`、`.windsurfrules` | 全局路径位于 `~/.codeium/windsurf/skills/` |
| **GitHub Copilot** | `~/.copilot/skills/` | `.agents/skills/` | `AGENTS.md`、`.github/copilot-instructions.md` | 全局路径位于 `~/.copilot/skills/` |
| **Pi / Cline / Kimi Code / Warp / Zed** | `~/.agents/skills/` | `.agents/skills/` | `AGENTS.md` | 直接共用 `~/.agents/skills/` 通用规范根目录 |
| **Trae / Trae CN** | `~/.trae/skills/`、`~/.trae-cn/skills/` | `.trae/skills/` | `AGENTS.md` | 国际版与国内版配置目录独立 |
| **Qoder / Qoder CN** | `~/.qoder/skills/`、`~/.qoder-cn/skills/` | `.qoder/skills/` | `AGENTS.md` | 国际版与国内版配置目录独立 |
| **JetBrains Junie** | `~/.junie/skills/` | `.junie/skills/` | `AGENTS.md` | 全局路径位于 `~/.junie/skills/` |
| **Roo Code / Kilo / Kiro / Continue** | `~/.roo/skills/`、`~/.kilo/skills/`、`~/.kiro/skills/`、`~/.continue/skills/` | 各自同名点目录或 `.agents/skills/` | `AGENTS.md` | Kiro 自定义 Agent 需在 `.kiro/agents/<name>.json` 的 `resources` 中声明 `skill://` |
| **Qwen Code / 通义灵码 / CodeBuddy** | `~/.qwen/skills/`、`~/.lingma/skills/`、`~/.codebuddy/skills/` | 各自同名点目录 | `AGENTS.md` | 均遵循标准 `SKILL.md` 目录结构 |

## 2. 跨 Agent 编写“最大公约数”守则

为了让同一个 Skill 在 Antigravity、OpenCode、Claude Code、Codex、Cursor 等客户端全部零报错运行，始终遵守以下五条规则：

1. **Frontmatter 只用全端通用五字段**：
   - 必填：`name`、`description`
   - 可选：`license`、`metadata`（键值均为字符串）、`allowed-tools`
   - 避免依赖单一客户端私有字段（如 Claude 的 `context: fork`）；确有客户端定制元数据需求时，优先收敛在 `metadata` 下。
2. **`description` 避开尖括号 `<` 和 `>`**：
   - Codex 校验器会将 `<` / `>` 视为非法字符直接报错；需要占位表达时改用中文书名号、圆括号或反引号（如 `` `skill-name` ``）。
3. **正文指令保持客户端中立**：
   - 不要把某种客户端专有的斜杠命令或召唤语法（如 `/plan`、`@xxx`、`$xxx`）写成唯一操作方式；应直接描述动作意图（如“先加载 `xxx` 技能”或“先给出分步计划待用户确认后再执行”）。
   - 引用同技能下的附加资源时，统一使用相对 `SKILL.md` 所在目录的相对路径（如 `[参考文档](references/foo.md)`、`scripts/run.py`），这是所有客户端唯一共同支持的路径解析基准。
4. **辅助子目录命名统一**：
   - 统一使用 `scripts/`（可执行脚本）、`references/`（按需加载的参考文档）、`assets/`（输出模板与静态资源），兼容所有主流客户端的渐进式披露机制。
5. **仓库级规则三端对齐**：
   - 仓库根目录以 `AGENTS.md` 为唯一真源，通过软链接提供 `CLAUDE.md -> AGENTS.md`（适配 Claude Code）与 `GEMINI.md -> AGENTS.md`（适配 Gemini CLI；Antigravity 会按真实文件路径自动去重，不会重复注入）。
