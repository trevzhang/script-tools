#!/bin/bash

# 函数定义

# ASCII转Unicode
ascii_to_unicode() {
    echo -n "$1" | od -An -t x1 | tr -d ' \n' | sed 's/../\\u00&/g'
}

# Unicode转ASCII
unicode_to_ascii() {
    echo "$1" | sed 's/\\u//g' | xxd -r -p | iconv -f UTF-16BE -t ASCII
}

# Unicode转中文
unicode_to_chinese() {
    echo "$1" | sed 's/\\u//g' | xxd -r -p
}

# 中文转Unicode
chinese_to_unicode() {
    echo "$1" | xxd -p | sed 's/../\\u&/g'
}

# 中文转UTF-8
chinese_to_utf8() {
    echo "$1" | iconv -f UTF-8 -t UTF-8
}

# UTF-8转中文
utf8_to_chinese() {
    echo "$1" | iconv -f UTF-8 -t UTF-8
}

# UrlEncode编码
urlencode() {
    echo "$1" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g'
}

# UrlDecode解码
urldecode() {
    echo "$1" | sed 's/%/\\x/g' | xxd -r -p
}

# ASCII转NATIVE
ascii_to_native() {
    echo "$1"
}

# NATIVE转ASCII
native_to_ascii() {
    echo "$1"
}

# HEX编码
hex_encode() {
    echo "$1" | xxd -p
}

# HEX解码
hex_decode() {
    echo "$1" | xxd -r -p
}

# Base64编码
base64_encode() {
    echo "$1" | base64
}

# Base64解码
base64_decode() {
    echo "$1" | base64 --decode
}

# 主逻辑
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <operation> <string>"
    exit 1
fi

operation="$1"
input="$2"

case "$operation" in
    "ascii_to_unicode") result=$(ascii_to_unicode "$input") ;;
    "unicode_to_ascii") result=$(unicode_to_ascii "$input") ;;
    "unicode_to_chinese") result=$(unicode_to_chinese "$input") ;;
    "chinese_to_unicode") result=$(chinese_to_unicode "$input") ;;
    "chinese_to_utf8") result=$(chinese_to_utf8 "$input") ;;
    "utf8_to_chinese") result=$(utf8_to_chinese "$input") ;;
    "urlencode") result=$(urlencode "$input") ;;
    "urldecode") result=$(urldecode "$input") ;;
    "ascii_to_native") result=$(ascii_to_native "$input") ;;
    "native_to_ascii") result=$(native_to_ascii "$input") ;;
    "hex_encode") result=$(hex_encode "$input") ;;
    "hex_decode") result=$(hex_decode "$input") ;;
    "base64_encode") result=$(base64_encode "$input") ;;
    "base64_decode") result=$(base64_decode "$input") ;;
    *) echo "Unsupported operation: $operation" >&2; exit 1 ;;
esac

echo "$result" | pbcopy
echo "Result: $result (copied to clipboard)"