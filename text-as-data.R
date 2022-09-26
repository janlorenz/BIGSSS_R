library(tidyverse)
library(pdftools)
library(quanteda)
library(quanteda.textstats)
library(seededlda)

# We read the text from the pdf
rawtext <- pdf_text("BIGSSS Cohort 2022.pdf")

# We make a nice tabular data frame out of it
fellows22 <- rawtext |> 
  paste(collapse = "") |> 
  str_split("\n") |> unlist() |> as_tibble() |> 
  mutate(start = str_detect(value, "@"),
         id = cumsum(start)) |> 
  filter(id > 0) |> 
  group_by(id) |> 
  mutate(Name = value[1] |> word(4,-3) |> str_trim()) |> 
  slice(-1) |> 
  mutate(Degree = value[str_detect(value, "Degree    ")] |> word(2,-1) |> str_trim()) |> 
  filter(!str_detect(value, "Degree    ")) |> 
  mutate(Current_position = value[str_which(value, "Current position  "):(str_which(value, "Current position  ")+1)] |> 
            paste(collapse = " ") |> word(3,-1) |> str_squish()) |> 
  slice(-(str_which(value, "Current position  "):(str_which(value, "Current position  ")+1))) |> 
  mutate(Proposed_doctoral_research = 
           c(value[str_which(value, "Proposed doctoral  ")] |> word(3,-1) |> str_squish(), 
             value[str_which(value, "Proposed doctoral  ")+1] |> word(2,-1) |> str_squish(),
             value[str_which(value, "Proposed doctoral  ")+2] |> str_squish()) |> 
           paste(collapse = " ")) |> 
  slice(-(str_which(value, "Proposed doctoral  "):(str_which(value, "Proposed doctoral  ")+2))) |> 
  filter(!str_detect(value,"Affiliated Fellows") & !str_detect(value,"These fellows are") & !str_detect(value,"Adjunct Fellows")) |> 
  mutate(value = value |> str_remove("Methods experience  ") |> str_trim()) |> 
  mutate(value = value |> str_remove("Methods ") |> str_remove("experience  ") |> str_trim()) |> 
  # Next: filter rows with numbers-
  filter(str_length(value) == 0 | str_length(value)>2) |> 
  group_by(Name, Degree, Current_position, Proposed_doctoral_research) |> 
  summarize(Methods = value |> paste(collapse = " ") |> str_trim(), .groups = "drop")
  


# Now we follow some steps of the Quanteda tutorial https://tutorials.quanteda.io:
# -   Create a corpus from the dataframe
# -   Tokenize
# -   Document-Feature Matrix
# -   Remove stopwords
# -   Topic model


# Create corpus from text, tokenize it
corp_fellows <- fellows22 |> 
  corpus(text_field = "Methods") 
print(corp_fellows)

corp_fellows_toks <- corp_fellows |> 
  tokens(remove_punct = TRUE, remove_url = TRUE, remove_symbols = TRUE)
tokens(corp_fellows_toks)

# We can check "keywords in context" (kwic) like this to get some insight
corp_fellows_toks |> kwic(pattern = "course*") |> head()
corp_fellows_toks |> kwic(pattern = "policy") |> head()
corp_fellows_toks |> kwic(pattern = "stat*") |> head()

# create document-work(feature)-matrix and remove English stopwords and words with 1 character
corp_fellows_dfm <- corp_fellows_toks |> 
  dfm() |> dfm_remove(pattern = stopwords("en")) |> 
  dfm_keep(min_nchar = 2)

# Frequency statistics 
corp_fellows_dfm |> textstat_frequency() |> head(20)

# Topic model
fellows_lda <- corp_fellows_dfm |> textmodel_lda(k = 10)

# These words characterize the topics
terms(fellows_lda) 

# These are the most relevant topics of fellows
topics(fellows_lda)


# Join the main topic to the threads table and show those with most width
fellows22_top <- fellows22 |>
  mutate(policy_degree = str_detect(Degree, "Polic")) |> 
  mutate(main_topic = topics(fellows_lda)) |> 
  select(Name,main_topic,everything()) |> 
  bind_cols(fellows_lda$theta)


fellows22_top |> 
  pivot_longer(starts_with("topic"), names_to = "Topic") |> 
  # group_by(Name) |> 
  # summarise(sum(value))
  ggplot(aes(x = Topic, y = value, fill = policy_degree)) +
  geom_col() + 
  facet_wrap("Name", ncol = 5)
