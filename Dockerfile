# syntax = docker/dockerfile:1

# Base image for the build
ARG RUBY_VERSION=3.3.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Set working directory
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development test" \
    TZ=Asia/Tokyo \
    LANG=C.UTF-8 \
    PATH="/usr/local/bundle/bin:${PATH}"

# Install dependencies for building gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libvips pkg-config cron

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Ensure cron can run
RUN chmod 0644 /etc/crontab && \
    touch /var/log/cron.log && \
    chmod 0644 /var/log/cron.log && \
    mkdir -p /var/run/crond && \
    chown root:root /var/run/crond && \
    chmod 0775 /var/run/crond

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Add whenever gem and update crontab
RUN gem install whenever && \
    whenever --update-crontab

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the cron service and Rails server
CMD ["sh", "-c", "cron && bundle exec rails server -b 0.0.0.0 -p 3000"]