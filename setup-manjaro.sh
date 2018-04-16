#!/usr/bin/bash

function log {
  msg="$1"
  echo "********************************************"
  echo "$msg"
  echo "********************************************"
  echo ""
}

function url_for_latest_release_from_github {
  user="$1"
  repo="$2"
  package="$3"
  query=".assets | .[] | {name: .name, url: .browser_download_url} | select(.name | test(\"$package\")) | .url"

  curl -sL "https://api.github.com/repos/$user/$repo/releases/latest" | jq -r "$query"
}

if [ ! -d "$HOME/Drive/personal/ssh" ]; then
  log "You need to manually install insync and pull down the ssh keys"
  exit 42
fi
if [ ! -d "$HOME/.ssh" ]; then
  ln -s $HOME/Drive/personal/ssh $HOME/.ssh
fi
ssh-agent -s
ssh-add $HOME/.ssh/id_rsa

sudo pacman -S \
  firefox \
  neovim \
  python-neovim \
  fish \
  jq \
  hub \
  ripgrep \
  fzf \
  pulseaudio \
  cmake \
  freetype2 \
  fontconfig \
  pkg-config \
  make \
  xclip \
  python-gobject \
  python-xdg \
  librsvg \
  redshift \
  maim \
  rofi \
  ttf-hack

yaourt -S \
  peek \
  insync \
  universal-ctags-git \
  flameshot \
  noto-emoji-fonts \
  corebird \
  xininfo-git

if [ ! -d $HOME/projects ]; then
  mkdir -p $HOME/projects
fi
if [ ! -d $HOME/src/bin ]; then
  mkdir -p $HOME/src/bin
fi
if [ ! -d $HOME/bin ]; then
  git clone https://github.com/jc00ke/bin.git
fi

cd $HOME

if [ -z "$(which direnv)" ]; then
  cd $HOME/src
  package="direnv.linux-amd64"
  log "Install $package"
  url=$(url_for_latest_release_from_github "zimbatm" "direnv" "$package")
  wget "$url"
  chmod +x $package
  sudo mv $package /usr/local/bin/direnv
fi

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
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.4.1
  mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
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
rm "$HOME/.i3config.conf"
ln -sf "$HOME/projects/dotfiles/i3config.conf" "$HOME/.i3/config"

rm -f $HOME/.vimrc
if [ ! -d $HOME/.config/nvim ]; then
  mkdir -p $HOME/.config/nvim
  ln -s "$HOME/projects/dotfiles/init.vim" "$HOME/.config/nvim/init.vim"

  pip install wheel neovim
  curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  nvim +PlugInstall +qall
fi

asdf plugin-add rust https://github.com/code-lever/asdf-rust.git
asdf install rust stable
asdf global rust stable

cd $HOME/src
git clone git@github.com:jwilm/alacritty.git                                                                                                                                                  14:51:40
cd alacritty
cargo build --release
cp target/release/alacritty $HOME/src/bin/

cd $HOME/src
if [ ! -d $HOME/src/teiler ]; then
  git clone git@github.com:carnager/teiler.git
  sudo make install
fi

