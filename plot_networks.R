# Audited playground network (not a live model call).
# Writes results/*.csv and images/network-*.svg for the Unilorin slides.
# Run from UNILORIN-presentation/. Slides use eval: false and the saved SVGs.

library(tidyverse)
library(tidygraph)
library(ggraph)

root <- if (file.exists("school-obs.md")) {
  normalizePath(".")
} else if (file.exists("UNILORIN-presentation/school-obs.md")) {
  normalizePath("UNILORIN-presentation")
} else {
  stop("Open UNILORIN-presentation/ and source this file.")
}

results_dir <- file.path(root, "results")
images_dir <- file.path(root, "images")
dir.create(results_dir, showWarnings = FALSE)
dir.create(images_dir, showWarnings = FALSE)

edges <- tribble(
  ~person_from, ~person_to, ~tie, ~evidence_quote,
  "Ezekiel", "Kwame", "affiliation", "emerged from the fifth-grade hallway with Kwame, Lukas, and Henrik",
  "Ezekiel", "Lukas", "affiliation", "emerged from the fifth-grade hallway with Kwame, Lukas, and Henrik",
  "Ezekiel", "Henrik", "affiliation", "emerged from the fifth-grade hallway with Kwame, Lukas, and Henrik",
  "Kwame", "Lukas", "affiliation", "the four boys ran toward the field together",
  "Kwame", "Henrik", "affiliation", "Kwame and Henrik stood behind the net waiting",
  "Lukas", "Henrik", "affiliation", "the four boys ran toward the field together",
  "Amara", "Valentina", "affiliation", "Amara and Valentina were walking with Sophie",
  "Amara", "Sophie", "affiliation", "Amara and Valentina were walking with Sophie",
  "Valentina", "Sophie", "affiliation", "Amara and Valentina were walking with Sophie",
  "Valentina", "Henrik", "other", "Can we play?",
  "Valentina", "Ezekiel", "exclusion", "We already started.",
  "Ngozi", "Ezekiel", "authority", "Ngozi instructed the children to reorganize the teams",
  "Ngozi", "Valentina", "authority", "What's happening here?",
  "Henrik", "Valentina", "help", "Henrik handed a training vest to Valentina",
  "Andrés", "Oliver", "play", "already midway through a game",
  "Andrés", "Chidi", "play", "already midway through a game",
  "Andrés", "James", "play", "already midway through a game",
  "Oliver", "Chidi", "play", "already midway through a game",
  "Oliver", "James", "play", "already midway through a game",
  "Chidi", "James", "play", "already midway through a game",
  "Andrés", "Oliver", "conflict", "That was out!",
  "Mateo", "Thabo", "affiliation", "sat sharing a package of cookies",
  "Isabella", "Mariana", "conflict", "You can't change the rules now",
  "Emma", "Isabella", "affiliation", "sitting with Isabella and Sofía",
  "Emma", "Sofía", "affiliation", "sitting with Isabella and Sofía",
  "Isabella", "Sofía", "affiliation", "sitting with Isabella and Sofía",
  "Mariana", "Imani", "affiliation", "Imani immediately stood up and followed her",
  "Mariana", "Camila", "affiliation", "Camila followed a few seconds later",
  "Imani", "Camila", "affiliation", "entered the building together",
  "Mariana", "Emma", "exclusion", "Let's go over there",
  "Imani", "Emma", "exclusion", "Imani immediately stood up and followed her",
  "Camila", "Emma", "exclusion", "Camila followed a few seconds later",
  "Imani", "Zainab", "help", "What happened?",
  "Chidi", "Zainab", "help", "Chidi began searching beneath a nearby bench",
  "James", "Zainab", "help", "James checked around the entrance to the cafeteria",
  "Noah", "Zainab", "help", "Noah, a third-grade student, lifted a crumpled five-thousand-peso bill"
)

nodes <- tribble(
  ~name, ~role, ~grade, ~location, ~activity,
  "Ezekiel", "student", "fifth", "soccer_field", "organizing teams",
  "Kwame", "student", "", "soccer_field", "naming players",
  "Lukas", "student", "", "soccer_field", "brought the ball",
  "Henrik", "student", "", "soccer_field", "on the field",
  "Amara", "student", "", "soccer_field", "watching from the sideline",
  "Valentina", "student", "", "soccer_field", "asking to play",
  "Sophie", "student", "", "soccer_field", "watching",
  "Ngozi", "teacher", "", "soccer_field", "intervening",
  "Andrés", "student", "", "basketball_court", "directing play",
  "Oliver", "student", "", "basketball_court", "dribbling",
  "Chidi", "student", "", "basketball_court", "waiting with the ball",
  "James", "student", "", "basketball_court", "playing",
  "Mateo", "student", "", "cafeteria_benches", "sharing cookies",
  "Thabo", "student", "", "cafeteria_benches", "sharing cookies",
  "Emma", "student", "", "concrete_tables", "left with juice",
  "Isabella", "student", "", "concrete_tables", "arguing rules",
  "Sofía", "student", "", "concrete_tables", "stayed at the table",
  "Mariana", "student", "", "concrete_tables", "gathering papers",
  "Imani", "student", "", "concrete_tables", "followed Mariana",
  "Camila", "student", "", "concrete_tables", "followed Mariana",
  "Zainab", "student", "", "school_store", "lost a bill",
  "Noah", "student", "third", "school_store", "found the bill"
)

write_csv(edges, file.path(results_dir, "edges.csv"))
write_csv(nodes, file.path(results_dir, "nodes.csv"))

edges_graph <- edges |>
  rename(from = person_from, to = person_to)

net <- tbl_graph(
  nodes = nodes,
  edges = edges_graph,
  directed = FALSE,
  node_key = "name"
)

tie_cols <- c(
  affiliation = "#5c6b7a",
  play = "#005030",
  conflict = "#e85d04",
  exclusion = "#9b2226",
  help = "#2a6f97",
  authority = "#b08900",
  other = "#6c757d"
)

loc_cols <- c(
  soccer_field = "#005030",
  basketball_court = "#e85d04",
  cafeteria_benches = "#5c6b7a",
  concrete_tables = "#2a6f97",
  school_store = "#b08900"
)

base_theme <- theme_void() +
  theme(
    legend.position = "bottom",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    plot.margin = margin(12, 12, 12, 12)
  )

set.seed(16)
p_ties <- ggraph(net, layout = "kk") +
  geom_edge_fan(aes(color = tie), width = 0.8, strength = 0.8) +
  geom_node_point(size = 5, color = "#1c2430") +
  geom_node_text(aes(label = name), repel = TRUE, size = 3.2, color = "#1c2430") +
  scale_edge_color_manual(values = tie_cols, name = "tie") +
  base_theme

ggsave(
  file.path(images_dir, "network-ties.svg"),
  p_ties,
  width = 12.8,
  height = 7.2,
  bg = "white"
)

loc_xy <- tibble(
  location = c(
    "soccer_field", "basketball_court", "cafeteria_benches",
    "concrete_tables", "school_store"
  ),
  x0 = c(0.15, 0.85, 0.12, 0.48, 0.88),
  y0 = c(0.72, 0.72, 0.22, 0.28, 0.22)
)

nodes_xy <- nodes |>
  left_join(loc_xy, by = "location") |>
  group_by(location) |>
  mutate(
    n = n(),
    i = row_number() - 1,
    angle = if_else(n == 1, 0, 2 * pi * i / n),
    radius = if_else(n == 1, 0, 0.12),
    x = x0 + radius * cos(angle),
    y = y0 + radius * sin(angle)
  ) |>
  ungroup() |>
  select(name, role, grade, location, activity, x, y)

net_xy <- tbl_graph(
  nodes = nodes_xy,
  edges = edges_graph,
  directed = FALSE,
  node_key = "name"
)

p_loc <- ggraph(net_xy, layout = "manual", x = x, y = y) +
  geom_edge_fan(aes(color = tie), width = 0.75, strength = 0.6, alpha = 0.85) +
  geom_node_point(aes(color = location, shape = role), size = 6) +
  geom_node_text(aes(label = name), repel = TRUE, size = 3.1, color = "#1c2430") +
  scale_edge_color_manual(values = tie_cols, name = "tie") +
  scale_color_manual(values = loc_cols, name = "location") +
  scale_shape_manual(values = c(student = 16, teacher = 17), name = "role") +
  coord_fixed(xlim = c(-0.05, 1.05), ylim = c(-0.02, 0.95), expand = FALSE) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.box = "vertical",
    legend.title = element_text(size = 11),
    legend.text = element_text(size = 10),
    plot.margin = margin(8, 8, 8, 8)
  )

ggsave(
  file.path(images_dir, "network-by-location.svg"),
  p_loc,
  width = 12.8,
  height = 7.2,
  bg = "white"
)

message("Wrote results/edges.csv, results/nodes.csv")
message("Wrote images/network-ties.svg, images/network-by-location.svg")
