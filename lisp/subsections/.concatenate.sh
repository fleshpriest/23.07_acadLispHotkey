#! /usr/bin/env bash

# Erases main.lsp & replaces it with the contents of the various submodule scripts

main="../main.lsp"
rm $main
cat *.lsp >> $main
echo "Submodules concatonated into $main"
