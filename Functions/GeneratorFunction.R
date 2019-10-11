### Function to generate Networks from starting point based on group size parameter, preferential attachment and homophily parameter

NetworkGeneration <- function(network,
         rhgcombinations_passdown = rhgCombinations,
         AddingNodes = 96,
         m_passdown = m,
         t_passdown = t,
         p_passdown = p,
         majority_passdown = majority,
         minority_passdown = minority,
         majshape_passdown = majshape,
         minshape_passdown = minshape,
         majnorm_passdown = majnorm,
         minnorm_passdown = minnorm,
         majnormcolor_passdown = majnormcolor,
         minnormcolor_passdown = minnormcolor){
        
        # splitting up the combined input of h and g into two seperate values
        h <- rhgcombinations_passdown[1,2]
        g <- rhgcombinations_passdown[1,1]
        
        # Our algorithm depends on a vertex attribute called group, so we need to check whether such an attribute exists
        if(length(V(network)$demo) == 0){
                
                warning("Vertices need an attribute called group.")
                stop()
        }
        
        # The algorithm is only meaningfull for parameters of h between 0 and 1, so we only allow h to take this range
        if(h < 0 | h > 1){
                
                warning("parameter h must be between 0 and 1")
                stop()
                
        }
        
        # m needs to be larger than one but smaller or equal to the number of nodes in the initial network
        if(m_passdown < 1 | m_passdown > length(V(network))){
                
                warning("m needs to be larger than one but smaller or equal to the number of nodes in the initial network")
                stop()
        }
                
        for (i in 1:AddingNodes) {
                
        # First, we need to generate a name for the new node
        NewNodeName <- as.character(length(V(network)) + 1)
        
        NewVertex <- vertex(NewNodeName)
        
        # We randomly sample the group membership of new node with probability g
        # for the first group and 1-g for the second group
        NewDemo <- sample(c(minority_passdown,majority_passdown),1,prob = c(g,(1-g))) 
        NewVertex$demo <- NewDemo
        
        # getting the degree of of all nodes
        Degrees <- degree(network)
        
        # creating a list of numerators for all nodes (multiplying node degree with homophily parameter based on group membership of new node)
        WeightedSameGroupNodeDegrees <- Degrees[V(network)$demo == NewDemo]*h
        WeightedOtherGroupNodeDegrees <- Degrees[V(network)$demo != NewDemo]*(1-h)
        
        # Calculating connection probabilities
        EdgeFormProb <- c(WeightedSameGroupNodeDegrees,WeightedOtherGroupNodeDegrees)/sum(Degrees[V(network)$demo == NewDemo]*h, Degrees[V(network)$demo != NewDemo]*(1-h))
        
        # Sorting Connection Probabilities by their name/Index
        EdgeFormProb <- EdgeFormProb[order(as.numeric(names(EdgeFormProb)))]
        
        # Initiating vector of chosen nodes
        ChosenNodes <- rep("String",m_passdown)
        
        # Applying Roulette Wheel Selection using Edge Formation Probabilities to choose m nodes to connect to
        for (i in 1:m_passdown){
                
                # Updateing EdgeFormProb so it won't include nodes that have been picked in previous runs
                EdgeFormProbUpdate <- EdgeFormProb[!is.element(names(EdgeFormProb),ChosenNodes)]
                
                # Pick a random number from a uniform distribution from 0 to the maximum of the cumulative sum of all updated edge form probabilities
                RandPick <- runif(n = 1, min = 0, max = max(cumsum(EdgeFormProbUpdate)))
                
                # Returning a True/False vector for whether the random pick is larger than the cumulative sum of probabilities
                RoulettePick <-  RandPick >= cumsum(EdgeFormProbUpdate)
                
                # choosing the first name of the first vertex whose cumulative probability is not bigger than the random number
                ChosenNodes[i] <- names(EdgeFormProbUpdate[sum(RoulettePick) + 1])
                
        }
        
        # forming a vector of edges for the node to be added
        NewSenders <- rep(NewNodeName,length(ChosenNodes))
        
        # forming a list of new edges
        EdgeList  <- paste(NewSenders, ChosenNodes)
        EdgeList <- unlist(strsplit(EdgeList," "))
        
        # adding new vertex and edges to the network
        network <- network + NewVertex
        network <- network + edges(EdgeList)
        
        # setting shape attributes
        V(network)$shape[V(network)$demo  == majority_passdown] <-  majshape_passdown
        V(network)$shape[V(network)$demo  == minority_passdown] <-  minshape_passdown
        
        }
        
        # attaching parameters as attributes of the network
        network$h <- h
        network$g <- g
        network$t <- t_passdown
        network$m <- m_passdown
        
        # return network
        return(network)
        
}
