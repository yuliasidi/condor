#!/home/statsadmin/R/bin/Rscript

# Prepare: collect command line arguments,
# set iteration number and a unique seed
args <- commandArgs()
set.seed(Sys.time())
n <- as.numeric(args[length(args)-1])

# Collect n samples
x <- runif(n,k)
y <- runif(n)

# Compute and output the value of pi
pihat <- sum(x * x + y * y < 1) / n * 4
pihat
write(pihat, args[length(args)])
proc.time()
