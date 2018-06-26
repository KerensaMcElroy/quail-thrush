library(tidyverse)

# this project uses data that was previously split across two projects. 
# this is an attempt to pull it together into a useful metadata file.
# ultimately for upload to DAP. And to facilitate paper writing. 

library_meta <- read_tsv('/OSM/CBR/NRCA_FINCHGENOM/data/2015-11-12_libraries/2015-11-12_libraries.samples', col_names = FALSE)
quail_meta <- read_tsv('/OSM/CBR/NRCA_FINCHGENOM/data/2015-10-01_quail/2015-10-01_quail.samples', col_names = FALSE)

colnames(library_meta) <- c('file','specimen','library','centre','date','species')
colnames(quail_meta) <- c('file','specimen','library','centre','date','species')

library_meta <- library_meta %>% 
  filter(!str_detect(species, 'heli'))

meta <- bind_rows(library_meta, quail_meta)

# now we need to switch over to ozcam to get list of museums...

specimens <- unique(meta$specimen)
write(specimens, file='analysis/specimens_meta.csv')

# used as input to ozcam catalogue search, then selected any cinclosoma options. Resulted in following file:

ozcam <- read_csv('data/records-2018-06-26.csv', col_names=TRUE)
meta<- rename(meta, catalogNumber = specimen)
not_found_oz<- setdiff(ozcam$catalogNumber, specimens)
not_found_spec <- setdiff(specimens, ozcam$catalogNumber)

#A17964 is from Gaynor - she has marked this 'x'. WAM says not to be put on ALA - will exclude for now.

meta <- inner_join(meta, ozcam, by = "catalogNumber") %>%
  select_if(colSums(!is.na(.)) > 0)


meta <- select(meta, one_of(c("file", "catalogNumber", "decimalLatitude", "decimalLongitude", "library", "centre", "date", "species", "institutionCode", "collectionCode", "recordedBy", "sex", "eventDate", "lifeStage", "stateProvince", "verbatimLocality"))) %>%
  rename(seqCentre = centre) %>%
  rename(libDate = date) %>%
  mutate(species = str_replace(species, 'cinclosoma', 'Cinclosoma')) %>%
  mutate(species = str_replace(species, 'Clarum', '_clarum')) %>%
  mutate(species = str_replace(species, 'Fordianum','_fordianum')) %>%
  mutate(species = str_replace(species, 'Castanotum','_castanotum')) %>%
  mutate(species = str_replace(species, 'Punctatum','_punctatum')) %>%
  mutate(species = str_replace(species, 'ptilorrhoaCaerulescens','Cinclosoma_cinnamomeum_alisteri'))

#write(colnames(meta), file='analysis/col_names.csv')
