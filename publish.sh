#!/bin/bash
jupyter-book clean ese532_handouts/ --all
jupyter-book build ese532_handouts/
rm -rf ~/fall2020/html/handouts/*
cp -r ese532_handouts/_build/html/* ~/fall2020/html/handouts/
chmod a+rx ~/fall2020/html/handouts/
chmod a+r ~/fall2020/html/handouts/index.html
find ~/fall2020/html/handouts/* -type d -exec chmod a+rx {} +
find ~/fall2020/html/handouts/* -type f -exec chmod a+r {} +