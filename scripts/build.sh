#!/bin/sh
set -e

git -C apps/funlesson switch master
git -C apps/funlesson-web switch master

cd apps/funlesson
funbuild build

cd ../..
cd apps/funlesson-web
funbuild build

cd ../..

funbuild push
