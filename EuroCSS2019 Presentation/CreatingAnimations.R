############## Creating an Animation for the network generation algortihm we are using

# TO DO
# - check if Gifksi animation is working now

# setting wd to source file location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# libraries
library(igraph)
library(ggnet)
library(ggplot2)
library(magick)
library(gifski)

# First of all, we need a function to generate a starting point based on some input parameters
m = 2
h = 0.9
g = 0.2
rhgCombinations <- cbind.data.frame(g,h)
t = "uniform"
iter = 50
norm_end_maj = 0.6
norm_end_min = 0.4

majority = "Group A"
minority = "Group B"
majshape = "square"
minshape = "circle"
majnorm = "Norm 1"
minnorm = "Norm 2"
majnormcolor = "lightblue"
minnormcolor = "lightcoral"

GenerateStartingPoint <- function(m_passdown = m,
                                  majority_passdown = majority,
                                  minority_passdown = minority,
                                  majshape_passdown = majshape,
                                  minshape_passdown = minshape){

        # creating vertex names based on m
        VertexNames <- as.character(1:(2*m_passdown))

        # Splitting them in half to get two seperate parts for the starting point network
        VertexNamesA <- VertexNames[VertexNames[1]:median(as.numeric(VertexNames))]
        VertexNamesB <- VertexNames[(median(as.numeric(VertexNames)) + 1):(as.numeric(VertexNames[length(VertexNames)]) + 1)]

        # creating vector of unique combinations as edges for complete unidirectional graph
        EdgesA <- as.numeric(as.vector(combn(VertexNamesA,m = 2)))
        EdgesB <- as.numeric(as.vector(combn(VertexNamesB,m = 2)))

        # creating graph
        StartingPoint <- graph(as.character(c(EdgesA,EdgesB)), directed = FALSE)

        # creating group attributes
        V(StartingPoint)$demo <- c(rep(majority_passdown,m_passdown),rep(minority_passdown,m_passdown))

        # translating to Vertex shape
        V(StartingPoint)$shape[V(StartingPoint)$demo  == majority_passdown] <- majshape_passdown
        V(StartingPoint)$shape[V(StartingPoint)$demo  == minority_passdown] <- minshape_passdown

        return(StartingPoint)
}

network <- GenerateStartingPoint()

# Now we need a function that adds 1 new node to the network at a time

AddANode <- function(network,
                        rhgcombinations_passdown = rhgCombinations,
                        AddingNodes = 1,
                        m_passdown = m,
                        t_passdown = t,
                        majority_passdown = majority,
                        minority_passdown = minority,
                        majshape_passdown = majshape,
                        minshape_passdown = minshape,
                        majnorm_passdown = majnorm,
                        minnorm_passdown = minnorm){

        # splitting up the combined input of h and g into two seperate values
        h <- rhgcombinations_passdown[1,2]
        g <- rhgcombinations_passdown[1,1]

        for (i in 1:AddingNodes) {

                # First, we need to generate a name for the new node
                NewNodeName <- as.character(length(V(network)) + 1)

                NewVertex <- vertex(NewNodeName)

                # We randomly sample the group membership of new node with probability g
                # for the first group and 1-g for the second group
                NewDemo <- sample(c(minority_passdown,majority_passdown),1,prob = c(g,(1 - g)))
                NewVertex$demo <- NewDemo

                # getting the degree of of all nodes
                Degrees <- igraph::degree(network)

                # creating a list of numerators for all nodes (multiplying node degree with homophily parameter based on group membership of new node)
                WeightedSameGroupNodeDegrees <- Degrees[V(network)$demo == NewDemo]*h
                WeightedOtherGroupNodeDegrees <- Degrees[V(network)$demo != NewDemo]*(1 - h)

                # Calculating connection probabilities
                EdgeFormProb <- c(WeightedSameGroupNodeDegrees,WeightedOtherGroupNodeDegrees)/sum(Degrees[V(network)$demo == NewDemo]*h, Degrees[V(network)$demo != NewDemo]*(1 - h))

                # Sorting Connection Probabilities by their name/Index
                EdgeFormProb <- EdgeFormProb[order(as.numeric(names(EdgeFormProb)))]

                # Initiating vector of chosen nodes
                ChosenNodes <- rep("String",m_passdown)

                # Applying Roulette Wheel Selection using Edge Formation Probabilities to choose m nodes to connect to
                for (i in 1:m_passdown) {

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

# creating a network with 100 nodes iteratively

networks <- list()
networks[[1]] <- network
counter1 <- 1

while (counter1 < 97) {

        network <- AddANode(network)
        networks[[counter1 + 1]] <- network
        counter1 <<- counter1 + 1

}

############## We now also want to initialize the norms and see the granovetter mdoel in action

NormNet <- networks[[97]]
NormNet$norm_end_maj <- norm_end_maj
NormNet$norm_end_min <- norm_end_min


NormInit <- function(network,
                      majority_passdown = majority,
                      minority_passdown = minority,
                      majshape_passdown = majshape,
                      minshape_passdown = minshape,
                      majnorm_passdown = majnorm,
                      minnorm_passdown = minnorm,
                      majnormcolor_passdown = majnormcolor,
                      minnormcolor_passdown = minnormcolor){

        # initializing norm vector
        V(network)$norm <- seq_along(V(network))

        # assigning norms probabilistically based on group membership, majority norm endorsement and minority norm endorsement
        V(network)$norm[V(network)$demo == majority_passdown] <- sample(length(V(network)$norm[V(network)$demo == majority_passdown]),x = c(majnorm_passdown,minnorm_passdown),prob = c(network$norm_end_maj,(1 - network$norm_end_maj)), replace = TRUE)
        V(network)$norm[V(network)$demo == minority_passdown] <- sample(length(V(network)$norm[V(network)$demo == minority_passdown]),x = c(majnorm_passdown,minnorm_passdown),prob = c(network$norm_end_min,(1 - network$norm_end_min)), replace = TRUE)

        # translating into colors for plotting
        V(network)$color[V(network)$norm == majnorm_passdown] <- majnormcolor_passdown
        V(network)$color[V(network)$norm == minnorm_passdown] <- minnormcolor_passdown

        # returning network object
        return(network)
}

# applying function
NormIniNet <- NormInit(NormNet)

# initializing threshold distribution for UNIFORM threshold #####################################
V(NormIniNet)$t <- runif(length(V(NormIniNet)),0,1)


## Updating function:

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
        UpdateNorm <- function(node){

                # we switch off warning because R prints a useless warning for using subgraph()
                options(warn = -1)

                # getting a vector of nodes in the ego-network of the node
                neighbours <- ego(network,1,node,"all",mindist = 1)

                # building a graph object of only the neighbors of the node
                NeighborGraph <- induced_subgraph(network,names(unlist(neighbours)))

                # creating a sorted proportion table for their norm attributes
                PropTable <- sort(prop.table(table(V(NeighborGraph)$norm)), decreasing = TRUE)

                # deleting these attributes whose proportion is not above the threshold
                PropTable <- PropTable[PropTable > V(network)[node]$t]

                # If no attributes are above the threshold, we do nothing, if yes, then we adopt the remaining
                # attribute with the largest proportion among the nodes neighbors
                if (length(PropTable) == 0) {

                        NewNorm <- V(network)[node]$norm

                } else if (length(PropTable) == 1) {

                        NewNorm <- names(PropTable[1])

                } else if (length(PropTable) == 2 & length(unique(PropTable)) == 1) {

                        NewNorm <- names(sample(PropTable))[1]

                } else if (length(PropTable) == 2 & length(unique(PropTable)) == 2) {

                        NewNorm <- names(PropTable[1])

                } else {}

                # we switch the warnings back on again and return the vector with the updated norms
                options(warn = 0)

                # Assigning the new norm to the updated node
                V(network)[node]$norm <- NewNorm

                # Updateing color attribute of the updated node
                V(network)[node]$color[V(network)[node]$norm == majnorm_passdown] <- majnormcolor_passdown
                V(network)[node]$color[V(network)[node]$norm == minnorm_passdown] <- minnormcolor_passdown

                #returning network object with one updated node
                return(network)
        }

        # creating a nested list for saving the generated networks and some descriptive
        # statistics of their properties

        NestedList <- vector("list", iter_passdown + 1)
        NestedList[[1]] <- network

        # we have to update all nodes (going through the randomOrder once) MaxIterations
        # number of times with the updated network from the previous round as input to the next round

        for (n in 1:iter_passdown) {

                # randomly shuffle the list of vertices
                RandomOrder <- sample(V(network))

                # We need to use the update norm function on every element of the shuffled Vector of nodes

                for (i in RandomOrder) {

                        network <- UpdateNorm(i)

                }

                # saving the generated network
                NestedList[[n + 1]] <- network
        }

        # returning updated List of networks
        return(NestedList)
}

GranoList <- AsynchronousUpdateing(NormIniNet)


identical(GranoList[[1]],GranoList[[51]])

plot(GranoList[[1]])
plot(GranoList[[2]])
plot(GranoList[[3]])
plot(GranoList[[4]])



# Testing

# distribution of Groups
table(V(GranoList[[1]])$demo)


igraph::degree(GranoList[[1]])

mean(igraph::degree(induced_subgraph(GranoList[[1]], V(GranoList[[1]])[V(GranoList[[1]])$demo == "Group A"])))

mean(igraph::degree(induced_subgraph(GranoList[[1]], V(GranoList[[1]])[V(GranoList[[1]])$demo == "Group B"])))


######################## ANIMATING THE NETWORK GENERATION ALGORITHM

# lets try if this one looks better: Way better!
library(intergraph)
set.seed(12345)
ggnet2(networks[[97]],
       shape = V(networks[[97]])$demo,
       shape.palette = c("Group A" = 15, "Group B" = 19))


# we need to create and save a plot for each network with ggnet

# first we need to convert the igraph network to a ggnet network (and carrying over vertex attributes)
net <- as.network(as_adj(networks[[97]]))
net %v% "demo" = V(networks[[97]])$demo
net %v% "shape" = V(networks[[97]])$shape
net %v% "name" = V(networks[[97]])$name

# visualization
set.seed(123)
ggnet2(net,
        mode = "kamadakawai",
        size = "degree",
        color = "demo",
        shape = "shape",
        shape.palette = c("circle" = 19, "square" = 15),
        color.palette = c("Minority Group" = "black", "Majority Group" = "grey")) +
        guides(size = FALSE, shape = FALSE, color = guide_legend("Group", override.aes = list(shape = c(19,15))))

# creating vectors for node coordinates in full graph
x = gplot.layout.fruchtermanreingold(net, NULL)
net %v% "x" = x[, 1]
net %v% "y" = x[, 2]


# creating matrix to indicate whether node is present in iteration
mat <- matrix(data = 0, nrow = 100, ncol = 100)
mat <- lower.tri(mat, diag = TRUE)
mat <- mat*1
mat[mat == 0] <- NA
mat <- mat[4:100,]
dim(mat)

# we need to attach the NA attribute as vertex attributes
for (i in 1:dim(mat)[1]) {

        net %v% paste0("Iteration_",i) <- mat[i,]


}

# test plot
ggnet2(net,
       mode = c("x", "y"),
       size = "degree",
       color = "demo",
       shape = "shape",
       shape.palette = c("circle" = 19, "square" = 15),
       color.palette = c("Minority Group" = "black", "Majority Group" = "grey"),
       na.rm = "Iteration_45") +
       guides(size = F, shape = F, color = guide_legend("Group", override.aes = list(shape = c(19,15))))


ggsave(paste0("Network_97"), device = "jpeg")


# saving all the different plots in a folder
setwd("./GenerationPlots")

for (i in 1:97) {

        # plotting iteration
        ggnet2(net,
               mode = c("x", "y"),
               size = "degree",
               color = "demo",
               shape = "shape",
               shape.palette = c("circle" = 19, "square" = 15),
               color.palette = c("Group B" = "black", "Group A" = "grey"),
               na.rm = paste0("Iteration_",i)) +
               guides(size = FALSE, shape = FALSE, color = guide_legend("Group", override.aes = list(shape = c(19,15))))

        # saving iteration
        ggsave(paste0("Iteration_",i,".jpg"), device = "jpeg")

}


# Animate generated plots
GIFAnimator <- function(){

        # list all image files in the subdir
        Plots <- list.files(full.names = TRUE, recursive = TRUE, pattern = ".jpg$")

        # order them correctly
        Plots <- Plots[order(nchar(Plots),Plots)]

        # saving animation
        image_write_gif(image_read(Plots),path = "Network.gif")
}

# do it
GIFAnimator()






#################### ANIMATING THE GRANOVETTER ALGORITHM

GranoList
# lets try if this one looks better: Way better!
library(intergraph)
set.seed(12345)


Granonet <- as.network(as_adj(GranoList[[1]]))
Granonet %v% "demo" = V(GranoList[[1]])$demo
Granonet %v% "shape" = V(GranoList[[1]])$shape
Granonet %v% "name" = V(GranoList[[1]])$name
Granonet %v% "color" = V(GranoList[[1]])$color
Granonet %v% "norm" = V(GranoList[[1]])$norm

# Test graph
set.seed(123)
ggnet2(Granonet,
       mode = "kamadakawai",
       size = "degree",
       color = "norm",
       shape = "demo",
       shape.palette = c("Group B" = 19, "Group A" = 15),
       color.palette = c("Norm 1" = "lightblue", "Norm 2" = "lightcoral")) +
       guides(size = FALSE, shape = guide_legend("Group - Shape"), color = guide_legend("Norm - Color"))


# creating vectors for node coordinates in full graph
FixedLayout = gplot.layout.fruchtermanreingold(Granonet, NULL)


# new wd
# saving all the different plots in a folder
setwd("../GranoPlots")

for (i in seq_along(GranoList)) {

        # defining network
        Granonet <- as.network(as_adj(GranoList[[i]]))
        Granonet %v% "demo" = V(GranoList[[i]])$demo
        Granonet %v% "shape" = V(GranoList[[i]])$shape
        Granonet %v% "name" = V(GranoList[[i]])$name
        Granonet %v% "color" = V(GranoList[[i]])$color
        Granonet %v% "norm" = V(GranoList[[i]])$norm

        # creating plots
        ggnet2(Granonet,
               mode = FixedLayout,
               size = "degree",
               color = "norm",
               shape = "demo",
               shape.palette = c("Group B" = 19, "Group A" = 15),
               color.palette = c("Norm 1" = "lightblue", "Norm 2" = "lightcoral")) +
               guides(size = FALSE, shape = guide_legend("Group - Shape"), color = guide_legend("Norm - Color"))


        # saving iteration
        ggsave(paste0("GranoIteration_",i,".jpg"), device = "jpeg")
}


# Animate generated plots
GIFAnimator <- function(){

        # list all image files in the subdir
        Plots <- list.files(full.names = TRUE, recursive = TRUE, pattern = ".jpg$")

        # order them correctly
        Plots <- Plots[order(nchar(Plots),Plots)]

        # saving animation
        image_write_gif(image_read(Plots),path = "GranoNetwork.gif")
}

# do it
GIFAnimator()
