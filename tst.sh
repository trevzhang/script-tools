#!/bin/sh

function usage(){
    echo "-h --help \n" \
         "  将10/13位时间戳或日期字符串转换为本地时间或13位时间戳 \n"\
         "  参数：时间戳（10/13位）或日期字符串（%Y-%m-%d 或 %Y-%m-%d %H:%M:%S） \n"\
         "  默认值：当前时间 \n"\
         "  e.g. tst 1709267405      => 2024-03-01 12:30:05 \n"\
         "       tst 1709267405000   => 2024-03-01 12:30:05 \n"\
         "       tst '2024-03-01 12:30:05' => 1709267405000 \n"
    exit 1
}

os_platform=`uname -s`
if [[ $# -le 0 ]]; then
    echo "默认按照当前时间取值"
    if [[ "${os_platform}" = "Darwin" ]];then
        if command -v gdate >/dev/null 2>&1; then
            echo $(gdate +%s%3N)
        else
            echo "提示：安装GNU coreutils以获取更精确的时间戳。使用'brew install coreutils'安装。"
            echo `date +%s`000
        fi
    elif [[ "${os_platform}" = "Linux" ]];then
        echo $(date +%s%3N)
    fi
else
    case $1 in
      -h|--help)
          usage
      ;;
      *)
          inputStr=${1}
          if [[ $inputStr =~ ^[0-9]{10}$ ]] || [[ $inputStr =~ ^[0-9]{13}$ ]]; then
                timestampStr=${inputStr}
                if [[ ${#timestampStr} -eq 13 ]];then
                  timestampStr=${timestampStr:0:10}
                fi
                echo "时间戳位:\t${timestampStr}"
                if [[ "${os_platform}" = "Darwin" ]];then
                  dateStr=`date -r${timestampStr} +"%Y-%m-%d %H:%M:%S"`
                elif [[ "${os_platform}" = "Linux" ]];then
                  dateStr=`date -d @${timestampStr} +"%Y-%m-%d %H:%M:%S"`
                fi
                echo "本地时间:\t${dateStr}"
            elif [[ $inputStr =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || [[ $inputStr =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] || [[ $inputStr =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{3}$ ]]; then
                # 如果输入只有日期部分，添加默认时间
                if [[ $inputStr =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                    inputStr="${inputStr} 00:00:00"
                fi
                # 移除可能存在的毫秒部分，因为date命令不支持直接解析毫秒
                inputStrWithoutMillis=${inputStr%.*}
                if [[ "${os_platform}" = "Darwin" ]];then
                    timestampStr=`date -j -f "%Y-%m-%d %H:%M:%S" "${inputStrWithoutMillis}" +"%s"`
                elif [[ "${os_platform}" = "Linux" ]];then
                    timestampStr=`date -d "${inputStrWithoutMillis}" +"%s"`
                fi
                # 如果原始输入包含毫秒，提取毫秒部分
                if [[ $inputStr =~ \.[0-9]{3}$ ]]; then
                    millis=${inputStr##*.}
                else
                    millis="000"
                fi
                echo "13位时间戳:\t${timestampStr}${millis}"
          else
                echo "请输入有效的10/13位数字时间戳或日期字符串（%Y-%m-%d 或 %Y-%m-%d %H:%M:%S）"
                exit 1
          fi
      ;;
    esac
fi
