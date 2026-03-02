#! /usr/bin/env bash

main="../main.lsp"
rm $main
cat *.lsp >> $main
echo "Submodules concatonated into $main"
