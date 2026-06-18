# Global Population Exposed to Increasing Heat but Decreasing Greenness

This repository shares selected public-facing outputs and a reproducible analysis framework for the article:

> Ye T, Xu R, Huang W, Yang Z, Yu P, Yu W, Liu Y, Wu Y, Wen B, Zhang Y, Hart JE, Nieuwenhuijsen M, Abramson MJ, Guo Y, Li S. **Billions of people exposed to increasing heat but decreasing greenness from 2000 to 2022**. *The Innovation*. Published online March 7, 2025. https://doi.org/10.1016/j.xinn.2025.100870

The study assessed global exposure to areas experiencing increasing heat but decreasing greenness (IHDG) from 2000 to 2022, with stratification by geography, income group, urbanicity, and population age structure.

## Repository contents

- `figures/`: published article figures and graphical abstract.
- `analysis-framework/`: a public, simplified R workflow skeleton describing the main analytical steps.
- `docs/`: notes on data access, reproducibility boundaries, and figure provenance.

## Key public summary

- 69.3% of global populated areas experienced increasing heat but decreasing greenness.
- 41.3% of the global population, approximately 2.9 billion people, was exposed to IHDG.
- Low- and middle-income countries bore most of this burden.
- Urban areas were more affected than rural areas.
- Populations exposed to IHDG showed an accelerated aging trend.

## Figures

The article figures are available in [`figures/`](figures/):

- [`graphical_abstract.pdf`](figures/graphical_abstract.pdf) and [`graphical_abstract.png`](figures/graphical_abstract.png)
- [`figure_1.pdf`](figures/figure_1.pdf)
- [`figure_2.pdf`](figures/figure_2.pdf)
- [`figure_3.pdf`](figures/figure_3.pdf)
- [`figure_4.pdf`](figures/figure_4.pdf)
- [`figure_5.pdf`](figures/figure_5.pdf)

## Analysis framework

The full internal analysis project contains local paths, intermediate files, and data products that are not prepared for direct public release. Instead, this repository provides a clean framework script:

- [`analysis-framework/ihdg_workflow_skeleton.R`](analysis-framework/ihdg_workflow_skeleton.R)

It documents the core workflow:

1. Build annual heat and greenness indicators.
2. Align raster indicators with populated grid cells.
3. Estimate long-term trends for heat and greenness.
4. Classify populated cells into IHDG and other trend combinations.
5. Aggregate exposed populations by country, income group, continent, urbanicity, and age group.
6. Generate publication figures and summary tables.

## Data availability

This repository does not redistribute third-party geospatial, demographic, or climate datasets. See [`docs/data_and_reproducibility.md`](docs/data_and_reproducibility.md) for the data categories used and guidance for reproducing the analysis with appropriately licensed data sources.

## License and citation

The article is open access under the license stated by the journal. The public figures in this repository are shared for scholarly communication related to the published article. Please cite the article above when using or discussing these materials.
