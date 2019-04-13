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
  # It's a symlink
  if [ -h "$pre_commit_file" ]; then
    pre_commit_file=$(readlink "$pre_commit_file")
    return 0
  fi

  if [ -d ".git" ]; then
    $(mkdir -p ".git/hooks");
  elif [ -e ".git" ]; then
    # grab the git dir from our .git file, listed as 'gitdir: blah/blah/foo'
    git_dir=$(grep gitdir .git | cut -d ' ' -f 2)
    pre_commit_file="$git_dir/hooks/pre-commit"

    # Even if our git dir is in an unusual place, we still need to create the hook directory
    # if it does not already exist.
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
export PATH=/usr/local/bin:$PATH
STAGE_FILES=$(git diff --cached --name-only --diff-filter=ACM -- '*.h' '*.m' '*.c')
if test ${#STAGE_FILES} -gt 0
then
    echo '开始依赖检查'

	which brew &> /dev/null
    if [[ "$?" == 1 ]]; then
        echo "没安装home brew，将安装"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    fi

    which clang-format &> /dev/null
    if [[ "$?" == 1 ]]; then
      echo "没安装clang-format，将安装"
	    brew install clang-format
    fi

    PASS=true

    for FILE in $STAGE_FILES
    do
      clang-format $FILE -style=file -i
      if [[ "$?" == 1 ]]; then
      PASS=false
    fi
  done

  if ! $PASS; then
      echo "clang-format 检查没通过！"
      exit 1
  else
      echo "clang-format 检查完毕"
  fi

else
    echo "没有文件需要检查"
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
  fi
}

function ensure_path_environment() {
  ENV_PATH='''PATH=/usr/local/bin:$PATH'''

  if grep -q $ENV_PATH ~/.bash_profile; then

    echo "homebrew 环境变量路径存在"
  else
    echo "homebrew 环境变量路径不存在，将添加"
    echo "$ENV_PATH" >> ~/.bash_profile
    source ~/.bash_profile
  fi
}

ensure_pre_commit_file_exists && ensure_pre_commit_file_is_executable && ensure_hook_is_installed && ensure_git_ignores_clang_format_file && symlink_clang_format && ensure_path_environment
