### Function to generate starting point networks based on parameters: m and demographic characteristics with corresponding shapes

GenerateStartingPoint <- function(m_passdown = m,
                                  majority_passdown = majority,
                                  minority_passdown = minority,
                                  majshape_passdown = majshape,
                                  minshape_passdown = minshape){
        
        # creating vertex name sbased on m
        VertexNames <- as.character(1:(2*m_passdown))
        
        # Splitting them in half to get two speerate parts for the starting point network
        VertexNamesA <- VertexNames[VertexNames[1]: median(as.numeric(VertexNames))]
        VertexNamesB <- VertexNames[(median(as.numeric(VertexNames)) + 1): (as.numeric(VertexNames[length(VertexNames)])+1)]
        
        # creating vector of unique combinations as edges for complete unidirectional graph
        EdgesA <- as.numeric(as.vector(combn(VertexNamesA,m=2)))
        EdgesB <- as.numeric(as.vector(combn(VertexNamesB,m=2)))
        
        # creating graph
        StartingPoint <- graph(as.character(c(EdgesA,EdgesB)), directed = FALSE)
        
        # creating group attributes
        V(StartingPoint)$demo <- c(rep(majority_passdown,m_passdown),rep(minority_passdown,m_passdown))
        
        # translating to Vertex shape
        V(StartingPoint)$shape[V(StartingPoint)$demo  == majority_passdown] <- majshape_passdown
        V(StartingPoint)$shape[V(StartingPoint)$demo  == minority_passdown] <- minshape_passdown
        
        return(StartingPoint)
}
