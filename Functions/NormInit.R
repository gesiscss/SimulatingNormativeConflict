# Function to initialize norms in created networks based on majority and minority norm endorsement parameters

NormInit <- function (network,
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
        V(network)$norm[V(network)$demo == majority_passdown] <- sample(length(V(network)$norm[V(network)$demo == majority_passdown]),x = c(majnorm_passdown,minnorm_passdown),prob = c(network$norm_end_maj,(1-network$norm_end_maj)), replace = TRUE)
        V(network)$norm[V(network)$demo == minority_passdown] <- sample(length(V(network)$norm[V(network)$demo == minority_passdown]),x = c(majnorm_passdown,minnorm_passdown),prob = c(network$norm_end_min,(1-network$norm_end_min)), replace = TRUE)
        
        # translating into colors for plotting
        V(network)$color[V(network)$norm == majnorm_passdown] <- majnormcolor_passdown
        V(network)$color[V(network)$norm == minnorm_passdown] <- minnormcolor_passdown
        
        # returning network object
        return(network)
        
}