# DevOps for Data Science Project (sample)

Lab exercise from DevOps for Data Science.

### For Python: 

1. added `uv`, then `uv init`
2. `uv venv`to add venv for the project (`.venv` was already in .gitignore)
3. Used `uv add -r requirements.txt` since I had already a `requirement.txt`


### For R: 

1. [{renv}](https://rstudio.github.io/renv/) was used (`renv::init`)
2. restart R 
3. `renv::status()` to check 
    - Missing system libraries
    - You should install needed packages as usual 
    - `renv::update()` will update packages 
    - `renv::snapshot()` after that to update tje lockfile 
4. `renv::restore()` install the packages level

useful commands: 

- `uv sync`
- `source .venv/bin/activate`

Notes Olivier: 

I had some issues `pkg_resources`, it was imported by palmerpenguins and was not present in `requirements.txt`. It seems to be part of setuptools that may or not be install at the system layer (who knows!) and is a "deprecated as an API". Updating some package help but their reverse dependencies were requiring a more recent Python version or pinpointing the last version of said packages with the specific version. 

Since palmerpenguins is just a table, I will use the R version to shortcut that..  