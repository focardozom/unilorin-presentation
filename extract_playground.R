# University of Ilorin - extract a playground network from ethnography
# Prompts: UNILORIN-presentation/prompts/
# Text:    UNILORIN-presentation/school-obs.md
# Never commit keys. Do not send real field notes / PHI / identifiable students.

library(tidyverse)
library(ellmer)

# ---------------------------------------------------------------------------
# Paths and one-call helpers
# ---------------------------------------------------------------------------
workshop_root <- function() {
  start <- getwd()
  candidates <- accumulate(
    seq_len(8),
    \(path, i) dirname(path),
    .init = start
  ) |>
    unique()

  found <- detect(
    candidates,
    \(path) file.exists(file.path(path, "school-obs.md")) &&
      dir.exists(file.path(path, "prompts"))
  )

  if (is.null(found)) {
    stop(
      "Cannot find school-obs.md. Open UNILORIN-presentation/ as the ",
      "working directory, then run this script.",
      call. = FALSE
    )
  }

  found
}

read_workshop_file <- function(...) {
  path <- file.path(workshop_root(), ...)
  if (!file.exists(path)) {
    stop("Missing file: ", path, call. = FALSE)
  }
  read_file(path)
}

new_chat <- function() {
  keys <- c(
    GOOGLE_API_KEY = "gemini",
    ANTHROPIC_API_KEY = "anthropic",
    OPENAI_API_KEY = "openai"
  )
  found <- keys[nzchar(Sys.getenv(names(keys)))]

  if (length(found) == 0) {
    stop(
      "No API key visible to this R session. ",
      "Add GOOGLE_API_KEY to ~/.Renviron (see the slides), save, restart R.",
      call. = FALSE
    )
  }

  switch(
    found[[1]],
    gemini = chat_google_gemini(),
    anthropic = chat_anthropic(),
    openai = chat_openai()
  )
}

extract_with <- function(prompt_file, text, schema) {
  chat <- new_chat()
  instructions <- read_workshop_file("prompts", prompt_file)
  chat$chat_structured(
    str_c(instructions, "\n\nTEXT:\n", text),
    type = schema
  )
}

obs <- read_workshop_file("school-obs.md")

# ---------------------------------------------------------------------------
# 0) Toy - confirm chat_structured returns a list
# ---------------------------------------------------------------------------
chat_toy <- new_chat()
toy <- chat_toy$chat_structured(
  "My name is Susan and I'm 13 years old",
  type = type_object(
    name = type_string(),
    age = type_number()
  )
)
str(toy)

# ---------------------------------------------------------------------------
# Round 1 - ties (the edge list)
# ---------------------------------------------------------------------------
tie <- type_object(
  "One undirected tie the text supports. Prefer omit over invention.",
  person_from = type_string("Person at one end; Amara is one person"),
  person_to = type_string("Person at the other end; one name per person"),
  tie = type_enum(
    c(
      "affiliation",
      "play",
      "conflict",
      "exclusion",
      "help",
      "authority",
      "other"
    ),
    "Best-fitting label; use other if the list does not fit"
  ),
  evidence_quote = type_string(
    "Short quote from the text that supports this tie"
  )
)

ties <- type_array(
  tie,
  "Distinct ties stated in the text. Do not invent. Shared courtyard is not a tie."
)

edges <- extract_with("extract_ties.md", obs, ties)
edges

people_from_edges <- edges |>
  pivot_longer(
    cols = c(person_from, person_to),
    values_to = "person"
  ) |>
  distinct(person)

people_from_edges

# Instructor gold (not a model output) - audit these first:
# affiliation: Ezekiel-Kwame-Lukas-Henrik (arrive together)
# affiliation: Amara-Valentina-Sophie (walk together)
# exclusion:   Valentina / Amara vs Ezekiel ("We already started")
# authority:   Ngozi - children on the soccer field
# play:        Andrés-Oliver-Chidi-James
# conflict:    Andrés-Oliver (out of bounds)
# affiliation: Mateo-Thabo (share cookies)
# conflict:    Isabella-Mariana (rules)
# exclusion:   Mariana-Imani-Camila leave when Emma arrives
# help:        Imani, Chidi, James, Noah - Zainab
# Not ties:    Thabo laughing at basketball; watching soccer ≠ playing;
#              crowd around Zainab ≠ friendship; Noah is not on the soccer team

# ---------------------------------------------------------------------------
# Round 2 - node attributes
# ---------------------------------------------------------------------------
person <- type_object(
  "One named person. Omit invented biography.",
  name = type_string("Canonical first name as written"),
  role = type_enum(
    c("student", "teacher", "other"),
    "Only if the text supports it"
  ),
  grade = type_string(
    "Grade only if stated (fifth, third). Empty string if unknown."
  ),
  location = type_enum(
    c(
      "soccer_field",
      "basketball_court",
      "cafeteria_benches",
      "concrete_tables",
      "school_store",
      "other"
    ),
    "Where we see them most in these notes"
  ),
  activity = type_string("What they are doing there, in a few words"),
  evidence_quote = type_string("Short quote that supports role or location")
)

people <- type_array(
  person,
  "One row per named person. Do not add unnamed children in the crowd."
)

nodes <- extract_with("extract_nodes.md", obs, people)
nodes

# Instructor gold:
# grade stated: Ezekiel (fifth-grade hallway), Noah (third-grade)
# teacher:      Ngozi only
# do not infer gender; do not guess everyone else is fifth grade

# ---------------------------------------------------------------------------
# Assemble the database
# ---------------------------------------------------------------------------
out_dir <- file.path(workshop_root(), "output")
dir.create(out_dir, showWarnings = FALSE)

write_csv(edges, file.path(out_dir, "edges.csv"))
write_csv(nodes, file.path(out_dir, "nodes.csv"))

# Names in the edge list that never got node attributes (or the reverse)
edge_names <- people_from_edges |>
  pull(person)
node_names <- nodes |>
  pull(name)

mismatch <- setdiff(
  union(edge_names, node_names),
  intersect(edge_names, node_names)
)

tibble(
  person = mismatch,
  in_edges = mismatch %in% edge_names,
  in_nodes = mismatch %in% node_names
)

# Optional sketch of the graph (no extra packages)
edges |>
  transmute(line = str_c(person_from, " --", tie, "-- ", person_to)) |>
  pull(line) |>
  writeLines()
