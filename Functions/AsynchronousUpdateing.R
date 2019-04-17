### Function to update all nodes in the network once in a random order (asynchronous updateing)

AsynchronousUpdateing <- function(network,
         iter_passdown = iter,
         majority_passdown = majority,
         minority_passdown = minority,
         majshape_passdown = majshape,
         minshape_passdown = minshape,
         majnorm_passdown = majnorm,
         minnorm_passdown = minnorm,
         majnormcolor_passdown = majnormcolor,
         minnormcolor_passdown = minnormcolor) {
        
        # Updates the norm of one node and returns the updated network object
        UpdateNorm <- function (node){
                
                # we switch off warning because R prints a useless warning for using subgraph()
                options(warn=-1)
                
                # getting a vector of nodes in the ego-network of the node
                neighbours <- ego(network,1,node,"all",mindist=1)
                
                # building a graph object of only the neighbors of the node
                NeighborGraph <- induced_subgraph(network,names(unlist(neighbours)))
                
                # creating a sorted proportion table for their norm attributes
                PropTable <- sort(prop.table(table(V(NeighborGraph)$norm)), decreasing = TRUE)
                
                # deleting these attributes whose proportion is not above the threshold
                PropTable <- PropTable[PropTable > V(network)[node]$t]
                
                # If no attributes are above the threshold, we do nothing, if yes, then we adopt the remaining
                # attribute with the largest proportion among the nodes neighbors
                if(length(PropTable) == 0){
                        
                        NewNorm <- V(network)[node]$norm
                        
                } else if(length(PropTable) == 1) {
                        
                        NewNorm <- names(PropTable[1])
                        
                } else if(length(PropTable) == 2 & length(unique(PropTable)) == 1) {
                  
                  NewNorm <- names(sample(PropTable))[1]
                  
                } else if(length(PropTable) == 2 & length(unique(PropTable)) == 2) {
                  
                  NewNorm <- names(PropTable[1])
                  
                } else {}
                
                # we switch the warnings back on again and return the vector with the updated norms
                options(warn=0)
                
                # Assigning the new norm to the updated node
                V(network)[node]$norm <- NewNorm
                
                # Updateing color attribute of the updated node
                V(network)[node]$color[V(network)[node]$norm == majnorm_passdown] <- majnormcolor_passdown
                V(network)[node]$color[V(network)[node]$norm == minnorm_passdown] <-  minnormcolor_passdown
                
                #returning network object with one updated node
                return(network)
        }
        
        # creating a nested list for saving the generated networks and some descriptive
        # statistics of their properties
        
        NestedList <- vector("list", iter_passdown+1)
        NestedList[[1]] <- network
        
        # we have to update all nodes (going through the randomOrder once) MaxIterations
        # number of times with the updated network from the previous round as input to the next round
        
        for(n in 1:iter_passdown){
        
        # randomly shuffle the list of vertices
        RandomOrder <- sample(V(network))
        
        # We need to use the update norm function on every element of the shuffled Vector of nodes
        
                for (i in RandomOrder){
                
                network <- UpdateNorm(i)
                
                }
        
        # We break the loop if the created network is identical to the previous one (commented out
        # for asynchronous networks because the same network might result in different outcomes with
        # a different updating order)
        
        # if(identical(network,NestedList[[n]],ignore.environment = TRUE)){
                
        #        break()
        # }
        
        # saving the generated network
        NestedList[[n+1]] <- network
        
        # We don´t need this ouput if we are using the pbmclapply wrapper to create a progress bar
        # print(paste("Finished iteration",n, "of",iter_passdown))
        
        }
        
        # We don´t need this ouput if we are using the pbmclapply wrapper to create a progress bar
        # print(paste("Finished all iterations of one parameter configuration"))
        
        # returning updated List of networks
        return(NestedList)
}
