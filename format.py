#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os
import re

# 在这里修改需要修成的源码顶级目录（不一定是项目根目录，比如 iOS 项目不想修改 Pods 目录， node 项目不想修改 node_modules 目录）
PROJECT_ROOT = './customer'

def findfile(startdir):
    fileList = []
    for dir_path, subdir_list, file_list in os.walk(startdir):

        # 可以在这里设置过滤不相关目录
        if not(dir_path.find(".git") > -1 or dir_path.find(".gitee") > -1 or dir_path.find(".svn") > -1 or dir_path.endswith('lproj') or dir_path.endswith('xcassets')):
            for fname in file_list:
                if fname.lower().endswith(".h") or fname.lower().endswith(".m") or fname.lower().endswith(".c"):
                    full_path = os.path.join(dir_path, fname)
                    fileList.append(full_path)
    return fileList


if __name__ == "__main__":
    file_list = findfile(PROJECT_ROOT)
    for fname in file_list:

        fname = fname.replace('(', '\(', 1)
        fname = fname.replace(')', '\)', 1)

        print("检查并修正代码格式：" + fname)
        command = "clang-format " + fname + " -style=file -i"
        os.system(command)

    print("\n恭喜！已修正 " + PROJECT_ROOT + " 目录下所有源码文件格式（过滤的除外）")
