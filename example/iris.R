#!/home/statsadmin/R/bin/Rscript

# Prepare: collect command line arguments,
# set iteration number and a unique seed

args <- commandArgs()

idx <- args[length(args)]

cat(idx)

.libPaths('ysidi/lib')

library(dplyr)

set.seed(Sys.time())

saveRDS(iris%>%dplyr::sample_n(idx),
        file = sprintf('iris_%s.rds',idx)
        )
