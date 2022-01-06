######################################################################
###############     MCGLfxns::genepop2colony()    ####################
####### Converts a genepop file to a Colony GUI input file ###########
######################################################################


#### First set up genepop files for male and female parents and offspring samples
#### An option for that is to read the genepop file into R as a genind file
#### before doing filtering and subsetting on that. Then write out as a genepop that
#### becomes input for this function.

#### "file_in" is the filepath for the genepop file
#### "file_out" is the filepath for where to write the colony file out

genepop2colony <- function(file_in="", file_out=""){
  if(!require(radiator)){install.packages("radiator")}
  if(!require(tidyverse)){install.packages("tidyverse")}

  tidy_genepop(data = file_in) %>%
    separate(GT, into = c("allele1", "allele2"), sep = 3) %>%
    mutate(allele1 = str_remove(allele1, "^0+"),
           allele2 = str_remove(allele2, "^0+")) %>%
    mutate_at(c("allele1", "allele2"), funs(replace(., .=="", 0))) %>%
    unite("GT", allele1:allele2, sep = " ") %>%
    select(-POP_ID) %>%
    pivot_wider(names_from = MARKERS,
                values_from = GT) %>%
    unite("GTs", 2:ncol(.), sep = " ") %>%
    write_delim(file_out,
                delim = " ",
                quote = "none",
                col_names = FALSE)
}
