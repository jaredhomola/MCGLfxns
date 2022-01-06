#######################################################################
##############     MCGLfxns::colonyMarkerCreate()    ##################
#### Generate the marker input file for Colony from a genepop file ####
#######################################################################


#### First set up genepop files for male and female parents and offspring samples
#### An option for that is to read the genepop file into R as a genind file
#### before doing filtering and subsetting on that. Then write out as a genepop that
#### becomes input for this function.

#### "file_in" is the filepath for any of the genepop files created above
#### "file_out" is the filepath for where to write the colony file out
#### "cod" is 0 for codominant, 1 for dominant markers. MCGL projects are likely 0
#### "gte" is genotype error rate. Default = 0.02
#### "ote" is other error rate. Default = 0.001


colonyMarkerCreate = function(file_in="", file_out="", cod = 0, gte = 0.02, ote = 0.001){
  if(!require(radiator)){install.packages("radiator")}
  if(!require(tidyverse)){install.packages("tidyverse")}

  tidyDat <- tidy_genepop(data = file_in)
  nmarkers <- length(unique(tidyDat$MARKERS))
  markers  <- data.frame(matrix(data = 0, nrow = 3, ncol = nmarkers))
  colnames(markers) <- unique(tidyDat$MARKERS)

  #filling in matrix
  markers[1,] <- cod #for co-dominant markers
  markers[2,] <- gte # genotyping error
  markers[3,] <- ote #other types of error

  write_delim(markers,
              file_out,
              delim = " ",
              quote = "none")
}
