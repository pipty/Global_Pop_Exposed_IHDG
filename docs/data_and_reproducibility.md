# Data and Reproducibility Notes

This repository is designed to make the published outputs and analytical logic easier to inspect without redistributing internal working files or third-party datasets.

## Data categories used in the study

The analysis combined gridded and tabular data sources representing:

- annual greenness indicators, including NDVI;
- heat exposure indicators, including UTCI-derived measures;
- gridded population counts from 2000 to 2022;
- country, continent, income group, and urbanicity classifications;
- age structure summaries used for demographic stratification.

Users who want to reproduce the analysis should obtain the relevant datasets from their original providers and check each provider's license, citation, and redistribution requirements.

## What is intentionally not included

The repository does not include:

- raw geospatial rasters;
- shapefiles or gridded demographic products;
- `.RData`, `.rds`, database, DBF, or large CSV intermediate files;
- local project paths or machine-specific processing scripts;
- manuscript submission correspondence or editorial files.

## Public analysis framework

The script in `analysis-framework/ihdg_workflow_skeleton.R` gives the public structure of the analysis. It is not a drop-in reproduction package. It is intended to document the main steps:

1. prepare annual heat and greenness indicators;
2. align indicators to populated grid cells;
3. estimate heat and greenness trends;
4. classify increasing heat plus decreasing greenness;
5. aggregate exposed population by major strata;
6. create figures and summary outputs.

## Figure provenance

The files in `figures/` are exported publication figures from the accepted article files. They are provided to support reading, presentation, and scholarly discussion of the published study.
