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
#A17964 is from Gaynor - she has marked this 'x'. WAM says not to be put on ALA - will exclude for now. Sorted (see below)
wam <- read_csv('data/2018.06.22_McElroy.csv', col_names=TRUE) %>% #sample in database that is not in OZCAM. See email trail with WAM (Rebecca Bray and Ron Johnstone) 
  unite(catalogNumber, SUFFIX, REGNO,sep = '') %>%
  select_if(colSums(!is.na(.)) > 0) %>%
  rename(sex=SEX) %>%
  rename(decimalLongitude=LONGDEC) %>%
  rename(decimalLatitude=LATDEC) %>%
  rename(eventDate=DTFR) %>%
  mutate(eventDate=as.Date(eventDate, "%m/%d/%Y")) %>%
  rename(recordedBy=COLLTOR) %>%
  rename(stateProvince=STATE) %>%
  rename(verbatimLocality=SITE) %>%
  add_column(institutionCode='WAM') %>%
  add_column(collectionCode='AVIF') %>%
  add_column(lifestage='Immature')
  
ozcam <- full_join(ozcam, wam)
meta<- rename(meta, catalogNumber = specimen)
not_found_oz<- setdiff(ozcam$catalogNumber, specimens)
not_found_spec <- setdiff(specimens, ozcam$catalogNumber)


meta <- inner_join(meta, ozcam) %>%
  select_if(colSums(!is.na(.)) > 0)


meta <- select(meta, one_of(c("file", "catalogNumber", "decimalLatitude", "decimalLongitude", "library", "centre", "date", "species", "institutionCode", "collectionCode", "recordedBy", "sex", "eventDate", "lifeStage", "stateProvince", "verbatimLocality"))) %>%
  separate(col=1, remove=FALSE, into = c('flowCell','lane','runDate', 'submission','ref','index'), sep='_', extra = 'drop') %>%
  rename(seqCentre = centre) %>%
  rename(libDate = date) %>%
  add_column(platform = 'illumina') %>%
  add_column(version = 'HiSeq 2500') %>%
  add_column(chemistry = 'v4.0') %>%
  mutate(species = str_replace(species, 'cinclosoma', 'Cinclosoma')) %>%
  mutate(species = str_replace(species, 'Clarum', '_clarum')) %>%
  mutate(species = str_replace(species, 'Fordianum','_fordianum')) %>%
  mutate(species = str_replace(species, 'Castanotum','_castanotum')) %>%
  mutate(species = str_replace(species, 'Punctatum','_punctatum')) %>%
  mutate(species = str_replace(species, 'ptilorrhoaCaerulescens','Cinclosoma_cinnamomeum_alisteri')) 

counts <- read_tsv(file='/OSM/CBR/NRCA_FINCHGENOM/data/2018-06_quail-thrush/DAP/counts.txt', col_names=c('file','readCounts'))
meta <- full_join(meta, counts)

meta <- meta %>% select(c('file', 'catalogNumber', 'species', 'sex', 'lifeStage', 'eventDate', 'recordedBy', 'decimalLatitude', 'decimalLongitude', 'stateProvince', 'verbatimLocality', 'institutionCode', 'collectionCode', 'index', 'library', 'libDate','seqCentre','runDate','platform','version','chemistry', 'flowCell','lane', 'readCounts'))
write_tsv(meta, path='data/metadata.tsv')
write_tsv(meta, path='/OSM/CBR/NRCA_FINCHGENOM/data/2018-06_quail-thrush/DAP/metadata.tsv')
group_by(meta, species) %>%
  summarise(count = n_distinct('catalogNumber'))

meta %>%
  group_by(catalogNumber) %>%
  summarize(total_reads = sum(readCounts)) %>%
  ggplot(aes(x=catalogNumber, y=total_reads))+
      geom_point() +
      geom_hline(yintercept=20000000)

read_counts <-meta %>%
  group_by(catalogNumber) %>%
  summarise(total_reads = sum(readCounts)) %>%
  mutate(depth = cut(total_reads, breaks=c(-Inf,20000000, Inf), labels=c('low','high')))
    
first_run <- meta %>% 
  filter(grepl('C8KKRANXX', file)) 

#%>%
#  ggplot(aes(x = readCounts)) + geom_histogram()

meta <- meta %>%
  group_by(catalogNumber) %>%
  mutate(total_reads = sum(readCounts)) %>%
  mutate(level = cut(total_reads, breaks=c(-Inf,20000000, Inf), labels=c('low','high')))

later_run <- meta %>%
  filter(!grepl('C8KKRANXX', file)) %>%
  group_by(catalogNumber) %>%
  summarise(total_reads=sum(readCounts)) %>%
  mutate(depth = cut(total_reads, breaks=c(-Inf,20000000, Inf), labels=c('low','high')))

inner_join(first_run, later_run, by='catalogNumber') %>%
  group_by(catalogNumber) %>%
  summarise(n())

later_run %>%
  group_by(catalogNumber) %>%
  summarise(n())

later_run %>%
  summarise(mean())
low <- read_counts %>%
  filter(grepl('low',depth))
