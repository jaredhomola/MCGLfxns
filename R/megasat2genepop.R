#library(miscTools)
#library(readxl)
#library(tidyverse)
#
#metaDat <- read_excel("X:/2105 Pike reproductive success/2105samples.xlsx",
#                      sheet = "Sheet1") %>%
#  select(SampleID, WaterbodyName) %>%
#  rename(sample = SampleID)
#
#### Read in genotypes, merge with metadata, organize by pop, remove negative controls
#dat1 <- read_table("X:/2101 Pike_Musky Microsatellite Panel/NOP/2105-123_output/Output_2105-123_paired_out/Genotype.txt") %>%
#  select(-ncol(.)) %>%
#  separate(Sample_idx1_idx2,
#           into = c("sample", NA, NA, NA),
#           sep = "\\.") %>%
#  left_join(metaDat) %>%
#  arrange(WaterbodyName, sample) %>%
#  filter(!grepl('NTC-', sample))
#
#dat <- read_table("X:/2101 Pike_Musky Microsatellite Panel/NOP/2105-250_output/Output_2105-250_paired_out/Genotype.txt") %>%
#  select(-ncol(.)) %>%
#  separate(Sample_idx1_idx2,
#           into = c("sample", NA, NA, NA),
#           sep = "\\.") %>%
#  left_join(metaDat) %>%
#  arrange(WaterbodyName, sample) %>%
#  filter(!grepl('NTC-', sample)) %>%
#  bind_rows(dat1) %>%
#  arrange(WaterbodyName)
#
### Names for each allele of each locus
#loci <- colnames(dat) %>%
#  as_tibble() %>%
#  mutate(value = str_remove(value, "[)]")) %>%
#  mutate(value = str_remove(value, "[(]")) %>%
#  mutate(value = str_remove(value, "[-]")) %>%
#  slice(-1)
#
### Names for each locus
#loci2 <- loci %>%
#  filter(!grepl("Water", value)) %>%
#  slice(which(row_number() %% 2 == 1))
#
### Change MegaSat notation to be missing genepop calls (000)
#dat2 <- dat %>%
#  select(-sample, -WaterbodyName) %>%
#  mutate(across(everything(), ~replace(., . ==  0, "000")),
#         across(everything(), ~replace(., . ==  "X" , "000")),
#         across(everything(), ~replace(., . ==  "Unscored" , "000")),
#         across(everything(), ~str_pad(., 3, pad = "0")))
#
### Set up a locus index to negate complications due to similar locus names (e.g., B25 and B259)
#locIndex <- paste0("locus",
#                   rep(1001:((1001+length(loci$value)/2)-1), each = 2),
#                   rep(letters[1:2], times = length(loci$value)/2))
#names(dat2) <- locIndex
#
### Unite the alleles for each locus
#genDat <- do.call(cbind,
#        lapply(unique(substr(locIndex, 1, 9)), function(x) {
#          unite_(dat2,
#                 x,
#                 grep(x, names(dat2), value = TRUE),
#                 sep = '',
#                 remove = TRUE) %>%
#            select(x)
#        })) %>%
#  mutate(sample = paste0(dat$sample,","),
#         .before = 1)
#
#
## ---------------- #
## Construct the Genepop file
## ---------------- #
#
#mat = as.matrix(genDat)
#
### Genepop header
#file_date = format(Sys.time(), "%Y%m%d@%H%M") # date and time
#header = paste("Genepop file format", "MCGL2101 ", file_date)
#
### List of loci names separated by commas
#loc_names = paste(loci2$value, collapse=",")
#
##### Generate appropriate "Pop" rows
### Pop label that will separate each population
#popline = c("Pop", rep("", ncol(mat)-1 ))
#
### Count the number of individuals in each population
#pop_counts = data.frame(Counts = count(dat, WaterbodyName))
#
### Add a column totalling the cumulative sum
#pop_counts$Sum = cumsum(pop_counts$Counts.n)
#
### Insert a Pop row between each population
#for (i in 1:nrow(pop_counts)){
#  # i is the row number and increases by 1 after each interation to compensate
#  # for the extra row being inserted each run through the loop
#  pop.row = rep(NA, nrow(pop_counts))
#  pop.row[i] = pop_counts$Sum[i] + i
#  mat = insertRow(mat, pop.row[i], popline)
#}
#
## Remove the last Pop row
#mat = mat[-nrow(mat), ]
#
#
### Insert title, locus and pop rows at the beginning
#mat = insertRow(mat, 1, c(header, rep("", ncol(mat)-1 )))
#mat = insertRow(mat, 2, c(loc_names, rep("", ncol(mat)-1 )))
#mat = insertRow(mat, 3, popline)
#
## Export file
#write.table(mat, file= "X:/2101 Pike_Musky Microsatellite Panel/NOP/genotypes150_250.gen",
#            quote=FALSE,
#            col.names=F,
#            row.names=F)
#
