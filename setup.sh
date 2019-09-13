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
ssh-add $HOME/.ssh/id_ed25519

function add_ppa {
  ppa="$1"
  package="$2"
  log "Adding $ppa for $package"
  sudo sh -c "add-apt-repository -y ppa:$ppa"
}

#add_ppa "kgilmer" "regolith-stable"

sudo apt-get update

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
  ubuntu-restricted-extras

if [ ! -d $HOME/projects ]; then
  mkdir -p $HOME/projects
fi
if [ ! -d $HOME/src ]; then
  mkdir -p $HOME/src
fi

# sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
# sudo update-alternatives --config vi
# sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
# sudo update-alternatives --config vim
# sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
# sudo update-alternatives --config editor

log "Swap Command & Alt on Apple keyboards"
echo options hid_apple swap_opt_cmd=1 | sudo tee -a /etc/modprobe.d/hid_apple.conf
sudo update-initramfs -u -k all

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
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.4.1
  mkdir -p ~/.config/fish/completions; and cp ~/.asdf/completions/asdf.fish ~/.config/fish/completions
fi

cd $HOME
if [ ! -d $HOME/projects/dotfiles ]; then
  git clone git@github.com:jc00ke/dotfiles.git projects/dotfiles
fi
for file in $HOME/projects/dotfiles/*
do
  name="$(basename $file)"
  rm -f ".$name"
  ln -s "$HOME/projects/dotfiles/$name" "$HOME/.$name"
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
