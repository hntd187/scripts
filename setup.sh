#!/bin/bash

idea_version="2016.1.1"
idea_filename="ideaIC-$idea_version.tar.gz"
idea_url="https://download.jetbrains.com/idea/$idea_filename"
jdk_version=8
spotify_key=BBEBDCB318AD50EC6865090613B00F1FD2C19886

if [[ ! -e /etc/apt/sources.list.d/webupd8team-ubuntu-sublime-text-3-xenial.list ]]; then 
  sudo add-apt-repository ppa:webupd8team/sublime-text-3
fi

key=$(apt-key list | grep pub | awk '{print $2}' | grep -c $(echo $spotify_key | tail -c 9))
if [[ $key -eq 0 ]]; then 
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $spotify_key
fi

echo -e "Adding repos...\n"

if [[ ! -e /etc/apt/sources.list.d/canonical.list ]]; then
  echo -e "Adding canonical partners repo...\n"
  echo deb http://archive.canonical.com/ubuntu xenial partner | sudo tee /etc/apt/sources.list.d/canonical.list
else
  echo -e "Canonical repo already exists...\n"
fi

if [[ ! -e /etc/apt/sources.list.d/spotify.list ]]; then
  echo -e "Adding Spotify Repo\n"
  echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
else
  echo -e "Spotify repo already exists...\n"
fi

sudo apt-get -qy update > /dev/null
[[ $# -eq 1 ]] && echo "Update repo failed..." && exit 1;

echo -e "Installing vim, curl, nmap, git, jdk8 and compilers...\n"
sudo apt-get -y install vim curl nmap git openjdk-${jdk_version}-jdk build-essential > /dev/null
[[ $# -eq 1 ]] && echo "Install software failed..." && exit 1;

echo -e "Installing Chrome and the correct flash plugin\n"
sudo apt-get -y install chromium-browser adobe-flashplugin > /dev/null
[[ $# -eq 1 ]] && echo "Install browser failed..." && exit 1;

echo -e "Installing Spotify and Sublime...\n"
sudo apt-get -y install spotify-client sublime-text-installer > /dev/null
[[ $# -eq 1 ]] && echo "Install extras failed..." && exit 1;


if [[ ! -e ~/.config/tilda/config_0 ]]; then
  echo -e "Creating tilda configuration...\n"
  mkdir -p ~/.config/tilda
  curl -# https://cdn.rawgit.com/hntd187/scripts/master/config_0 -o ~/.config/tilda/config_0
fi

if [[ ! -e ~/.vimrc ]]; then
  echo -e "Creating .vimrc configuration...\n"
  curl -# https://cdn.rawgit.com/hntd187/scripts/master/.vimrc -o ~/.vimrc
fi

if [[ ! -e /usr/local/sbt ]]; then
  echo -e "Installing sbt... \n"
  sudo curl -# https://cdn.rawgit.com/paulp/sbt-extras/master/sbt -o /usr/local/bin/sbt
  sudo chmod 0755 /usr/local/bin/sbt
fi

echo -e "Downloading Jetbrains IDEA $idea_version from $idea_url...\n"
curl -#L -o ~/$idea_filename -C - $idea_url
idea_folder=$(tar -tf ~/$idea_filename | head -1 | cut -d/ -f1)
tar -xzf ~/$idea_filename -C ~/

~/$idea_folder/bin/idea.sh
