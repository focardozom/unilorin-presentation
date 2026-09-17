# University of Ilorin — From field notes to a database

Guest workshop: take one recess ethnography, extract one social network,
then add node attributes with `ellmer`.

Do **not** use `quarto preview` in Dropbox — it loops. Render once:

```bash
quarto render index.qmd --to revealjs
open _site/index.html
```

In Cursor: Render once (not Preview), and keep **Render on Save** off.

## Timing (90 minutes)

| Block | Minutes | What |
|------:|--------:|------|
| Why code | 12 | Chat is not a method; the R trail |
| Security | 10 | Privacy vs security; store the key |
| Ethnography | 10 | Silent read of `school-obs.md` |
| Structured extraction | 10 | Schema, `$chat_structured()`, quotes |
| Round 1 ties | 20 | One edge list; audit soccer first |
| Round 2 nodes | 15 | Attributes; grade only if stated |
| Assemble + close | 13 | Two CSVs; share-out |

For 60 minutes: keep security, skip the live chat demo, and shorten the soccer audit.

## Files

```
├── index.qmd                 slides
├── school-obs.md             recess vignette (synthetic)
├── extract_playground.R      live extraction script
├── plot_networks.R           tidygraph figures for the slides
├── results/                  audited edges.csv and nodes.csv
├── images/                   network SVGs and courtyard figure
└── prompts/
    ├── extract_ties.md
    └── extract_nodes.md
```

Working directory for the lab: this folder. Run the code from the slides in R,
or source `extract_playground.R`.

## Lab setup

```r
install.packages(c("tidyverse", "ellmer", "usethis"))
usethis::edit_r_environ()
```

Add **one** line to `~/.Renviron` (no quotes), save, and **restart R**:

```
GOOGLE_API_KEY=paste-the-value-here
```

Confirm with `nzchar(Sys.getenv("GOOGLE_API_KEY"))`. Never print the key while
projecting, and never commit it.

The vignette is a **composite teaching observation**. No real students. Do not
send identifiable field notes to a public API.
