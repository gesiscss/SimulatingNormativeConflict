# Function to extract infromation at every iteration of each network

Extractor <- function(y,
                      majority_passdown = majority,
                      minority_passdown = minority,
                      majshape_passdown = majshape,
                      minshape_passdown = minshape,
                      majnorm_passdown = majnorm,
                      minnorm_passdown = minnorm,
                      majnormcolor_passdown = majnormcolor,
                      minnormcolor_passdown = minnormcolor){
        
        # Function for computing dyad percentages between demo groups and within demo groups
        DemoDyadBalance  <- function(z){
                
                # Getting a List of all dyads in the network
                DyadMat <- get.edgelist(z, names=TRUE)
                DyadList <- lapply(seq_len(nrow(DyadMat)), function(i) DyadMat[i,])
                
                # getting list of triangle node demo attributes
                DyadNetList <- lapply(DyadList,function(x){V(z)[unlist(x)]$demo})
                
                # Checking if the attribute is the same in all Dyads
                SameDemo <- lapply(DyadNetList, function(x){length(unique(unlist(x))) == 1})
                
                # counting the number of dyads with the same demo attribute
                NumberOfSameDemo <- sum(unlist(SameDemo))
                
                # returning count
                return(NumberOfSameDemo/nrow(DyadMat))
                
        }
        
        # Function for computing dyad percentages in majority group
        MajNormDyadBalance  <- function(z){
                
                # selecting subgraph consisting only of majority nodes
                MajGraph <- induced_subgraph(z, V(z)$demo == majority_passdown)
                
                # Getting a List of all dyads between majority nodes
                DyadMat <- get.edgelist(MajGraph, names=TRUE)
                DyadList <- lapply(seq_len(nrow(DyadMat)), function(i) DyadMat[i,])
                
                # getting list of majority dyad norm attributes
                DyadNetList <- lapply(DyadList,function(x){V(MajGraph)[unlist(x)]$norm})
                
                # Checking if the attribute is the same in all Dyads
                SameNorm <- lapply(DyadNetList, function(x){length(unique(unlist(x))) == 1})
                
                # Checking whether the attribute is majority_norm on majority_norm or  minority_norm on _minority norm
                NormCombinations <- sapply(DyadNetList[unlist(SameNorm)], paste, collapse = " ")
                
                # dealing with the special case of only one edge that is MajMin or MinMaj
                if(length(NormCombinations) == 0){
                        
                        PercentageOfSameNormMaj <- 0
                        PercentageOfSameNormMin <- 0
                        
                        
                } else if (length(NormCombinations) != 0){
                        
                        PercentageOfSameNormMaj <- table(NormCombinations)[paste(rep(majnorm_passdown,2),collapse = " ")]/nrow(DyadMat)
                        PercentageOfSameNormMin <- table(NormCombinations)[paste(rep(minnorm_passdown,2),collapse = " ")]/nrow(DyadMat)
                        
                }
                
                #summarizing
                Output <- c(nrow(DyadMat),PercentageOfSameNormMaj,PercentageOfSameNormMin)
                Output[is.na(Output)] <- 0
                names(Output) <- c("TotalEdgesInMaj","MajMajTies","MinMinTies")
                
                return(Output)
                
        }
        
        MajResults <- sapply(y,MajNormDyadBalance)
        
        # Function for computing dyad percentages in minority group
        MinNormDyadBalance  <- function(z){
                
                # selecting subgraph consisting only of minority nodes
                MinGraph <- induced_subgraph(z, V(z)$demo == minority_passdown)
                
                # Getting a List of all dyads in the network
                DyadMat <- get.edgelist(MinGraph, names=TRUE)
                DyadList <- lapply(seq_len(nrow(DyadMat)), function(i) DyadMat[i,])
                
                # getting list of triangle node norm attributes
                DyadNetList <- lapply(DyadList,function(x){V(MinGraph)[unlist(x)]$norm})
                
                # Checking if the attribute is the same in all Dyads
                SameNorm <- lapply(DyadNetList, function(x){length(unique(unlist(x))) == 1})
                
                # Checking whether the attribute is majority_norm on majority_norm or  minority_norm on _minority norm
                NormCombinations <- sapply(DyadNetList[unlist(SameNorm)], paste, collapse=" ")
                
                # dealing with the special case of only one edge that is MajMin or MinMaj
                if(length(NormCombinations) == 0){
                        
                        PercentageOfSameNormMaj <- 0
                        PercentageOfSameNormMin <- 0
                        
                        
                } else if (length(NormCombinations) != 0){
                        
                        PercentageOfSameNormMaj <- table(NormCombinations)[paste(rep(majnorm_passdown,2),collapse = " ")]/nrow(DyadMat)
                        PercentageOfSameNormMin <- table(NormCombinations)[paste(rep(minnorm_passdown,2),collapse = " ")]/nrow(DyadMat)
                        
                }
                
                #summarizing
                Output <- c(nrow(DyadMat),PercentageOfSameNormMaj,PercentageOfSameNormMin)
                Output[is.na(Output)] <- 0
                names(Output) <- c("TotalEdgesInMaj","MajMajTies","MinMinTies")
                
                return(Output)
                
        }
        
        MinResults <- sapply(y,MinNormDyadBalance)
        
        # Function for computing dyad norm percentages for between group edges
        BetweenGroupDyadBalance  <- function(z){
                
                # Getting a List of all dyads in the network
                DyadMat <- get.edgelist(z, names=TRUE)
                DyadList <- lapply(seq_len(nrow(DyadMat)), function(i) DyadMat[i,])
                
                # getting list of dyad node demo attributes
                DyadNetList <- lapply(DyadList,function(x){V(z)[unlist(x)]$demo})
                
                # getting list of dyad node norm attributes
                DyadNetNormList <- lapply(DyadList,function(x){V(z)[unlist(x)]$norm})
                
                # Checking if the demo attribute is the same in all Dyads (1 means they are the same)
                SameDemo <- lapply(DyadNetList, function(x){length(unique(unlist(x))) == 1})
                
                # getting the norm combinations for all edges that connect nodes from different demo groups
                NormCombinations <- sapply(DyadNetNormList[unlist(SameDemo) != TRUE], paste, collapse=" ")
                
                # dealing with the special case of no edges between the groups
                if(length(NormCombinations) == 0){
                        
                        PercentageOfSameNormMaj <- 0
                        PercentageOfSameNormMin <- 0
                        
                        PercentageofDiffNormMajMin <- 0
                        PercentageofDiffNormMinMaj <- 0
                        
                } else if (length(NormCombinations) != 0){
                        
                        PercentageOfSameNormMaj <- table(NormCombinations)[paste(rep(majnorm_passdown,2),collapse = " ")]/length(NormCombinations)
                        PercentageOfSameNormMin <- table(NormCombinations)[paste(rep(minnorm_passdown,2),collapse = " ")]/length(NormCombinations)
                        
                        PercentageofDiffNormMajMin <- table(NormCombinations)[paste(c(majnorm_passdown,minnorm_passdown),collapse = " ")]/length(NormCombinations)
                        PercentageofDiffNormMinMaj <- table(NormCombinations)[paste(c(minnorm_passdown,majnorm_passdown),collapse = " ")]/length(NormCombinations)       
                        
                }
                
                #summarizing
                Output <- c(length(NormCombinations),PercentageOfSameNormMaj,PercentageOfSameNormMin,PercentageofDiffNormMajMin,PercentageofDiffNormMinMaj)
                Output[is.na(Output)] <- 0
                names(Output) <- c("TotalEdgesBetweenGroups","%MajMajBetweenGroupTies","%MinMinBetweenGroupTies","%MajMinBetweenGroupTies","%MinMajBetweenGroupTies")
                
                return(Output)
                
        }
        
        BetweenResults <- sapply(y,BetweenGroupDyadBalance)
        
        # Functions to extract norm distributions at every step of the threshold model
        NoOfMajorityNodes <- sapply(y,function(x){length(V(x)[V(x)$demo== majority_passdown])})
        NoOfMinorityNodes <- sapply(y,function(x){length(V(x)[V(x)$demo== minority_passdown])})
        
        NumberofEdgesInGraph <- sapply(y,function(x){ecount(x)})
        TotalEdgesAmongMaj <- MajResults[1,1]
        TotalEdgesAmongMin <- MinResults[1,1]
        TotalEdgesBetweenGroups <- BetweenResults[1,1]
        
        MajorityNormPercentageOverall <- sapply(y, function(x){length(V(x)[V(x)$norm == majnorm_passdown])/vcount(x)})
        MajorityNormPercentageInMajority <- sapply(y, function(x){length(V(x)[V(x)$demo == majority_passdown & V(x)$norm == majnorm_passdown])/length(V(x)[V(x)$demo == majority_passdown])})
        MajorityNormPercentageInMinority <- sapply(y, function(x){length(V(x)[V(x)$demo == minority_passdown & V(x)$norm == majnorm_passdown])/length(V(x)[V(x)$demo == minority_passdown])})
        
        PercSameGroupEdges <- sapply(y,DemoDyadBalance)
        PercMajMajEdgesInMaj <- MajResults[2,]
        PercMinMinEdgesInMaj <- MajResults[3,]
        PercMajMajEdgesInMin <- MinResults[2,]
        PercMinMinEdgesInMin <- MinResults[3,]
        
        PercMajMajEdgesBetween <- BetweenResults[2,]
        PercMinMinEdgesBetween <- BetweenResults[3,]
        PercMajMinEdgesBetween <- BetweenResults[4,]
        PercMinMajEdgesBetween <- BetweenResults[5,]
        
        
        
        # binding results into a dataframe and returning it
        NormDist1Net <- cbind.data.frame(NoOfMajorityNodes,
                                         NoOfMinorityNodes,
                                         NumberofEdgesInGraph,
                                         TotalEdgesAmongMaj,
                                         TotalEdgesAmongMin,
                                         TotalEdgesBetweenGroups,
                                         MajorityNormPercentageOverall,
                                         MajorityNormPercentageInMajority,
                                         MajorityNormPercentageInMinority,
                                         PercSameGroupEdges,
                                         PercMajMajEdgesInMaj,
                                         PercMinMinEdgesInMaj,
                                         PercMajMajEdgesInMin,
                                         PercMinMinEdgesInMin,
                                         PercMajMajEdgesBetween,
                                         PercMinMinEdgesBetween,
                                         PercMajMinEdgesBetween,
                                         PercMinMajEdgesBetween,
                                         row.names = NULL)
        
        # returning dataframe
        return(NormDist1Net)
                                   
    # free memory
		gc(verbose=TRUE)
}
