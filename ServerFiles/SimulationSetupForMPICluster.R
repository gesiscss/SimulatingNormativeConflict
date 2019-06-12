# Wrapper function for the whole process of:
# - creating parameter permutations
# - create folders and files to save output
# - generate a list of basic networks as starting points
# - evolve these starting points into larger networks based on parameters: node, m, g, h
# - initilaize norm distributions within these networks based on parameters: norm_end_maj, norm_end_min
# - simulate evolution of norms in these networks based on an adapted Granovetter Threshold Model, based on parameters: iter, t and UpdateProcess
# - Extracting and saving distribution of norms at each iteration of each network
# - OPTIONAL: Create Plots at each iteration of each network for visualization
# - OPTIONAL: Create Animations from plots to visualize norm evolution in each network

## This Version of the Simulation Wrapper uses the parLapply() function
## instead of mclapply(). This makes it possible to not only run the function
## on multiple cores of the same machine, but to distribute the Simulation
## to multiple cores on multiple nodes of an MPI Cluster.
## To make it work on such a cluster, one has to

# 1) load the necessary libraries
library(parallel)
library(snow)
library(Rmpi)

# 1) Initialize the Cluster from R (you might need to fetch the number of cores differently)
cl <- makeCluster(strtoi(Sys.getenv(c("SLURM_NTASKS")))-1, type="MPI");cl

# 2) Testing how many cores are available accross the initialized cluster
mpi.universe.size() 

# 3) # Exporting all necessary libraries to all the slave nodes to make them available
clusterEvalQ(cl,suppressMessages(library(igraph)))
clusterEvalQ(cl,suppressMessages(library(tidyverse)))
clusterEvalQ(cl,suppressMessages(library(tictoc)))
clusterEvalQ(cl,suppressMessages(library(data.table)))
clusterEvalQ(cl,suppressMessages(library(threejs)))
clusterEvalQ(cl,suppressMessages(library(htmlwidgets)))
clusterEvalQ(cl,suppressMessages(library(pbmcapply)))
clusterEvalQ(cl,suppressMessages(library(parallel)))

# 4) Exporting all our custom functions to all the slave nodes to make them available
clusterEvalQ(cl,source("../Functions/GenerateStartingPoint.R"))
clusterEvalQ(cl,source("../Functions/GeneratorFunction.R"))
clusterEvalQ(cl,source("../Functions/NormInit.R"))
clusterEvalQ(cl,source("../Functions/SynchronousNormUpdateing.R"))
clusterEvalQ(cl,source("../Functions/GeneratorFunction.R"))
clusterEvalQ(cl,source("../Functions/AsynchronousUpdateing.R"))
clusterEvalQ(cl,source("../Functions/Extractor.R"))
clusterEvalQ(cl,source("../Functions/Plotter.R"))
clusterEvalQ(cl,source("../Functions/Animator2.R"))
clusterEvalQ(cl,source("../Functions/removeNULLs.R"))


# Initialize the simulation function
clusterEvalQ(cl,source("../Simulation.R"))

# Start the simulatons:
# NOTE: Rather than to call the function once and
# specify that we want 20 repetitions, we call the function
# 20 times specifying 1 repetition. This makes it easier
# to monitor progress and prevents complete data loss
# should an error occur on the server

# 1
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output1",
           cores = mpi.universe.size())

# 2
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output2",
           cores = mpi.universe.size())

# 3
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output3",
           cores = mpi.universe.size())

# 4
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output4",
           cores = mpi.universe.size())

# 5
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output5",
           cores = mpi.universe.size())

# 6
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output6",
           cores = mpi.universe.size())

# 7
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output7",
           cores = mpi.universe.size())

# 8
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output8",
           cores = mpi.universe.size())

# 9
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output9",
           cores = mpi.universe.size())

# 10
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output10",
           cores = mpi.universe.size())

# 11
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output11",
           cores = mpi.universe.size())

# 12
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output12",
           cores = mpi.universe.size())

# 13
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output13",
           cores = mpi.universe.size())

# 14
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output14",
           cores = mpi.universe.size())

# 15
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output15",
           cores = mpi.universe.size())

# 16
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output16",
           cores = mpi.universe.size())

# 17
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output17",
           cores = mpi.universe.size())

# 18
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output18",
           cores = mpi.universe.size())

# 19
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output19",
           cores = mpi.universe.size())

# 20
Simulation(nodes = 2000,
           r = 1,
           norm_end_maj = c(0.5,0.6,0.8), 
           norm_end_min = c(0.5,0.4,0.2),
           g = seq(0.1,0.5,0.1),    
           h = seq(0,1,0.1), 
           iter = 50,
           Folder = "/Output20",
           cores = mpi.universe.size())