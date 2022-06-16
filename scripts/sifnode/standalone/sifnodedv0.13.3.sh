#!/bin/bash
#####CHANGE THESE#########################################
## visit go.dev/dl and copy/paste your desired version. ##
##########################################################
GOV=go1.18.3.linux-amd64.tar.gz
FLD=/usr/local/bin/go
FLD1=$HOME/go

##########################################################
# echo "Enter Chain Name (ie. Osmosis)"
# read CHAIN_D
# echo $CHAIN_D is Selected
function update(){
  command sudo apt update
}

function upgrade1() {
   command sudo apt upgrade -y
}

function loclgo() {
  if [[ -f "$FLD" ]]; then
    if [[ -f "$FLD1" ]]; then
      rm -r $FLD && rm -r $FLD1
    else
      return 2
  fi
fi
  if [[ $RES = 1 ]]; then
    echo "ok move on"
  else
    echo "no go"
  fi
}


function dlinstall() {
  wget https://go.dev/dl/$GOV
}
function tarf() {
  tar xf $1
}

function pathlock() {
  if go version; then
    echo ""
  else
    echo "*******************************"
    echo "running gopath"
    gopath
  fi
}

function gopath() {
  echo $PATH
  export PATH=$PATH:$HOME/go/bin
  sudo ln -s $HOME/go/bin/go /usr/local/bin/go
}
function goclean() {
if [[ -f "$GOV" ]]; then
  rm $GOV
else
  echo "can't find or delete $GOV"
fi
}
##error handling##
##################
echo "##########################################################"
echo "Install script for Sifnode v0.33.3 with go1.18.3"
echo "##########################################################"
read -p "Press any key to continue or CTRL-C to abort"

update
upgrade1

echo "##########################################################"
echo "                SYSTEM UPDATED & UPGRADED                 "
echo "##########################################################"
sleep 2

if loclgo; then
  echo "cleaned up"
else
  echo "already cleaned"
command cd
fi

echo "##########################################################"
echo "             PREVIOUS GO INSTALLATION REMOVED             "
echo "##########################################################"
sleep 2
echo "##########################################################"
echo "                  INSTALLING GO V1.18.*                   "
echo "##########################################################"
echo ""
echo "looking for old GO installation in $FLD & $FLD1"
sleep 2
#     if loclgo; then
#         echo "all clear"
#       else
#         echo "unable to remove $FLD or $FLD1. Try after with 'sudo rm -r'"
#     fi
# echo "Downloading and installing GO."
# echo "sleeping 2 seconds"
# sleep 2
if dlinstall; then
  echo "xtracting GO to $HOME/go"
  tarf $GOV
  echo "xtraction complete."
else
  echo "error decompressing"
fi

if pathlock; then
  echo "setting up GO path"
  goclean
  echo "$GOV remove. Squeeky Clean!"
fi
command cd
echo $pwd
sleep 2
########## go installed ##############

########## git and all ###############

echo "##########################################################"
echo "                       GO INSTALLED                       "
echo "##########################################################"
echo "##########################################################"
echo "              INSTALLING MAKE, GCC, JQ and GIT            "
echo "##########################################################"
read -p "Press Enter to continue or CTRL-C to cancel"

reqApp=(git make gcc jq)

function install_apps_basics() {
  sudo apt install $@ -y
}

function gitd() {
  if command cd; then
  command git clone https://github.com/Sifchain/sifnode.git
  command cd sifnode/
else
  echo "issue with main git"
fi
}
function giti() {
  # if command cd; then
    if git checkout v0.13.3 && make clean install; then
    echo ""
  else
    echo "can't move to proper folder"
  fi
}
function cosmovi() {
  if command cd; then
    go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0
  else
    echo "can't move back to $HOME"
  fi
}



echo "##########################################################"
echo "           Checking for GCC, MAKE, GIT & jQ "
echo "##########################################################"
command cd

function status1() {
  ins=$1
  st1=$(dpkg -s $ins | grep "Status: install ok installed")
  st2=$(echo $st1 2>/dev/null)

  if [[ $st2 = "Status: install ok installed" ]]; then
    echo "$ins installed"
  else
    DEBIAN_FRONTEND=noninteractive sudo apt install $ins -y
  fi
}

function basics_loop() {
  for check in ${reqApp[*]}
  do
    status1 $check
  done
}
basics_loop

sleep 2

gitd
giti
cosmovi

sleep 2

echo "##########################################################"
echo "                    Deploying SIFNODE                     "
echo "##########################################################"

CP1=$(mkdir -p $HOME/.sifnoded/cosmovisor/genesis/bin)
CP2=$(mkdir $HOME/.sifnoded/cosmovisor/upgrades)
CP3=$(sudo cp $HOME/go/bin/sifnoded $HOME/.sifnoded/cosmovisor/genesis/bin)

function cmd1() {
  command $1
}

for sc in $CP1 $CP2 $CP3
do
 cmd1 $sc
done

echo ""
echo "Folder creation and Cpy Complete."
echo ""
sleep 2

echo "##########################################################"
echo "                     Fine tuning                          "
echo "##########################################################"

function exportExport() {
touch var.var
echo "
DAEMON_HOME=$HOME/.sifnoded
DAEMON_RESTART_AFTER_UPGRADE=true
DAEMON_ALLOW_DOWNLOAD_BINARIES=false
DAEMON_NAME=sifnoded
UNSAFE_SKIP_BACKUP=true
" > var.var
}

exportExport

echo "Variables Export Completed."
echo ""

function linkSifnoded() {
sudo ln -s $HOME/.sifnoded/cosmovisor/genesis/bin/sifnoded /usr/local/bin/sifnoded
}

echo "Linking sifnoded"
echo ""
linkSifnoded
echo "Sifnoded $(command sifnoded version) installed"


echo "##########################################################"
echo "                        IMPORTANT                         "
echo "##########################################################"
echo "##########################################################"
echo "   When the installation is over, type "source var.var"   "
echo "##########################################################"

echo "##########################################################"
echo "  Ready for INIT. Have a look at GITHUB and run part2.sh  "
echo "##########################################################"
