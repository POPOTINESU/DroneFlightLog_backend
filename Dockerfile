# ベースイメージ
FROM registry.docker.com/library/ruby:3.3.0-slim as base

# 作業ディレクトリ
WORKDIR /rails

# 環境変数設定
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    TZ=Asia/Tokyo \
    LANG=C.UTF-8 \
    PATH="/usr/local/bundle/bin:${PATH}"

# ビルドステージ
FROM base as build

# パッケージのインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config cron

# Gemのインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# アプリケーションコードのコピー
COPY . .

# bootsnapコードのプリコンパイル
RUN bundle exec bootsnap precompile app/ lib/

# wheneverをインストール
RUN gem install whenever

# wheneverコマンドを実行してcrontabを更新
RUN whenever --update-crontab

# 最終ステージ
FROM base

# デプロイに必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client cron && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# ビルドアーティファクトのコピー
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# ユーザー設定
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# entrypointの設定
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# cronサービスを起動し、アプリケーションを開始
CMD ["sh", "-c", "cron && bundle exec puma -C config/puma.rb"]