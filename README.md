# Accompanying notebook to *Make Reddit Great Again*

This repository contains an [R Markdown](http://rmarkdown.rstudio.com) notebook and respective code
that shows how to derive the main results of the article
"Make Reddit Great Again: Assessing Community Effects of Moderation Interventions on r/The_Donald".

- [**Dataset files**](https://doi.org/10.5281/zenodo.6250577)
- [**Rendered notebook**](https://amauryt.github.io/make_reddit_great_again/)

The article is available as a [preprint on arXiv](https://arxiv.org/abs/2201.06455).
If you use the approach and or functions on this repository on your own research, please cite:

```
@misc{trujillo2022make,
      title={Make Reddit Great Again: Assessing Community Effects of Moderation Interventions on r/The_Donald}, 
      author={Amaury Trujillo and Stefano Cresci},
      year={2022},
      eprint={2201.06455},
      archivePrefix={arXiv},
      primaryClass={cs.SI}
}
```

## Re-running and Customization 

### Prerequisites

First of all, read the aforementioned paper to understand the notebook contents.
Then, download the corresponding dataset files from Zenodo.
Finally, install the required R packages used for the analyses.

### Dataset

Download all of the dataset files from the Zenodo platform (see link above) and put them into the subdirectory `data`.
The subdirectory must have the following files:

 - the_donald.sqlite
 - core_the_donald.sqlite
 - mbfc_scores.csv

#### R packages

The notebook/code requires the following R packages:

  - `data.table`: efficient manipulation of data
  - `RSQLite`: DBI client for SQLite
  - `checkmate`: function argument checking
  - `ggplot2`: create graphics declaratively
  - `colorspace`: manipulation of colors and palettes
  - `zoo`: regular and irregular time-series
  - `CausalImpact`: causal inference using bayesian structural time-series (BSTS) models

See the R Session information at the end of the rendered notebook for more details on environment and
package versions used.

### Custom dataset

**Please note that we will not follow up requests regarding technical support on customization, as it is outside the scope of our work.**

If you want to use a custom dataset, it is better to collect the Reddit data from [Pushshift](https://pushshift.io/),
either the API or monthly dump files.
To work with the freshest content the use of the [Reddit API](https://www.reddit.com/dev/api/) is also possible,
but subject to different constraints.
To score the toxicity of comments using the [Perspective API](https://www.perspectiveapi.com/),
you need to create an account; see the website for more details.
You can work directly with the Perspective API or use a wrapper
such as the [peRspective](https://github.com/favstats/peRspective) package.

Once you have collected the data, build an SQLite database with the same schema as the ones used here,
which are described in the respective Zenodo dataset description.
Regarding the ID of Reddit entities, it is suggested to change it from base 36 (alphanumeric) to base
10 (numeric) for performance reasons, albeit the notebook should work with alphanumeric IDs with minimal modification.

Remember to modify the code in the script R files at the root directory according to your needs!

The order of the sourced scripts in the notebook is important:

  1. common_variables.R
  2. db_utils.R
  3. data_wrangling.R
  4. plot_utils.R

