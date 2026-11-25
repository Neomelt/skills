#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 2 ]]; then
  cat <<'EOF'
用法:
  ./scripts/new-skill.sh <分类> <skill-name> ["一句话描述（做什么 + 何时用）"]

可选分类:
  meta     - 元技能：提炼经验、维护仓库、通用协作底座
  work     - 工作工程：开发规范、排障流程、工具链与部署
  study    - 学习科研：课程复习、论文精读、概念拆解、实验复现
  life     - 日常生活：个人规划、阅读笔记、音乐制作、效率流
  private  - 本地私有：含个人隐私或内部地址，仅本机同步、Git 自动忽略不推远端

示例:
  ./scripts/new-skill.sh work rust-embedded-debug "排查 STM32/嵌入式 Rust 编译与烧录故障。当遇到 probe-rs、链接脚本或交叉编译报错时使用。"
EOF
  exit 1
fi

CATEGORY="$1"
SKILL_NAME="$2"
DESCRIPTION="${3:-在此填写该技能具体解决什么问题，以及用户提到哪些场景或关键词时应该触发它。}"

case "$CATEGORY" in
  meta|work|study|life)
    TARGET_DIR="$REPO_ROOT/skills/$CATEGORY/$SKILL_NAME"
    ;;
  private)
    TARGET_DIR="$REPO_ROOT/private/$SKILL_NAME"
    ;;
  *)
    echo "❌ 不支持的分类 '$CATEGORY'，可选值: meta | work | study | life | private" >&2
    exit 1
    ;;
esac

if [[ ! "$SKILL_NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || [[ ${#SKILL_NAME} -gt 64 ]]; then
  echo "❌ Skill 名称 '$SKILL_NAME' 不合法：只能包含小写字母、数字和单个连字符（≤64 字符），且不能以连字符开头或结尾。" >&2
  exit 1
fi

# 检查跨分类重名
if find "$REPO_ROOT/skills" "$REPO_ROOT/private" -mindepth 1 -maxdepth 2 -type d -name "$SKILL_NAME" 2>/dev/null | grep -q .; then
  echo "❌ 仓库内已存在同名 Skill '$SKILL_NAME'，请换一个唯一名称。" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

python3 - "$REPO_ROOT/templates/SKILL.template.md" "$TARGET_DIR/SKILL.md" "$SKILL_NAME" "$DESCRIPTION" <<'PY'
import sys
from pathlib import Path

tpl_path, out_path, name, desc = sys.argv[1:5]
desc_clean = desc.replace("<", "（").replace(">", "）").replace('"', '\\"')
content = Path(tpl_path).read_text(encoding="utf-8")
content = content.replace("__SKILL_NAME__", name)
content = content.replace("__SKILL_DESCRIPTION__", f'"{desc_clean}"')
Path(out_path).write_text(content, encoding="utf-8")
PY

echo "✅ 已创建 Skill 骨架: $TARGET_DIR/SKILL.md"
echo "👉 下一步："
echo "   1. 编辑 $TARGET_DIR/SKILL.md 填入真实步骤与踩坑记录"
if [[ "$CATEGORY" != "private" ]]; then
  echo "   2. 同步更新 README.md、skills.sh.json 与 CHANGELOG.md"
fi
echo "   3. 运行 ./scripts/sync.sh 校验并挂载到 OpenCode / Claude Code / Codex"
