#!/home/statsadmin/R/bin/Rscript

# Prepare: collect command line arguments,
# set iteration number and a unique seed

args <- commandArgs()

idx <- as.numeric(args[length(args)])

.libPaths('ysidi/lib')

library(dplyr)

source('iris_source.R')

set.seed(Sys.time())

saveRDS(iris%>%dplyr::sample_n(idx),
        file = sprintf('iris_%02d.rds',idx)
        )
