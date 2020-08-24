# ESE532 Handouts Repo

## Build Instructions
Make sure you have python3. If you don't, we recommend [Miniconda3](https://docs.conda.io/en/latest/miniconda.html)

Build by:
```
# source ~/.bashrc # activate your conda environment if not already
pip install -r requirements.txt
jupyter-book build ese532_handouts/
```
And then browse locally by opening the `index.html` in the `_build/html`
folder.

**For course admins**:
Copy `_build/html/*` to the `handouts` folder of the course website