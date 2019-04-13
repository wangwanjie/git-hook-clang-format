#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import os
import re


def findfile(startdir):
    fileList = []
    for dir_path, subdir_list, file_list in os.walk(startdir):

        # 过滤不相关目录
        if not(dir_path.find(".git") > -1 or dir_path.find(".gitee") > -1 or dir_path.find(".svn") > -1 or dir_path.endswith('lproj') or dir_path.endswith('xcassets')):
            for fname in file_list:
                if fname.lower().endswith(".h") or fname.lower().endswith(".m") or fname.lower().endswith(".c"):
                    full_path = os.path.join(dir_path, fname)
                    # plog(full_path)
                    fileList.append(full_path)
    return fileList


if __name__ == "__main__":
    file_list = findfile('./customer')
    for fname in file_list:

        fname = fname.replace('(', '\(', 1)
        fname = fname.replace(')', '\)', 1)
        print("格式化：" + fname)
        command = "clang-format " + fname + " -style=file -i"
        os.system(command)
