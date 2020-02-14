#!/bin/sh
# set -e 如果执行的命令返回值为非零，那么立刻退出
# set -u
# set -u 如果变量没有传入就会被当做是一个错误，Treat unset variables as an error when substituting.
# 因为本脚本第一个参数是可选的，所有有可能没有设置$1，要想避免报错，就不要设置 set -u
# "$@"  "$@" is an array-like construct of all positional parameters, {$1, $2, $3 ...}.
# echo "$@" 会打印所有变量从$1开始
# exec:
# exec: exec [-cl] [-a name] [command [arguments ...]] [redirection ...]
# 使用指定的命令替换掉 shell,参数会变成 command 的参数，如果没有指定 command,任何重定向会在现在的 shell 上生效.
# 就是使用exec 命令后 command 的进程会替换掉 shell 进程。这样就避免了，
# 没有 exec 时 command 起的进程作为 shell 的子进程，导致信号无法传递的问题.

# 详情使用命令：bash -c "help exec" 查看

set -e

# 执行注册命令，如果 kong 没有返回 200，该命令会返回非零，就会导致该脚本退出，从而关闭容器。
npm run register

if [ -z "$1" ]; then # 如果 $1 参数为空就输出错误。
	echo "npm run lack script name"
else
	exec npm run "$@"
fi
exec "$@"
