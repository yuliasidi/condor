
<!-- README.md is generated from README.Rmd. Please edit that file -->
condor
======

The goal of condor is to run R batch commands in `HTCondor` on a remote cluster directly from a local terminal or `RStudio` work environment. 

Installation
------------

You can install condor from github with:

``` r
# install.packages("devtools")
devtools::install_github("yuliasidi/condor")
```

SSH Key Setup
-------------

  - Installation of the R package [ssh](https://www.github.com/ropensci/ssh)
  - setting up an ssh key
    - create a key pairing on the local machine
    - on the remote machine 
      - In the user directory (`~`) create the subdirectory `~/.ssh` if it is not already there
        - `mkdir ~/.ssh`
      - Create a file in `~/.ssh` called `authorized_keys`
        - `touch ~/.ssh/authorized_keys`
    - copy the public key contents to the remote server into .ssh/authorized_keys
      - `cat ~/.ssh/id_rsa.pub | pbcopy` (mac)
    - paste the contents of the clipboard on the remote into `~/.ssh/authorized_keys`
      - `echo '[PASTE CONTENTS OF CLIPBOARD]' > ~/.ssh/authorized_keys`
      

Using ssh package to interact with uconn cluster
================================================

load library

``` r
library(ssh)
```

create ssh connection to cluster
--------------------------------

``` r

session <- ssh_connect(Sys.getenv('UCONN_USER'))
```

Transfering files to and from cluster
-------------------------------------

Example: path to a file

``` r

file_path <- R.home("COPYING")

file_path
#> [1] "/Library/Frameworks/R.framework/Resources/COPYING"
```

local ==&gt; cluster

``` r

scp_upload(session, file_path)
#> 
[91%] /Library/Frameworks/R.framework/Versions/3.5/Resources/COPYING
[100%] /Library/Frameworks/R.framework/Versions/3.5/Resources/COPYING
[100%] /Library/Frameworks/R.framework/Versions/3.5/Resources/COPYING
#> [1] "."
```

cluster ==&gt; local

``` r

scp_download(session, "COPYING", to = tempdir())
#>      18011 /var/folders/wk/lwx7hskj6gbd0_b4zlz3rj440000gn/T//Rtmplrjkji/COPYING
#> NULL
```

check that the file passed back and forth is the still the same

``` r

c(
  tools::md5sum(file_path),
  tools::md5sum(file.path(tempdir(), "COPYING"))
  )
#>                    /Library/Frameworks/R.framework/Resources/COPYING 
#>                                   "eb723b61539feef013de476e68b5c50a" 
#> /var/folders/wk/lwx7hskj6gbd0_b4zlz3rj440000gn/T//Rtmplrjkji/COPYING 
#>                                   "eb723b61539feef013de476e68b5c50a"
```

Running commands from local on the cluster
==========================================

commands to run

``` r

cmds <- c(
  'ls jobs/cluster', # list files in jobs cluster
  'cd jobs/cluster', # move to jobs/cluster
  'cat Rcalcpi.condor' # print the lines of Rcalcpi.condor
)
```

Run without returning anything to local R

``` r

ssh_exec_wait(session, command = cmds)
#> calcpi.R
#> cluster.Rproj
#> condor
#> condor_user.md
#> packrat
#> Rcalcpi.condor
#> executable = calcpi.R
#> universe = vanilla
#> Requirements = ParallelSchedulingGroup == "stats group"
#> +AccountingGroup = "group_statistics_testjob.username"
#> 
#> should_transfer_files = YES
#> when_to_transfer_output = ON_EXIT
#> 
#> arguments = 10000000 data/pihat-$(Process).rds
#> output    = out/pi-$(Process).Rout
#> error     = err/pi-$(Process).err
#> log       = log/pi.log
#> 
#> initialdir = condor
#> # transfer_input_files = ../../ysidi/lib/
#> transfer_output_files = data/pihat-$(Process).rds
#> 
#> Queue 5
#> [1] 0
```

Capturing the output from the cluster terminal as a list object in the local `R`

``` r

out <- ssh_exec_internal(session, command = cmds)
```

status of the lines that were run

``` r

out$status # 0 means everything was run ok
#> [1] 0
```

Printing the contents of out
----------------------------

using `ssh_print`

``` r

condor::ssh_print(out$stdout)
#>  [1] "calcpi.R"                                                 
#>  [2] "cluster.Rproj"                                            
#>  [3] "condor"                                                   
#>  [4] "condor_user.md"                                           
#>  [5] "packrat"                                                  
#>  [6] "Rcalcpi.condor"                                           
#>  [7] "executable = calcpi.R"                                    
#>  [8] "universe = vanilla"                                       
#>  [9] "Requirements = ParallelSchedulingGroup == \"stats group\""
#> [10] "+AccountingGroup = \"group_statistics_testjob.username\"" 
#> [11] ""                                                         
#> [12] "should_transfer_files = YES"                              
#> [13] "when_to_transfer_output = ON_EXIT"                        
#> [14] ""                                                         
#> [15] "arguments = 10000000 data/pihat-$(Process).rds"           
#> [16] "output    = out/pi-$(Process).Rout"                       
#> [17] "error     = err/pi-$(Process).err"                        
#> [18] "log       = log/pi.log"                                   
#> [19] ""                                                         
#> [20] "initialdir = condor"                                      
#> [21] "# transfer_input_files = ../../ysidi/lib/"                
#> [22] "transfer_output_files = data/pihat-$(Process).rds"        
#> [23] ""                                                         
#> [24] "Queue 5"
```

close ssh connection to cluster
===============================

``` r
      
ssh_disconnect(session)
```
