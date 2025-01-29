FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/usr/bin/zsh
ENV TERM=xterm-256color

RUN apt-get update && apt-get install -y \
  sudo \
  git \
  curl \
  zsh \
  make \
  gcc \
  locales \
  tzdata \
  ca-certificates \
  build-essential \
  procps \
  ansible \
  python3-apt \
  ansible-lint \
  && rm -rf /var/lib/apt/lists/* \
  && ansible-galaxy collection install community.general

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN userdel -r ubuntu 2>/dev/null || true && \
  useradd -m -s /usr/bin/zsh testuser -u 1000 \
  && echo "testuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/testuser \
  && mkdir -p /home/linuxbrew/.linuxbrew \
  && chown -R testuser:testuser /home/linuxbrew /home/linuxbrew/.linuxbrew \
  && chmod -R 755 /home/linuxbrew /home/linuxbrew/.linuxbrew

USER testuser
WORKDIR /home/testuser

COPY --chown=testuser:testuser . /home/testuser/dotfiles/
RUN chmod +x /home/testuser/dotfiles/install.sh

RUN mkdir -p .config .local/share .cache

COPY --chown=testuser:testuser test/entrypoint.sh /home/testuser/entrypoint.sh
RUN chmod +x /home/testuser/entrypoint.sh

HEALTHCHECK --interval=1s --timeout=3s --start-period=5s --retries=3 \
  CMD pidof zsh || exit 1

ENTRYPOINT ["/home/testuser/entrypoint.sh"]
