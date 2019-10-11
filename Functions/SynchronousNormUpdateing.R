### Function to update all nodes in the networks synchronously at the same time

SynchronousNormUpdateing <- function(network,
                                     iter_passdown = iter,
                                     majority_passdown = majority,
                                     minority_passdown = minority,
                                     majshape_passdown = majshape,
                                     minshape_passdown = minshape,
                                     majnorm_passdown = majnorm,
                                     minnorm_passdown = minnorm,
                                     majnormcolor_passdown = majnormcolor,
                                     minnormcolor_passdown = minnormcolor) {
        
        # The function for updateing norms
        UpdateNorm <- function (node){
                
                # we switch off warning because R prints a useless warning for using subgraph()
                options(warn=-1)
                
                # getting a vector of all neighbors of the node (including the node itself)
                neighbours <- ego(network,1,node,"all",mindist=0)
                
                # building a graph object of only the neighbors of the node
                NeighborGraph <- induced_subgraph(network,names(unlist(neighbors)))
                
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
                
                # returning updated network object
                return(NewNorm)
        }
        
        # creating a nested list for saving the generated networks and some descriptive
        # statistics of their properties
        
        NestedList <- list()
        
        # we have to update all nodes 
        for(n in 1:iter_passdown){
                
                # Applying the function to all Nodes
                NewNorms <- sapply(names(V(network)),UpdateNorm)
                
                # Updating the norms attributes of the input network
                V(network)$norm <- NewNorms
                
                # setting color attributes
                V(network)$color[V(network)$norm  == majnorm_passdown] <- majnormcolor_passdown
                V(network)$color[V(network)$norm  == minnorm_passdown] <- minnormcolor_passdown
                
                # saving the generated network
                NestedList[[n]] <- network
                
                
        }
        
        # returning updated Network list
        return(NestedList)
}
