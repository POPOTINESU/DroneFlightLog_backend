# syntax = docker/dockerfile:1

# ベースイメージの設定
ARG RUBY_VERSION=3.3.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# 作業ディレクトリの設定
WORKDIR /rails

# 環境変数の設定
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    TZ=Asia/Tokyo \
    LANG=C.UTF-8 \
    PATH="/usr/local/bundle/bin:${PATH}"

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config cron

# アプリケーションのGemをインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# アプリケーションコードのコピー
COPY . .

# bootsnapの事前コンパイル
RUN bundle exec bootsnap precompile app/ lib/

# cronが実行できるようにする設定
RUN chmod 0644 /etc/crontab && \
    touch /var/log/cron.log && \
    chmod 0644 /var/log/cron.log && \
    mkdir -p /var/run/crond && \
    chown root:root /var/run/crond && \
    chmod 0775 /var/run/crond

# whenever gemのインストールとcrontabの更新
RUN gem install whenever && \
    whenever --update-crontab

# エントリーポイントスクリプトをコピー
COPY entrypoint.sh /rails/entrypoint.sh

# エントリーポイントスクリプトに実行権限を付与（rootユーザーとして）
USER root
RUN chmod +x /rails/entrypoint.sh

# 非rootユーザーとして実行するための設定
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# エントリーポイントの設定
ENTRYPOINT ["/rails/entrypoint.sh"]

# サーバーを起動
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]