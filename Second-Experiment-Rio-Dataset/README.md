# Experiment on AlertaRio's dataset

This folder contains my main experiments on AlertaRio's dataset. This folder contains :

- 2 scripts :
  - One to generate the CSV files from the txt files of AlertaRio's dataset
  - One to unzip the archive provided by the AlertaRio's [website](http://alertario.rio.rj.gov.br/)
- 5 Jupyter Notebook :
  - The Data preprocessing notebook that runs the script to generate all the files needed for the experiments
  - The Data visualization notebook that includes some visualization on AlertaRio's dataset and explain my weather station choice
  - The first experiment doing one feature prediction
  - The first experiment doing multiple features prediction
  - The second experiment

## Get the data

The dataset can be downloaded on [AlertaRio's download page](http://alertario.rio.rj.gov.br/download/), then put the archive under the path data/archive. Then use the [Data preprocessing notebook](Data-visualization.ipynb) to generate the CSV files.

## Experiments

### First experiment monofeature

This experiment use a XGBoost regressor to predict one feature (usually the cumulative rain) from the N previous points.

### First experiment multifeatures

This experiment use a XGBoost regressor to predict all the features from the N previous points.

### Second experiment

This experiment use N previous points to predict the cumulative rain of the next M points.
