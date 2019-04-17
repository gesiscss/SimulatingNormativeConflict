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

Simulation <- function(
        
        ###### Setting interchangeable parameters for groups and norms #####
        
        majority = "majority",           # insert name for demographic attribute of majority
        minority = "minority",           # insert name for demographic attribute of minority
        
        majshape = "square",             # insert shape to represent majority nodes in network graph
        minshape = "circle",             # insert shape to represent minority nodes in network graph
        
        majnorm = "majority_norm",       # insert name for dominating norm in the majority group
        minnorm = "minority_norm",       # insert name for dominating norm in the minority group
        
        majnormcolor = "lightblue",      # insert color to represent norm that dominates in majority group
        minnormcolor = "lightcoral",     # insert color to represent norm that dominates in minority group
        
        
        ##### Simulation Parameters ######
        
        ## Stable Parameters
        r = 20,                            # number of runs per condition
        nodes = 2000,                      # number of nodes in network
        iter = 50,                         # Number of Iterations for the Granovetter Threshold Model (In the final version, we should implement automatic conversion detection to speed it up)
        
        ## varying parameters (some of these can handle sequences)
        
        norm_end_maj = c(0.5,0.6,0.8),               # proportion of majority group that endorses majority norm 
        norm_end_min = c(0.5,0.4,0.2),               # proportion of minority group that endorses majority norm
        t = "uniform",                               # threshold value for the Granovetter Threshold Model supports single value between 0 and 1, "uniform" and "normal" (trimmed to 0 - 1)
        tmean = NA,                                  # when t is supposed to come from a normal distribution, we need to specify a value for its mean
        tsd = NA,                                    # when t is supposed to come from a norms distribution, we need to specify a value for its sd    
        m = 2,                                       # value for minimum degree (SEQUENCE NOT IMPLEMENTED YET)
        g = seq(0.1,0.5,0.1),                        # proportion of network that's in the minority group      
        h = seq(0.1,1,0.1),                          # homophily
        
        ##### Simulation Settings #####
        
        UpdateProcess = "asynchronous",   # controls whether nodes are updated synchronously or asynchrounously
        
        # Technical Settings
        
        cores = 1,                        # controls how many cores to use (For Windows, only one core is supported)

        # Output Settings
        
        CreatePlots = FALSE,              # controls whether the function does create and save a plot of every network iteration (Time consuming)
        AnimatePlots = FALSE,             # controls whether all iteration plots of all networks are summarized into a GIF showcasing network evolution (VERY time consuming)
        
        # Settings for special cases
        SimplifyCombinations = FALSE      # only allows for specific complementary combinations of norm_end_maj and norm_end_min
        
) {
        
        options(warn = -1)
        
        ## importing packages
        if("igraph" %in% installed.packages() != TRUE) {
                install.packages("igraph")
        }
        if("tidyverse" %in% installed.packages() != TRUE) {
                install.packages("tidyverse")
        }
        if("tictoc" %in% installed.packages() != TRUE) {
                install.packages("tictoc")
        }
        if("parallel" %in% installed.packages() != TRUE) {
                install.packages("parallel")
        }
        if("data.table" %in% installed.packages() != TRUE) {
                install.packages("data.table")
        }
        if("threejs" %in% installed.packages() != TRUE) {
                install.packages("threejs")
        }
        if("htmlwidgets" %in% installed.packages() != TRUE) {
                install.packages("htmlwidgets")
        }
        if("pbmcapply" %in% installed.packages() != TRUE) {
                install.packages("pbmcapply")
        }

        
        ## attaching packages while surpressing console print messages
        suppressMessages(library(igraph))
        suppressMessages(library(tidyverse))
        suppressMessages(library(tictoc))
        suppressMessages(library(parallel))
        suppressMessages(library(data.table))
        suppressMessages(library(threejs))
        suppressMessages(library(htmlwidgets))
        suppressMessages(library(pbmcapply))
        
        # Switching warnings back on
        options(warn = 0)
        
        # Taking the time for overall simulation
        tic("\n \n \t \t-----------------FINISHED SIMULATION-------------------")
        
        # Taking Time for Setup
        tic("Setup completed")
        
        cat("Setup:\n")
        
        # check if input is valid
        if(majority == minority |
           majshape == minshape |
           majnorm  == minnorm  |
           majnormcolor == minnormcolor){
          
          warning("Input for demographic and norm attributes must be different between the tw groups")
          stop()
          
        }
        
        cat("\t - Validity of input checked \n")
        
        # detecting operating system to set cores to 1 for windows systems
        if (.Platform$OS.type == "windows" & cores != 1) {

                cores = 1
                warning("Windows Operating System detected. Multiple Cores are not supported in Windows. Simulation will continue with 1 core")
                
        } else {
                
                cores = cores
        }
        
        cat("\t - Number of used cores adapted to operating system \n")
        
        ## checking if we have write permissions to the wd
        if(file.access(getwd(),2) != 0) {
                
                cat("No write permission in the current working directory\n")
                stop()
        }
        
        cat("\t - Verified writing permissions to working directory \n")
        
        # Creating Output table for specified parameter range
        expand.grid(nodes,iter,norm_end_maj,norm_end_min,t,m,g,h,1:r) %>%
                rename(nodes = Var1) %>%
                rename(iter = Var2) %>%
                rename(norm_end_maj = Var3) %>%
                rename(norm_end_min = Var4) %>%
                rename(t = Var5) %>%
                rename(m = Var6) %>%
                rename(g = Var7) %>%
                rename(h = Var8) %>%
                rename(RunWithinParameterSet = Var9) %>%
                mutate(Diameter = NA,
                       PercentMajorityGroup = NA,
                       NumberIterationsRun = NA,
                       Assortativity = NA,
                       DegreeCentrality = NA,
                       ClosenessCentrality = NA,
                       BetweennessCentrality = NA,
                       Clusters = NA,
                       MajNormProbInMaj = NA,
                       MajNormProbInMin = NA,
                       TimeDone = NA) ->
                OutputDataTable
        
        cat("\t - Finished creation of parameter permutation table \n")
        
        # Simplify Combinations
        if(SimplifyCombinations == TRUE){
                
                OutputDataTable <- OutputDataTable[(OutputDataTable$norm_end_maj == 0.5 & OutputDataTable$norm_end_min == 0.5) |
                                                   (OutputDataTable$norm_end_maj == 0.6 & OutputDataTable$norm_end_min == 0.4) |
                                                   (OutputDataTable$norm_end_maj == 0.8 & OutputDataTable$norm_end_min == 0.2),]
                
        }
        
        
        # loading all necessary functions
        source("./Functions/GenerateStartingPoint.R")
        source("./Functions/GeneratorFunction.R")
        source("./Functions/NormInit.R")
        source("./Functions/SynchronousNormUpdateing.R")
        source("./Functions/AsynchronousUpdateing.R")
        source("./Functions/Extractor.R")
        source("./Functions/Plotter.R")
        source("./Functions/Animator2.R")
        source("./Functions/Animator.R")
        source("./Functions/removeNULLs.R")
        
        cat("\t - Sourced necessary functions \n")
        
        ### Create new folder for output and saving parameter combinations
        
        # saving old working directory
        oldwd <- getwd()
        
        # creating a new folder to save output in
        dir.create(paste(oldwd, "/Output",sep=""), showWarnings = F)
        
        # setting new folder as working directory
        setwd(paste(oldwd, "/Output",sep=""))
        
        # saving all permutations in a seperate Data object
        write.csv(OutputDataTable[,1:8], file = "ParameterPermutations.csv")
        
        # cat Status
        cat(paste("\t - Created output folder at", paste(oldwd, "/Output","\n",sep="")))
        
        # Generate Starting Point Network
        StartingPoint <- GenerateStartingPoint(m_passdown = m,
                                               majority_passdown = majority,
                                               minority_passdown = minority,
                                               majshape_passdown = majshape,
                                               minshape_passdown = minshape)
        
        cat("\t - Finished generation of starting point network \n \n")
        
        # output Setup completed + time
        toc()
        
        cat("\n \n Creating Network Structure & Initializing Norms: \n")
        
        #### Run the Actual Simulation
        
        # taking time for creation of network structure
        tic("Finished creation of Network Structures")
        
        # transforming output table into list
        rhgCombinations <- split(OutputDataTable[,7:8], seq(nrow(OutputDataTable[,7:8])))
        
        # Generating List of Networks from Starting Point Network by adding
        # We generate r number of networks for each combination of h and g
        
        NetworkList <- pbmclapply(rhgCombinations,
                                NetworkGeneration,
                                m_passdown = m,
                                network=StartingPoint,
                                AddingNodes=nodes-2*m,
                                mc.cores = cores,
                                t_passdown = t,
                                majority_passdown = majority,
                                minority_passdown = minority,
                                majshape_passdown = majshape,
                                minshape_passdown = minshape,
                                majnorm_passdown = majnorm,
                                minnorm_passdown = minnorm,
                                majnormcolor_passdown = majnormcolor,
                                minnormcolor_passdown = minnormcolor)
        
        # Output Finished creation of network structures + time
        toc()
        
        # taking time for initialization of norms
        tic("Finished Initialization of Norms in all Networks")
        
        # We attach the majority group proportion parameter as an attribute of each network so we can pass them simultaneously
        # to the norm initialization function
        
        tic("Finished attaching majority norm endorsement to networks")
        AttachedMajGroupProp <- pbmcmapply(set.graph.attribute,NetworkList,name = "norm_end_maj",value = OutputDataTable[,3], SIMPLIFY=F, mc.cores = cores)
        toc()
        
        tic("Finished attaching minority norm endorsement to networks")
        NormNetworkList <- pbmcmapply(set.graph.attribute,AttachedMajGroupProp,name = "norm_end_min",value = OutputDataTable[,4], SIMPLIFY=F, mc.cores = cores)
        toc()
        
        # Initilaizing base norm norm distribution based on passed parameters
        NormNetworks <- pbmclapply(NormNetworkList,
                                     NormInit,
                                     mc.cores = cores,
                                     majority_passdown = majority,
                                     minority_passdown = minority,
                                     majshape_passdown = majshape,
                                     minshape_passdown = minshape,
                                     majnorm_passdown = majnorm,
                                     minnorm_passdown = minnorm,
                                     majnormcolor_passdown = majnormcolor,
                                     minnormcolor_passdown = minnormcolor)
        toc()
        
        cat("\n \n Granovetter Threshold Model - Norm Evolution:\n")
        
        # Granovetter Threshold Model
        
        # if t is a single numeric value, we assign each node in each network the attribute of said value
        # if it is uniform or normal, we generate the appropriate values for each network.
        if(is.numeric(t) & t <= 1 & t >= 0){
              
                # assigning every node in every network the same specified value
                tic("Finished assigning treshold values to nodes")
                NormInitNetworks <- pbmclapply(NormNetworks,
                                               function(x, t_passdown){V(x)$t <- t_passdown; return(x)},
                                               t,
                                               mc.cores = cores)
                # output info + time
                toc()
                
        } else if (t == "uniform"){
                
                # assigning random uniform values to all nodes in all networks
                tic("Finished assigning treshold values to nodes")
                NormInitNetworks <- pbmclapply(NormNetworks,
                                               function(x){V(x)$t <- runif(length(V(x)),0,1); return(x)},
                                               mc.cores=cores) 
                # output info + time
                toc()
                
        } else if (t == "normal"){
                
                # assigning random values from a normal distribution to all nodes in all networks determined by parameters tmean and tsd
                tic("Finished assigning trehsold values to nodes")
                NormInitNetworks <- pbmclapply(NormNetworks,
                                               function(x,tmeanpd,tsdpd){Values <- rnorm(length(V(x)),tmeanpd,tsdpd)
                                                                                     Values[Values>1] <- 1
                                                                                     Values[Values<0] <- 0
                                                                                     V(x)$t <- Values
                                                                                     return(x)
                                                                                     },
                                               tmean,tsd,
                                               mc.cores = cores) 
                
                # output info + time
                toc()
        }
        
        
        # Norm Updateing function using the Granovetter Threshold Model (saves every step of every model)
        
        if(UpdateProcess == "asynchronous"){
                
                # taking time for norm evolution
                tic("Finished Simulation of Norm Evolution in all networks")
          
                OutputNetworkList <- pbmclapply(NormInitNetworks,
                                              AsynchronousUpdateing,
                                              iter_passdown = iter,
                                              mc.cores = cores,
                                              majority_passdown = majority,
                                              minority_passdown = minority,
                                              majshape_passdown = majshape,
                                              minshape_passdown = minshape,
                                              majnorm_passdown = majnorm,
                                              minnorm_passdown = minnorm,
                                              majnormcolor_passdown = majnormcolor,
                                              minnormcolor_passdown = minnormcolor)
                
                # print timing and finish message
                toc()
                
                # removing NULL elements from the list (introduced trough breaking the function when attributes reached equilibrium)
                tic("Finished removing Null elements from network list \n \n")
                OutputNetworkList <- mclapply(OutputNetworkList,removeNULLs, mc.cores = cores)
                toc()
                
        } else if(UpdateProcess == "synchronous"){
                
                # taking time for norm evolution
                tic("Finished Simulation of Norm Evolution in all networks")
          
                OutputNetworkList <- pbmclapply(NormInitNetworks,
                                              SynchronousNormUpdateing,
                                              iter_passdown = iter,
                                              mc.cores = cores,
                                              majority_passdown = majority,
                                              minority_passdown = minority,
                                              majshape_passdown = majshape,
                                              minshape_passdown = minshape,
                                              majnorm_passdown = majnorm,
                                              minnorm_passdown = minnorm,
                                              majnormcolor_passdown = majnormcolor,
                                              minnormcolor_passdown = minnormcolor)
                
                toc()
                
                # removing NULL elements from the list (introduced trough breaking the function when attributes reached equilibrium)
                tic("Finished removing Null elements from network list")
                OutputNetworkList <- mclapply(OutputNetworkList,removeNULLs, mc.cores = cores)
                toc()
        }
        
        # saving the cleaned up Output Network list
        save(OutputNetworkList,file="OutputNetworkList.Rdata")
        
        # printing info
        cat("Extracting Distribution of Norms from Network Objects: \n")
        
        # taking time
        tic("Extracted distribution of Norms for all Networks")
        
        # Applying the extractor function to the list of all networks
        NormResults <- pbmclapply(OutputNetworkList,
                                Extractor,
                                mc.cores = cores,
                                majority_passdown = majority,
                                minority_passdown = minority,
                                majshape_passdown = majshape,
                                minshape_passdown = minshape,
                                majnorm_passdown = majnorm,
                                minnorm_passdown = minnorm,
                                majnormcolor_passdown = majnormcolor,
                                minnormcolor_passdown = minnormcolor)
        
        # print that data extraction if finished + time
        toc()
        
        # taking time
        tic("Finished creation of network feature dataframe")
        
        # We want to create an output file that gives us the distribution of norms in the groups at each iteration
        
        # First we need a vector that tells us how many iterations each model ran (e.g. how many networks we have for each line
        # in the perumatation table)
        IterationCounts <- sapply(NormResults,function(x){dim(x)[1]},USE.NAMES = FALSE)
        names(IterationCounts) <- NULL
        
        # Then we have to repeat the rows of the Permutation Parameter Dataframe as many times as we did iterations for
        # the parameter permutation
        OutputData <- OutputDataTable[,1:8]
        n.times <- IterationCounts
        OutputData <- OutputData[rep(seq_len(nrow(OutputData)), n.times),] # Sometimes we get an error in this step?
        # The error occurs because the network list structure is broken -> have a look at that -> Step by step!
        
        # we want an indicator for the iteration number
        IterationNumberList <- sapply(rownames(OutputData),strsplit,".",fixed=TRUE)
        IterationNumberSplit <- unlist(sapply(IterationNumberList,`[`,2))
        names(IterationNumberSplit) <- NULL
        IterationNumber <- as.numeric(IterationNumberSplit)
        IterationNumber[is.na(IterationNumber)] <- 0
        
        # and for the network number
        NetworkNumberList <- sapply(rownames(OutputData),strsplit,".",fixed=TRUE)
        NetworkNumberSplit <- unlist(sapply(IterationNumberList,`[`,1))
        names(NetworkNumberSplit) <- NULL
        NetworkNumber <- as.numeric(NetworkNumberSplit)
        
        # We now need to bind the iteration number to the output dataframe
        OutputData <- cbind.data.frame(OutputData,NetworkNumber)
        OutputData <- cbind.data.frame(OutputData,IterationNumber)
        OutputData <- OutputData[c("NetworkNumber","IterationNumber","nodes","iter","norm_end_maj","norm_end_min","t","m","g","h")]
        
        # next we convert the list of dataframes into a single dataframe
        CompleteNormsDF <- do.call("rbind", NormResults)
        
        # and attach it to the output data file
        Output <- cbind.data.frame(OutputData,CompleteNormsDF)
        
        # saving
        save(Output, file = "NormResultsDF.RData")
        
        # end time for data frame
        toc()
        
        # ensuring that we also create the plots when the animation is desired
        if(AnimatePlots == TRUE & CreatePlots == FALSE){
                
                CreatePlots <- TRUE
                
        }
        
        # creating plots for all iterations of all networks if desired
        if(CreatePlots == TRUE){
                
                cat("Creating Network Plots: \n")
                
                # setting the current directory as the main directory to create subdirectories
                mainDir <- getwd()
                
                # taking the time
                tic("Finished plotting of all Networks")
                
                # creating as many subdirectories as we have Networks in the outputNetworkList
                for(i in 1:length(OutputNetworkList)){
                        
                        # list of subdirs
                        subDir <- paste("OutputPlots",i,sep="")
                        
                        # creating folders
                        if (file.exists(subDir)){
                                warning("file or folder already exists")
                                stop()
                        } else {
                                dir.create(file.path(mainDir,subDir))
                                setwd(mainDir)
                        }
                        
                        # go to subdir
                        CurrDir <- paste0(mainDir,"/",subDir)
                        setwd(CurrDir)
                        
                        # For each element of the outputnetworklist, plot every iteration and save it in the corresponding folder
                        pbmclapply(seq_along(OutputNetworkList[[i]]),
                                 Plotter,
                                 mc.cores = cores,
                                 Slave_i = i,
                                 t_passdown = t,
                                 tmean_passdown = tmean,
                                 tsd_passdown = tsd,
                                 OutputNetworkList_passdown = OutputNetworkList,
                                 majority_passdown = majority,
                                 minority_passdown = minority,
                                 majshape_passdown = majshape,
                                 minshape_passdown = minshape,
                                 majnorm_passdown = majnorm,
                                 minnorm_passdown = minnorm,
                                 majnormcolor_passdown = majnormcolor,
                                 minnormcolor_passdown = minnormcolor)
                        
                        # We don´t need this if we´re using the pbmclapply progress bar
                        # cat(paste("Finished all Plots for Network",i,"of",length(OutputNetworkList)))
                        
                        # going up from the subdirectory again
                        setwd('..')
                }
                
                # outputting time
                toc()
                
                # cat exit
                cat("Finished Simulation, Analysis and Plotting of Networks\n")
        }
        
        # creating animations from generated plots if desired
        if(AnimatePlots == TRUE){
                
                # printing info
                cat("Creating Animations of Network Plots:\n")
                
                # taking time
                tic("Finished all Animations of all Network Plots:")
                
                # going to output folder
                # setwd(paste0(getwd(),"/Output"))
                
                # Creating new directory
                dir.create("Animations")
                
                # going into animation folder
                setwd(paste0(getwd(),"/Animations"))
                
                # looping through all network configurations
                for(i in 1:length(OutputNetworkList)){
                        
                        Animator2(OutputNetworkList[[i]],Slave_i = i)
                        
                        # creating animations
                        # pbmclapply(OutputNetworkList[[i]],
                        #            Animator2,
                        #            Slave_i = i,
                        #            mc.cores= cores)
                        # 
                }
                
                
                # going into the proper directory again
                setwd('..')
                setwd('..')
                
                # outputting time
                toc()
                
                # cat exit
                cat("-------------------SIMULATION, ANALYSIS PLOTTING & ANIMATION FINISHED---------------\n")

        }
        
        # end time for simulation
        toc()
        
        # going back to original wd
        setwd(oldwd)
}

