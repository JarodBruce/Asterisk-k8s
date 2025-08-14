# ベースイメージとしてDebian 11 (Bullseye) のスリム版を使用
FROM debian:bullseye-slim

# 環境変数を設定し、aptが対話的なプロンプトを表示しないようにする
ENV DEBIAN_FRONTEND=noninteractive

# 必要なパッケージのインストール
# - asterisk: Asterisk本体
# - gnupg, curl: Asteriskの公式リポジトリを追加するために必要
# - procps: psコマンドなど、デバッグに便利なツール
RUN apt-get update &&     apt-get install -y asterisk procps &&     apt-get clean &&     rm -rf /var/lib/apt/lists/*

# Asteriskの実行に必要なディレクトリを作成
RUN mkdir -p /var/run/asterisk /var/log/asterisk /var/lib/asterisk /var/spool/asterisk && \
    # 作成したディレクトリの所有者をasteriskユーザーに変更
    chown -R asterisk:asterisk /var/run/asterisk /var/log/asterisk /var/lib/asterisk /var/spool/asterisk

# デフォルトのポートを公開 (network_mode: host を使うため、ドキュメントとしての意味合いが強い)
EXPOSE 5060/udp
EXPOSE 10000-20000/udp

# コンテナ起動時に実行されるコマンド
# -f: フォアグラウンドで実行
# -U: 実行ユーザーを指定
# -G: 実行グループを指定
COPY ./entrypoint.sh /
COPY ./ntfy_status.sh /usr/local/bin/ntfy_status.sh
ENTRYPOINT ["/entrypoint.sh"]

RUN asterisk -vx "pjsip list endpoints"
