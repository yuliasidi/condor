#!/home/statsadmin/R/bin/Rscript

# Prepare: collect command line arguments,
# set iteration number and a unique seed
idx <- as.numeric(commandArgs())

.libPaths('ysidi/lib')

library(dplyr)

set.seed(986)

saveRDS(iris%>%dplyr::sample_n(idx),file = sprintf('iris_%02d.rds',idx))
