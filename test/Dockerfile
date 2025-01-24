FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/usr/bin/zsh
ENV TERM=xterm-256color
ENV PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Install base packages
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
  && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN useradd -m -s /usr/bin/zsh testuser \
  && echo "testuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/testuser \
  && mkdir -p /home/testuser/.local/share /home/testuser/.cache \
  && chown -R testuser:testuser /home/testuser

USER testuser
WORKDIR /home/testuser

RUN mkdir -p .config .local/share .cache

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
  && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc

HEALTHCHECK --interval=1s --timeout=3s --start-period=5s --retries=3 \
  CMD pidof tail && pidof bash || exit 1

CMD ["tail", "-f", "/dev/null"]
