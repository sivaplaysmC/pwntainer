FROM docker.io/library/debian:sid-20251208-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN     apt update && \
        apt install --no-install-recommends -y \
        sudo \
        zsh \
        ca-certificates \
        gnupg \
        curl \
        wget \
        git \
        file \
        tmux \
        build-essential \
        python3 \
        python3-pip \
        python3-venv \
        xz-utils \
        unar \
        lzma \
        zip \
        fd-find \
        ripgrep \
        gcc \
        gdbserver \
        stow \
        unzip \
        ssh \
        xxd \
        socat \
        ncat \
        netcat-openbsd \
        binutils \
        elfutils \
        patchelf \
        strace \
        ltrace \
        locales \
        clangd \
        clang-format \
        jq \
        && \
        wget https://github.com/io12/pwninit/releases/download/3.3.1/pwninit -O /usr/local/bin/pwninit && \
        useradd -m -s /bin/zsh ahab && \
        usermod -aG sudo ahab && \
        echo "ahab ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ahab && \
        chmod 0440 /etc/sudoers.d/ahab && \
        ln -s `which fdfind` /usr/local/bin/fd && \
        sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        locale-gen && \
        rm -rf /var/cache/apt/  /var/lib/apt/lists/*

RUN     cd /tmp && \
        wget https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz && \
        tar -xzf nvim-linux-x86_64.tar.gz && \
        cp -r nvim-linux-x86_64/* /usr/local && \
        rm -rf /tmp/*

RUN curl -qsL 'https://install.pwndbg.re' | sh -s -- -t pwndbg-gdb && ln -sf `which pwndbg` /usr/local/bin/pwntools-gdb

USER ahab
ENV HOME=/home/ahab
WORKDIR /home/ahab

RUN set -eux; \
    \
    # ---- oh-my-zsh (non-interactive, no shell switch) ----
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; \
    \
    # ---- dotfiles ----
    # ---- fzf ----
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf; \
    ~/.fzf/install --all; \
    \
    # ---- fzf-tab ----
    git clone https://github.com/Aloxaf/fzf-tab \
      ~/.oh-my-zsh/custom/plugins/fzf-tab; \
    \
    git clone https://github.com/sivaplaysmC/dotfiles ~/.dotfiles; \
    cd ~/.dotfiles; \
    rm -f ~/.zshrc ~/.zshenv ~/.zprofile; \
    stow nvim tmux zsh yazi pwntools; \
    \
    # ---- nvim plugin bootstrap (no UI) ----
    nvim --headless "+qa"; \
    \
    # ---- yazi ----
    cd /tmp; \
    wget -q https://github.com/sxyazi/yazi/releases/download/v25.5.31/yazi-x86_64-unknown-linux-gnu.zip; \
    unzip yazi-x86_64-unknown-linux-gnu.zip; \
    mkdir -p ~/.local/bin ; \
    cp yazi-x86_64-unknown-linux-gnu/ya* ~/.local/bin/; \
    \
    # ---- cleanup ----
    rm -rf /tmp/* ~/.cache ~/.fzf/install.log

RUN set -eux; \
    \
    pip install --no-cache-dir --break-system-packages \
    angr \
    gmpy2 \
    ruff \
    basedpyright \
    z3-solver \
    pwntools \
    pycryptodome \
    ipython \
    ipdb \
    libdebug


ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TERM=xterm-256color

CMD [ "/usr/bin/zsh" ]

