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
  ttf-hack \
  diff-so-fancy

yaourt -S yay-bin
sudo pacman -R yaourt

yay -S \
  peek \
  insync \
  universal-ctags-git \
  flameshot \
  noto-emoji-fonts \
  corebird \
  xininfo-git \
  exa-git \
  rofi-emoji \
  xvkbd \
  gif-for-cli \
  zoom \
  direnv

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

rm -rf $HOME/.config/fish
git clone git@github.com:jc00ke/fish-config.git "$HOME/.config/fish"

rm -rf $HOME/.config/polybar
git clone git@github.com:jc00ke/polybar-config.git "$HOME/.config/polybar"

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


cd $HOME/src
rm -rf bat*
bat_package="x86_64-unknown-linux-musl"
bat_url="$(url_for_latest_release_from_github "sharkdp" "bat" "$bat_package")"
wget "$bat_url"
bat_archive="$(ls bat*)"
mkdir bat
tar xf "$bat_archive" -C bat --strip-components=1
sudo mv bat/bat /usr/local/bin/
sudo mv bat/bat.1 /usr/local/man/man1/
sudo mandb
