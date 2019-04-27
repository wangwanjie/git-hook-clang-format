# 说明
自动化完成 git 项目的 clang-format 的 git-hook 部署

# 步骤
终端命令行进入你的项目根目录，目录内执行 `setup-repo.sh` 脚本，即：

```bash
cd your_oc_project_dir
sh path_for_your_this_repo/setup-repo.sh
```

# 已有项目代码全量格式化
**修改 `format.py` 中需要操作的根目录，修改 `customer` 为你需要的根目录**

如果是已有项目，上一步操作完成后，执行一遍 `format.py` 脚本（依赖 `python 3`）

```bash
cd your_oc_project_dir
python3 format.py
```

如果未安装 `python3`，用 `homebrew` 安装一下：

```bash
~ via ⬢ v11.12.0
➜ brew install python@3
```

如果未安装 `homebrew`，以下命令安装：

```bash
~ via ⬢ v11.12.0
➜ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

# 正常修改提交代码

```bash
git add .
git commit -m "commit log"
```

如果提交代码时提示 `pre-commit` 没执行权限，请赋予其执行权限：

```bash
~ via ⬢ v11.12.0 took 2m 34s
➜ chmod +x .git/hooks/pre-commit
```

# 原理介绍
[自定义 Git - Git 钩子](https://git-scm.com/book/zh/v2/自定义-Git-Git-钩子)

[clang-format](https://hokein.github.io/2016/01/30/clang-format/)