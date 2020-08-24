# ESE532 Handouts Repo

## Build Instructions
Make sure you have python3. If you don't, we recommend [Miniconda3](https://docs.conda.io/en/latest/miniconda.html)

Build by:
```
# source ~/.bashrc # activate your conda environment if not already
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

**For course admins**:
Copy `ese532_handouts/_build/html/*` to the `handouts` folder of the course website