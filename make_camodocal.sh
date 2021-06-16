#!/bin/bash
GREEN='\033[1;32m'
NC='\033[0m' # no color
nproc=6
user=`id -u -n`

echo -e "\n${GREEN}>>> Installing Camodocal ${NC}"
cd $HOME/.
mkdir -p $HOME/camodocal/build && cd $HOME/camodocal/build && cmake -DCMAKE_BUILD_TYPE=Release ..
make -j$nproc || exit $?
make install || exit $?

echo -e "\n${GREEN}>>> Finish installation ${NC}"




