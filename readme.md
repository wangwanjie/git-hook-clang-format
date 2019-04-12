# 说明
自动化完成 OC 项目的 clang-format 的 git-hook 部署

# 步骤


```bash
cd your_oc_project_dir
sh path_for_your_this_repo/setup-repo.sh
```

# 已有项目代码全量格式化
**修改 format.py 中需要操作的根目录，修改 `customer` 为你需要的根目录**

如果是已有项目，上一步操作完成后，执行一遍 format.py 脚本

```bash
cd your_oc_project_dir
python3 format.py
```

# 正常修改提交代码

```bash
git add .
git coommit -m commit log"
```

# 原理介绍
[自定义 Git - Git 钩子](https://git-scm.com/book/zh/v2/自定义-Git-Git-钩子)

[clang-format](https://hokein.github.io/2016/01/30/clang-format/)