#!/bin/bash

# 初始化变量
release_branch=""
merge_option="--no-ff"  # 默认使用 --no-ff

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --ff)
            merge_option="--ff"
            shift
            ;;
        --no-ff)
            merge_option="--no-ff"
            shift
            ;;
        *)
            release_branch=$1
            shift
            ;;
    esac
done

# 如果没有提供目标分支，则提示用户输入
if [ -z "$release_branch" ]; then
    read -p "请输入目标分支名称: " release_branch
fi

# 获取当前分支名称
current_branch=$(git rev-parse --abbrev-ref HEAD)

# 显示操作信息
echo "当前分支: $current_branch"
echo "目标分支: $release_branch"
echo "合并选项: $merge_option"
echo "开始执行合并操作..."

# 保存当前工作区的修改，包括未跟踪的文件
git stash push --include-untracked

# 切换到目标分支
git checkout $release_branch

# 拉取最新的远程分支更新
git pull

# 合并当前分支到目标分支
git merge $current_branch $merge_option

# 推送合并后的目标分支到远程仓库
git push

# 切换回原来的分支
git checkout $current_branch

# 恢复之前保存的工作区修改
git stash pop

echo "操作完成！"
