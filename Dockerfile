# ベースイメージとしてDebian 11 (Bullseye) のスリム版を使用
FROM debian:bullseye-slim

# 環境変数を設定し、aptが対話的なプロンプトを表示しないようにする
ENV DEBIAN_FRONTEND=noninteractive

# 必要なパッケージのインストール
# - asterisk: Asterisk本体
# - gnupg, curl: Asteriskの公式リポジトリを追加するために必要
# - procps: psコマンドなど、デバッグに便利なツール
RUN apt-get update && \
    apt-get install -y gnupg curl procps && \
    \
    # Asteriskの公式リポジトリのキーを追加
    curl -sL https://packages.asterisk.org/keys/DEB-GPG-KEY-asterisk | apt-key add - && \
    \
    # Asteriskの公式リポジトリをaptのソースリストに追加
    echo "deb http://packages.asterisk.org/deb bullseye main" > /etc/apt/sources.list.d/asterisk.list && \
    \
    # パッケージリストを再度更新し、Asteriskをインストール
    apt-get update && \
    apt-get install -y asterisk && \
    \
    # 不要になったパッケージキャッシュを削除してイメージサイズを削減
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

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
CMD ["asterisk", "-f", "-U", "asterisk", "-G", "asterisk"]
