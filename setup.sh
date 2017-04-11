#!/bin/bash


function log {
  msg="$1"
  echo "********************************************"
  echo "$msg"
  echo "********************************************"
  echo ""
}
if [ ! -d "$HOME/.ssh" ]; then
  log "You need SSH keys or this isn't gonna do much"
  exit 42
fi
ssh-agent -s
ssh-add $HOME/.ssh/id_rsa


log "Adding the repos to /etc/apt/sources.list.d/"

RELEASE="$(lsb_release -sc)"
ME="$(whoami)"

function add_ppa {
  ppa="$1"
  package="$2"
  log "Adding $ppa for $package"
  sudo sh -c "add-apt-repository -y ppa:$ppa"
}

function add_key {
  url="$1"
  wget -qO - "$url" | sudo apt-key add -
}

function edit_ppa {
  from="$1"
  to="$2"
  list="$3"
  sudo sed -i "s/$from/$to/" "/etc/apt/sources.list.d/$list.list"
}

function url_for_latest_release_from_github {
  user="$1"
  repo="$2"
  package="$3"
  query=".assets | .[] | {name: .name, url: .browser_download_url} | select(.name | test(\"$package\")) | .url"

  curl -sL "https://api.github.com/repos/$user/$repo/releases/latest" | jq -r "$query"
}

add_ppa "git-core/ppa" "git-core"
add_ppa "neovim-ppa/unstable" "neovim"
add_ppa "shutter/ppa" "shutter"
add_ppa "tmate.io/archive" "tmate"
edit_ppa "zesty" "xenial" "shutter-ubuntu-ppa-zesty"
edit_ppa "zesty" "yakkety" "tmate_io-ubuntu-archive-zesty"
edit_ppa "zesty" "yakkety" "insync"

if [ -z "$(ls /etc/apt/sources.list.d/insync.list)" ]; then
  add_key "https://d2t3ff60b2tol4.cloudfront.net/services@insynchq.com.gpg.key"
  sudo sh -c "echo 'deb http://apt.insynchq.com/ubuntu $RELEASE non-free' > /etc/apt/sources.list.d/insync.list"
fi

if [ -z "$(ls /etc/apt/sources.list.d/google-chrome.list)" ]; then
  add_key "https://dl-ssl.google.com/linux/linux_signing_key.pub"
  sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb stable main" > /etc/apt/sources.list.d/google-chrome.list'
fi

sudo apt-get update

sudo apt-get install -y \
  build-essential \
  bison \
  shutter \
  xclip \
  htop \
  curl \
  git \
  git-doc \
  git-svn \
  git-gui \
  gitg \
  libffi-dev \
  libreadline-dev \
  libssl-dev \
  zlib1g-dev \
  libncurses5-dev \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  libgdbm-dev \
  parallel \
  fish \
  insync \
  autoconf \
  autopoint \
  libtool \
  exuberant-ctags \
  openconnect \
  network-manager-openconnect \
  network-manager-openconnect-gnome \
  tmux \
  tmate \
  google-chrome-stable \
  font-manager \
  software-properties-common \
  imagemagick \
  python3-pip \
  neovim \
  fonts-noto \
  fonts-noto-mono \
  gst-plugins-good \
  gst-plugins-bad \
  gstreamer1.0-libav \
  corebird \
  cmake \
  libfreetype6-dev \
  libfontconfig1-dev

if [ ! -d $HOME/projects ]; then
  mkdir -p $HOME/projects
fi
if [ ! -d $HOME/src ]; then
  mkdir -p $HOME/src
fi
if [ ! -d $HOME/bin ]; then
  git clone https://github.com/jc00ke/bin.git
fi

sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor

cd $HOME/src

function install_postmodern_package {
  package="$1"
  version="$2"
  tarball="${package}-${version}.tar.gz"
  wget -O "$tarball" "https://github.com/postmodern/${package}/archive/v${version}.tar.gz"
  tar -xzvf "$tarball"
  cd "${package}-${version}/"
  sudo make install
}

if [ -z "$(which ruby-install)" ]; then
  log "Installing ruby-install"
  install_postmodern_package "ruby-install" "0.6.1"
fi

if [ -z "$(which chruby-exec)" ]; then
  log "Installing chruby"
  install_postmodern_package "chruby" "0.3.9"
fi

wget -O chruby-fish-0.8.0.tar.gz https://github.com/JeanMertz/chruby-fish/archive/v0.8.0.tar.gz
tar -xzvf chruby-fish-0.8.0.tar.gz
cd chruby-fish-0.8.0/
sudo make install

if [ ! -d "$HOME/.config/omf" ]; then
  cd $HOME/src
  log "Install oh-my-fish"
  curl -L http://get.oh-my.fish | fish
fi

if [ -z "$(which jq)" ]; then
  cd $HOME/src
  package="jq-linux64"
  log "Install $package"
  wget "https://github.com/stedolan/jq/releases/download/jq-1.5/$package"
  chmod +x $package
  sudo mv $package /usr/local/bin/jq
fi

if [ -z "$(which direnv)" ]; then
  cd $HOME/src
  package="direnv.linux-amd64"
  log "Install $package"
  url=$(url_for_latest_release_from_github "zimbatm" "direnv" "$package")
  wget "$url"
  chmod +x $package
  sudo mv $package /usr/local/bin/direnv
fi

if [ -z "$(which hub)" ]; then
  cd $HOME/src
  package="hub-linux-amd64"
  log "Install $package"
  url=$(url_for_latest_release_from_github "github" "hub" "$package")
  wget "$url"
  archive="${url##*/}"
  tar xf "$archive"
  cd "${archive%.tgz}"
  sudo ./install
fi

if [ -z "$(which rg)" ]; then
  cd $HOME/src
  package="x86_64-unknown-linux-musl"
  log "Install $package"
  url=$(url_for_latest_release_from_github "BurntSushi" "ripgrep" "$package")
  wget "$url"
  archive="${url##*/}"
  tar xf "$archive"
  cd "${archive%.tar.gz}"
  sudo mv rg "/usr/local/bin/"
  sudo mv rg.1 "/usr/local/share/man/man1/"
  sudo mandb
  sudo mv "complete/rg.fish" "/usr/share/fish/vendor_completions.d/"
fi

if [ -z "$(which rustc)" ]; then
  log "Installing rustup for Rust and Cargo"
  curl https://sh.rustup.rs -sSf | sh
fi

if [ ! -d $HOME/src/alacritty ]; then
  cd $HOME/src
  git clone git@github.com:jwilm/alacritty.git
  cd alacritty
  ln -s $HOME/src/alacritty/Alacritty.desktop $HOME/.local/share/applications/Alacritty.desktop
  cargo build --release
  sudo cp target/release/alacritty /usr/local/bin
fi

cd $HOME
if [ ! -d $HOME/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git .asdf
fi

if [ ! -d $HOME/projects/dotfiles ]; then
  git clone git@github.com:jc00ke/dotfiles.git projects/dotfiles
fi
for file in $HOME/projects/dotfiles/*
do
  name="$(basename $file)"
  rm -f ".$name"
  ln -s "$HOME/projects/dotfiles/$name" "$HOME/.$name"
done

rm -f $HOME/.vimrc

if [ ! -d $HOME/.fzf ]; then
  git clone https://github.com/junegunn/fzf .fzf
  $HOME/.fzf/install
fi

rm -rf $HOME/.config/fish
if [ ! -d $HOME/.config/fish ]; then
  git clone git@github.com:jc00ke/fish-config.git "$HOME/.config/fish"
fi
chsh -s /usr/bin/fish

if [ ! -d $HOME/.config/nvim ]; then
  mkdir -p $HOME/.config/nvim
  ln -s "$HOME/projects/dotfiles/init.vim" "$HOME/.config/nvim/init.vim"

  pip install wheel neovim
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  nvim +PlugInstall +qall
fi

cd $HOME/src
node_version="7.7.4"
wget https://nodejs.org/dist/v$node_version/node-v$node_version-linux-x64.tar.xz
tar xf node-v$node_version-linux-x64.tar.xz
ln -s "$HOME/src/node-v$node_version-linux-x64" "$HOME/src/node"

cd $HOME

if [ ! -d "/usr/share/fonts/opentype/source-code-pro" ]; then
  log "Install Source Code Pro font"
  sudo git \
    clone \
    --depth 1 \
    --branch release \
    "https://github.com/adobe-fonts/source-code-pro.git" \
    "/usr/share/fonts/opentype/source-code-pro"
  sudo fc-cache -f -v
fi

cd $HOME
curl 'https://raw.githubusercontent.com/heewa/bae/master/emoji_vars.fish' > ~/.emoji_vars.fish

log "Install GNOME extensions"
log "https://extensions.gnome.org/extension/1113/nothing-to-say/"
dconf write "/org/gnome/shell/extensions/nothing-to-say/keybinding-toggle-mute" "[\"<Control>space\", \"Pause\"]"
dconf write "/org/gnome/desktop/interface/enable-animations" false
log "https://extensions.gnome.org/extension/15/alternatetab/"
log "https://extensions.gnome.org/extension/657/shelltile/"
log "https://extensions.gnome.org/extension/826/suspend-button/"
log "https://extensions.gnome.org/extension/484/workspace-grid/"
log "https://extensions.gnome.org/extension/1031/topicons/"
log "https://extensions.gnome.org/extension/967/hide-legacy-tray/"
