library(tidyverse) # all the things
library(rvest) # webscraping
library(glue) # easily interpret R code inside of strings
library(sometools) # my own personal package

avatar_wiki <- read_html("https://avatar.fandom.com/wiki/Avatar_Wiki:Transcripts")

chapters <- avatar_wiki %>%
    html_nodes("td") %>%
    html_text()

# to see rows with too much text that are actually many chapters

# chapters %>%
#     enframe(name = "row_num", value = "chapter") %>%
#     filter(row_num %in% 1:70) %>%
#     mutate(len = str_length(chapter)) %>%
#     arrange(desc(len))

chapters <- chapters %>%
    enframe(name = "row_num", value = "chapter") %>%
    filter(row_num %in% 1:70) %>%
    mutate(len = str_length(chapter)) %>%
    filter(len < 50) %>%
    mutate(chapter = str_remove_all(chapter, pattern = "\""),
           chapter = str_trim(chapter, side = "both"),
           chapter = str_remove_all(chapter, " \\(commentary\\)")) %>%
    filter( !(chapter %in% c("Unaired pilot", "Escape from the Spirit World")) )

iceberg <- read_html("https://avatar.fandom.com/wiki/Transcript:The_Boy_in_the_Iceberg")

characters <- iceberg %>%
    html_nodes("table.wikitable") %>%
    html_table() %>%
    pluck(1) %>%
    simplify() %>%
    enframe(value = "value1") %>%
    mutate(chapter1 = "https://avatar.fandom.com/wiki/Transcript:The_Boy_in_the_Iceberg") %>%
    select(-name)

text <- iceberg %>%
    html_nodes("table.wikitable") %>%
    html_table() %>%
    pluck(2) %>%
    simplify() %>%
    enframe(value = "value2") %>%
    mutate(chapter2 = "https://avatar.fandom.com/wiki/Transcript:The_Boy_in_the_Iceberg") %>%
    select(-name)

iceberg2 <- bind_cols(characters, text) %>%
    rename(character = value1, text = value2)

returns <- read_html("https://avatar.fandom.com/wiki/Transcript:The_Avatar_Returns")

characters2 <- returns %>%
    html_nodes("table.wikitable") %>%
    html_table() %>%
    pluck(1) %>%
    simplify() %>%
    enframe(value = "value1") %>%
    mutate(chapter1 = "https://avatar.fandom.com/wiki/Transcript:The_Avatar_Returns") %>%
    select(-name)

text2 <- returns %>%
    html_nodes("table.wikitable") %>%
    html_table() %>%
    pluck(2) %>%
    simplify() %>%
    enframe(value = "value2") %>%
    mutate(chapter2 = "https://avatar.fandom.com/wiki/Transcript:The_Avatar_Returns") %>%
    select(-name)

returns2 <- bind_cols(characters2, text2) %>%
    rename(character = value1, text = value2)

# iceberg2
# returns2

# join the two lists

# first two are different, the rest just look like one list each

chapter_urls <- chapters %>%
    filter( !(chapter %in% c("The Boy in the Iceberg", "The Avatar Returns")) ) %>%
    mutate(chapter = str_replace_all(chapter, pattern = " ", replacement = "_"),
           chapter = str_replace_all(chapter, pattern = "\'", replacement = "%27")) %>%
    pull(chapter)

full_urls <- glue("https://avatar.fandom.com/wiki/Transcript:{chapter_urls}")

characters_all <- full_urls %>%
    map(~ read_html(.x) %>%
            html_nodes("table.wikitable") %>%
            html_table() %>%
            pluck("X1") %>%
            simplify() %>%
            enframe() %>%
            mutate(chapter = .x))

transcripts_all <- full_urls %>%
    map(~ read_html(.x) %>%
            html_nodes("table.wikitable") %>%
            html_table() %>%
            pluck("X2") %>%
            simplify() %>%
            enframe() %>%
            mutate(chapter = .x))

characters_all2 <- characters_all %>%
  modify_at(33, ~ filter(.x, row_number() != 178)) %>%
  bind_rows()

transcripts_all2 <- transcripts_all %>%
  modify_at(33, ~ unnest(.x, cols = value)) %>%
  bind_rows()

full_transcript <- bind_cols(
  characters_all2 %>% select(character = value, chapter1 = chapter),
  transcripts_all2 %>% select(text = value, chapter2 = chapter))

dat <- bind_rows(iceberg2, returns2, full_transcript)

dat <- dat %>%
  select(character, text, chapter = chapter1) %>%
  mutate(
    chapter = str_remove_all(chapter, "https://avatar.fandom.com/wiki/Transcript:"),
    chapter = str_replace_all(chapter, "_", " "),
    chapter = str_replace_all(chapter, pattern = "%27", replacement = "\'")) %>%
  left_join(
    chapters %>%
  mutate(
    book = case_when(
      row_number() %in% 1:20  ~ "Water",
      row_number() %in% 21:40 ~ "Earth",
      TRUE                    ~ "Fire"
    )
  ) %>%
  group_by(book) %>%
  mutate(
    chapter_num = row_number()
  ) %>%
  ungroup() %>%
  mutate(
    book_num = case_when(
      book == "Water" ~ 1L,
      book == "Earth" ~ 2L,
      book == "Fire"  ~ 3L
    )
  ) %>%
  select(chapter, chapter_num, book, book_num)) %>%
  mutate(id = row_number(),
         character = ifelse(character == "", "Scene Description", character))

dat_transcript <- dat %>%
  mutate(scene_description = str_extract_all(text, pattern = "\\[[^\\]]+\\]"),
         character_words = str_remove_all(text, pattern = "\\[[^\\]]+\\]"),
         character_words = ifelse(character == "Scene Description",
                                  NA_character_,
                                  str_trim(character_words))) %>%
  select(id, book, book_num, chapter, chapter_num,
         character, full_text = text, character_words, scene_description)

iceberg_overview <- read_html("https://avatar.fandom.com/wiki/The_Boy_in_the_Iceberg")

iceberg_overview %>%
  html_nodes(".pi-border-color") %>%
  html_text()

chapter_urls2 <- chapters %>%
  mutate(chapter = str_replace_all(chapter, pattern = " ", replacement = "_"),
         chapter = str_replace_all(chapter, pattern = "\'", replacement = "%27"),
         chapter = case_when(
           chapter == "Jet"         ~ "Jet_(episode)",
           chapter == "Lake_Laogai" ~ "Lake_Laogai_(episode)",
           TRUE                     ~ chapter

         )) %>%
  pull(chapter)

overview_urls <- glue("https://avatar.fandom.com/wiki/{chapter_urls2}")

# do it once

# overview_urls[1] %>%
#   read_html() %>%
#   html_nodes(".pi-border-color") %>%
#   html_text() %>%
#   .[6:7] %>%
#   enframe() %>%
#   mutate(value = str_trim(value)) %>%
#   separate(col = value, into = c("role", "name"), sep = " by") %>%
#   mutate(name = str_trim(name)) %>%
#   pivot_wider(names_from = role, values_from = name)

# then iterate

writers_directors <- overview_urls %>%
  map_dfr( ~ read_html(.x) %>% html_nodes(".pi-border-color") %>%
    html_text() %>% .[6:7] %>% enframe() %>%
    mutate(value = str_trim(value)) %>%
    separate(col = value, into = c("role", "name"), sep = " by") %>%
    mutate(name = str_trim(name)) %>%
    pivot_wider(names_from = role, values_from = name) %>%
    mutate(url = .x))

writers_directors2 <- writers_directors %>%
  mutate(
    url = str_remove(url, "https://avatar.fandom.com/wiki/"),
    url = str_replace_all(url, "_", " "),
    url = str_remove(url, " \\(episode\\)"),
    url = str_replace_all(url, pattern = "%27", replacement = "\'"),
    Written = str_replace(Written, " Additional writing: ", ", ")
  ) %>%
  rename(chapter = url, writer = Written, director = Directed)

dat2 <- dat_transcript %>%
  left_join(
    writers_directors2, by = "chapter"
  )

imdb_raw <- read_html("https://www.imdb.com/list/ls079841896/")

chapter_names <- chapters %>% pull(chapter) %>%
  str_flatten(collapse = "|")

imdb_chapters <- imdb_raw %>%
html_nodes("h3.lister-item-header") %>%
  html_text() %>%
  enframe() %>%
  mutate(value = str_extract(value, pattern = chapter_names),
         value = case_when(
           name == 29 ~ "Winter Solstice, Part 2: Avatar Roku",
           name == 44 ~ "The Boiling Rock, Part 1",
           name == 52 ~ "Winter Solstice, Part 1: The Spirit World",
           TRUE       ~ value
         ))

imdb_ratings <- imdb_raw %>%
html_nodes("div.ipl-rating-widget") %>%
  html_text() %>%
  enframe() %>%
  mutate(value = parse_number(value))

imdb <- bind_cols(imdb_chapters, imdb_ratings) %>%
  select(chapter = 2, rating = 4) %>%
  right_join(chapters) %>%
  select(chapter, imdb_rating = rating)

dat3 <- dat2 %>% left_join(imdb, by = "chapter") %>%
  mutate(book = as_factor(book),
         chapter = as_factor(chapter))

appa <- dat3

usethis::use_data(appa, overwrite = TRUE)
