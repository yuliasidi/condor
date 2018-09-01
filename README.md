
<!-- README.md is generated from README.Rmd. Please edit that file -->

# condor

The goal of condor is to run R batch commands in `HTCondor` on a remote
cluster directly from a local terminal or `RStudio` work environment.

## Installation

You can install condor from github with:

``` r
# install.packages("devtools")
devtools::install_github("yuliasidi/condor")
```

## SSH Key Setup

  - Installation of the R package
    [ssh](https://www.github.com/ropensci/ssh)
  - setting up an ssh key
      - create a key pairing on the local machine
      - on the remote machine
          - In the user directory (`~`) create the subdirectory `~/.ssh`
            if it is not already there
              - `mkdir ~/.ssh`
          - Create a file in `~/.ssh` called `authorized_keys`
              - `touch ~/.ssh/authorized_keys`
      - copy the public key contents to the remote server into
        .ssh/authorized\_keys
          - `cat ~/.ssh/id_rsa.pub | pbcopy` (mac)
      - paste the contents of the clipboard on the remote into
        `~/.ssh/authorized_keys`
          - `echo '[PASTE CONTENTS OF CLIPBOARD]' >
            ~/.ssh/authorized_keys`

## Workflow

### Load Libraries

``` r
library(condor)
library(ssh)
```

### Preprocessing

Populate package template and create `Rcalcpi.condor` in `example`
subdir.

``` r
condor::build_template(
  file = 'calcpi.R',
  args = c('$(Process)'),
  tag = 'pi',
  jobs = 5,
  init_dir = 'jobs/run',
  template_file = 'example/Rcalcpi.condor',
  job_type = 'test')
```

Lines in file that will be run on the cluster

``` r
readLines(system.file('example/calcpi.R',package='condor'))
#>  [1] "#!/home/statsadmin/R/bin/Rscript"          
#>  [2] ""                                          
#>  [3] "# Prepare: collect command line arguments,"
#>  [4] "# set iteration number and a unique seed"  
#>  [5] "args <- commandArgs()"                     
#>  [6] "set.seed(Sys.time())"                      
#>  [7] "n <- as.numeric(args[length(args)-1])"     
#>  [8] ""                                          
#>  [9] "# Collect n samples"                       
#> [10] "x <- runif(n,k)"                           
#> [11] "y <- runif(n)"                             
#> [12] ""                                          
#> [13] "# Compute and output the value of pi"      
#> [14] "pihat <- sum(x * x + y * y < 1) / n * 4"   
#> [15] "pihat"                                     
#> [16] "write(pihat, args[length(args)])"          
#> [17] "proc.time()"
```

Lines in the populated condor file

``` r
readLines(system.file('example/Rcalcpi.condor',package='condor'))
#>  [1] "executable = calcpi.R"                                    
#>  [2] "universe = vanilla"                                       
#>  [3] "Requirements = ParallelSchedulingGroup == \"stats group\""
#>  [4] "+AccountingGroup = \"group_statistics_testjob.yuliasidi\""
#>  [5] ""                                                         
#>  [6] "should_transfer_files = YES"                              
#>  [7] "when_to_transfer_output = ON_EXIT"                        
#>  [8] ""                                                         
#>  [9] "arguments = $(Process)"                                   
#> [10] "output    = out/pi-$(Process).Rout"                       
#> [11] "error     = err/pi-$(Process).err"                        
#> [12] "log       = log/pi.log"                                   
#> [13] ""                                                         
#> [14] "initialdir = jobs/run"                                    
#> [15] "# transfer_input_files ="                                 
#> [16] "# transfer_output_files ="                                
#> [17] ""                                                         
#> [18] "Queue 5"
```

Connect to ssh

``` r
session <- ssh::ssh_connect(Sys.getenv('UCONN_USER'))
```

Upload files needed for the job to the cluster

``` r
ssh::scp_upload(session,
                files = c('example/calcpi.R',
                          'example/Rcalcpi.condor', 
                          'example/emailMyself.txt'),
                to = '~'
)
```

Create directories needed for job outputs

``` r
condor::create_dirs(session, file = 'example/Rcalcpi.condor')
```

Submit the jobs

``` r
condor::condor_submit(session,'Rcalcpi.condor')
```

### During the job

``` r
condor::condor_q(session)
```

``` r
condor::condor_rm(session,'5000.1')
```

### Post Processing

Retrieve the files

``` r
condor::pull(session,
             from = c('jobs/run/log',
                      'jobs/run/out',
                      'jobs/run/err',
                      'jobs/run/*.rds'),
             to = c('output',
                    'output',
                    'output',
                    'output/data'))
```

Remove files from the cluster

``` r
condor::cleanup_remote(session)
```

Collect output from the local into a single object

``` r
RETURN <- purrr::map(
  list.files(path = "example/output/data",full.names = TRUE),
  readRDS
  )
```

Remove files from the local machine

``` r
condor::cleanup_local(dir = 'example/output',tag = 'pi')
```

Close ssh connection

``` r
ssh::ssh_disconnect(session)
```
