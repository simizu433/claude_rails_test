FROM ruby:3.3

ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  git \
  curl \
  vim \
  less \
  sudo \
  procps \
  util-linux \
  && rm -rf /var/lib/apt/lists/*

# Create a real non-root user for VS Code Dev Containers.
# The UID/GID are passed from the host via docker-compose build args.
RUN set -eux; \
  if ! getent group "${USER_GID}" >/dev/null; then \
    groupadd --gid "${USER_GID}" "${USERNAME}"; \
  fi; \
  if ! getent passwd "${USER_UID}" >/dev/null; then \
    useradd --uid "${USER_UID}" --gid "${USER_GID}" -m -s /bin/bash "${USERNAME}"; \
  fi; \
  mkdir -p /workspace /workspace/vendor/bundle /workspace/.npm-global; \
  chown -R "${USER_UID}:${USER_GID}" /workspace /home/${USERNAME}

WORKDIR /workspace

# Takumi Guard for npm during image build.
RUN npm config set registry https://npm.flatt.tech/

# Rails CLI is installed in the image-level RubyGems path so it remains available
# even when /workspace is bind-mounted by Docker Compose.
RUN gem install rails bundler --no-document --source https://rubygems.flatt.tech/

# Project gems installed by `bundle install` go under the mounted workspace.
# Do NOT set GEM_HOME to /workspace/vendor/bundle, otherwise the image-level
# Rails CLI can become unable to find railties.
ENV BUNDLE_PATH=/workspace/vendor/bundle
ENV PATH="/workspace/.npm-global/bin:${PATH}"
ENV NPM_CONFIG_PREFIX=/workspace/.npm-global
ENV npm_config_registry=https://npm.flatt.tech/
ENV HOME=/home/devuser

USER devuser

CMD ["bash"]
