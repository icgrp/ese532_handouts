# ESE532 Handouts Repo

## Build Instructions
Make sure you have python3. If you don't, we recommend [Miniconda3](https://docs.conda.io/en/latest/miniconda.html)

## Build by:
```
# conda activate # activate your conda environment if not already
git clone https://github.com/icgrp/ese532_handouts.git
cd ese532_handouts/
pip install -r requirements.txt
jupyter-book build ese532_handouts/
```
And then browse locally by opening the `index.html` in the `ese532_handouts/_build/html`
folder.

Clean the built files using:
```
jupyter-book clean ese532_handouts/ --all
```

## Editing:
The content is in [ese532_handouts/](./ese532_handouts/) directory. It's written with
jupyter-book's MyST markdown syntax.

Refer to this guide to figure out the markdown
syntax: [https://jupyterbook.org/reference/cheatsheet.html](https://jupyterbook.org/reference/cheatsheet.html)

### For course admins:
Use `bash publish.sh` to upload the handouts on course website