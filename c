#!/bin/bash

# 添加 lib/ 目录到暂存区
git add lib/

# 提交更改，使用 "." 作为提交信息
git commit -m "."

# 推送到远程分支 bitsdojo-version
git push origin bitsdojo-version