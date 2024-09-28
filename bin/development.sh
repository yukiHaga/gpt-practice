#!/bin/sh

# set -eを追加することで、シェルスクリプト内でエラーが発生した時に、
# プログラムが終了する
# uオプションは、未定義の変数が使用された場合にエラーを出すように設定します。つまり、未定義の変数を使おうとするとスクリプトが中断されます。
set -eu

cd $APP_HOME

bundle i

if [ -e ./tmp/pids/server.pid ]; then
  rm ./tmp/pids/server.pid
fi

bundle exec rails s -b 0.0.0.0
# bundle exec rails s
