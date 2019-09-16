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
  log "Go install Keybase"
  exit 42
fi

sudo apt-get install -y \
  build-essential \
  bison \
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
  autoconf \
  autopoint \
  libtool \
  exuberant-ctags \
  openconnect \
  openvpn \
  software-properties-common \
  imagemagick \
  python3-pip \
  hub \
  cmake \
  peek \
  jq \
  ripgrep \
  direnv \
  ubuntu-restricted-extras \
  neovim \
  fzf \
  inotify-tools

if [ ! -d $HOME/projects ]; then
  mkdir -p $HOME/projects
fi
if [ ! -d $HOME/src ]; then
  mkdir -p $HOME/src
fi

cd $HOME

rm -rf $HOME/.config/fish
git clone git@github.com:jc00ke/fish-config.git "$HOME/.config/fish"

chsh -s /usr/bin/fish
if [ ! -d "$HOME/.config/omf" ]; then
  cd $HOME/src
  log "Install oh-my-fish"
  curl -L http://get.oh-my.fish | fish
fi

cd $HOME
if [ ! -d $HOME/.asdf ]; then
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.4
  mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
fi

cd $HOME
if [ ! -d $HOME/projects/dotfiles ]; then
  git clone git@github.com:jc00ke/dotfiles.git projects/dotfiles
fi
for file in $HOME/projects/dotfiles/*
do
  name="$(basename $file)"
  ln -sf "$HOME/projects/dotfiles/$name" "$HOME/.$name"
done

cd $HOME
rm -f $HOME/.vimrc

if [ ! -d $HOME/.config/nvim ]; then
  mkdir -p $HOME/.config/nvim
  ln -s "$HOME/projects/dotfiles/init.vim" "$HOME/.config/nvim/init.vim"

  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  nvim +PlugInstall +qall
fi

cd $HOME/src
ngrok_package="ngrok-stable-linux-amd64"
ngrok_archive="$ngrok_package.zip"
wget "https://bin.equinox.io/c/4VmDzA7iaHb/$ngrok_archive"
unzip "$ngrok_archive"
chmod +x ngrok
sudo mv ngrok /usr/local/bin/ngrok
