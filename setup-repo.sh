#!/usr/bin/env bash

# @Author VanJay

set -ex
export CDPATH=""
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
pre_commit_file='.git/hooks/pre-commit';

function ensure_pre_commit_file_exists() {
  if [ -d ".git/hooks" ]; then
    $(rm -r .git/hooks)
  fi
  if [ -e "$pre_commit_file" ]; then
    return 0
  fi
  # 是个符号链接
  if [ -h "$pre_commit_file" ]; then
    pre_commit_file=$(readlink "$pre_commit_file")
    return 0
  fi

  if [ -d ".git" ]; then
    $(mkdir -p ".git/hooks");
  elif [ -e ".git" ]; then
    git_dir=$(grep gitdir .git | cut -d ' ' -f 2)
    pre_commit_file="$git_dir/hooks/pre-commit"

    $(mkdir -p "$git_dir/hooks");
  else
    $(mkdir -p ".git/hooks");
  fi

  $(touch $pre_commit_file)
}

function ensure_pre_commit_file_is_executable() {
  $(chmod +x "$pre_commit_file")
}

PRE_COMMIT_CONTENT='''
#!/usr/bin/env bash

# 设置环境变量
export PATH=$PATH:/usr/local/bin:/usr/local/sbin

# 设置 clang-format 文件
STYLE=$(git config --get hooks.clangformat.style)
if [ -n "${STYLE}" ] ; then
  STYLEARG="-style=${STYLE}"
else
  # 项目目录下寻找 .clang-format 文件
  STYLE=$(git rev-parse --show-toplevel)/.clang-format
  if [ -n "${STYLE}" ] ; then
    STYLEARG="-style=file"
  else
    STYLEARG=""
  fi
fi

format_file() {
  file="${1}"
  clang-format -i ${STYLEARG} $file
  git add $file
}

STAGE_FILES=$(git diff --cached --name-only --diff-filter=ACM -- *.h *.m *.c)
if test ${#STAGE_FILES} -gt 0
then
    echo "开始依赖检查"

	which brew &> /dev/null
    if [[ "$?" == 1 ]]; then
        echo -e "没安装homebrew! 将安装"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
        exit 1
    fi

    which clang-format &> /dev/null
    if [[ "$?" == 1 ]]; then
        echo "没安装clang-format! 将安装"
        brew install clang-format
        exit 1
    fi

    for FILE in $STAGE_FILES; do
      format_file "${FILE}"
    done

    echo "clang-format 代码格式修正完毕"

else
    echo "未检测到改动的源码文件（*.h，*.m，*.c），如使用命令提交，请确保执行了 git add 目标文件 "
fi

exit 0
'''

function ensure_hook_is_installed() {
  # check if this repo is referenced in the precommit hook already
  repo_path=$(git rev-parse --show-toplevel)
  if ! grep -q "$repo_path" "$pre_commit_file"; then
    echo "#!/usr/bin/env bash" >> $pre_commit_file
    echo "$PRE_COMMIT_CONTENT" >> $pre_commit_file
  fi
}

function ensure_git_ignores_clang_format_file() {
  grep -q ".clang-format" ".gitignore"
  if [ $? -gt 0 ]; then
    echo ".clang-format" >> ".gitignore"
  fi
}

function symlink_clang_format() {
  if [ ! -f ".clang-format" ]; then
    $(ln -sf "$DIR/.clang-format" ".clang-format")
  else
    echo "项目目录已有 .clang-format，将不创建符号链接"
  fi
}

function ensure_path_environment() {
  ENV_PATH='''PATH=$PATH:/usr/local/bin:/usr/local/sbin'''

  if grep -q $ENV_PATH ~/.bash_profile; then
    echo "homebrew 环境变量路径存在"
  else
    echo "homebrew 环境变量路径不存在，将添加"
    echo "$ENV_PATH" >> ~/.bash_profile
    source ~/.bash_profile
  fi
}

ensure_pre_commit_file_exists && ensure_pre_commit_file_is_executable && ensure_hook_is_installed && ensure_git_ignores_clang_format_file && symlink_clang_format && ensure_path_environment
