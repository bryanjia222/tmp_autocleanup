#!/bin/bash

# 定义目标目录，默认为当前目录
target_directory="${1:-.}"

# 获取当前脚本的名称
script_name="$(basename "$0")"

# 查找超过1周未修改的文件或目录，仅限于当前目录下的文件或目录，并排除以"keep."开头的文件和当前脚本
files_to_delete=$(find "$target_directory" -maxdepth 1 -mindepth 1 \( -type f -o -type d \) -mtime +7 ! -name 'keep.*' ! -name "$script_name" | sed 's|^\./||')

# 如果没有找到符合条件的文件或目录，输出信息并退出
if [ -z "$files_to_delete" ]; then
  echo "没有找到超过1周未修改的文件或目录。"
  exit 0
fi

# 显示找到的文件或目录列表，并使用less/more进行预览
# 使用其他颜色显示目录以区分
color_reset="\e[0m"
color_dir="\e[1;34m"

formatted_files_to_delete=$(echo "$files_to_delete" | while IFS= read -r line; do
  if [ -d "$line" ]; then
    echo -e "${color_dir}$line${color_reset}"
  else
    echo "$line"
  fi
done)

echo -e "以下是超过1周未修改的文件或目录：\n$formatted_files_to_delete" | less

# 要求用户确认删除
read -p "是否确认删除这些文件或目录？(y/n): " confirm

# 根据用户输入进行操作
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
  echo "$files_to_delete" | xargs -d '\n' rm -r
  echo "文件或目录已删除。"
else
  echo "操作已取消。"
fi
