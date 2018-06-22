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

ozcam <- read_tsv('data/2018-06-22_cinclosoma.tsv', col_names=TRUE)

not_found_oz<- setdiff(ozcam$catalogNumber, specimens)
not_found_spec <- setdiff(specimens, ozcam$catalogNumber)
#need to go back to ozcam and manually find B07704, A17964
#B07704 is B7704
#A17964 is from Gaynor - she has marked this 'x'. Will wait to hear back from WAM.
ozcam[1,13]
ozcam[1,14]
ozcam[1,27]

ozcam$catalogNumber
