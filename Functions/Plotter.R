### Function to generate plots of listed networks (only usefull for networks with up to 100 nodes)

Plotter <- function(n,
                    Slave_i=i,
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
                    minnormcolor_passdown = minnormcolor){
        
        # set up picture device
        jpeg(paste0("Network_",Slave_i,"_Plot_",n,".jpg"),
             quality = 100)
        
        
        ### plotting network
        
        # ensuring each iteration has the same layout by including a seed
        set.seed(123)
        
        # creating network plot
        NetworkPlot <- plot(OutputNetworkList_passdown[[Slave_i]][[n]],
                            vertex.size = 10,
                            layout=layout_with_kk,
                            vertex.color = V(OutputNetworkList_passdown[[Slave_i]][[n]])$color,
                            edge.color = "black",
                            vertex.label = round(V(OutputNetworkList_passdown[[Slave_i]][[n]])$t,2),
                            main = paste("Iteration ",n,"of network ",Slave_i),
                            label.cex = 0.6)
        
        # adding legend for shapes and colors
        legend(x= "bottomleft", legend=c(paste(majority_passdown,majnorm_passdown),
                                         paste(minority_passdown,majnorm_passdown),
                                         paste(majority_passdown,minnorm_passdown),
                                         paste(minority_passdown,minnorm_passdown)),
               col = c(majnormcolor_passdown,majnormcolor_passdown,minnormcolor_passdown,minnormcolor_passdown),
               pch = c(15,16,15,16),
               xpd = TRUE,
               inset = c(-0.1,-0.2),
               bty = "n")
        
        
        # displaying parameters of the network
        
        if(t_passdown == "uniform" | is.numeric(t_passdown)){
                
                legend(x= "bottomright",
                       legend=c(paste("pmaj = ",OutputNetworkList_passdown[[Slave_i]][[n]]$norm_end_maj),
                                paste("pmin = ",OutputNetworkList_passdown[[Slave_i]][[n]]$norm_end_min),
                                paste("t = ",t_passdown),
                                paste("m = ",OutputNetworkList_passdown[[Slave_i]][[n]]$m),
                                paste("g = ",OutputNetworkList_passdown[[Slave_i]][[n]]$g),
                                paste("h = ",OutputNetworkList_passdown[[Slave_i]][[n]]$h)),
                       xpd = TRUE,
                       inset = c(0,-0.2),
                       bty = "n")
                
        } else if (t_passdown == "normal") {
                
                legend(x= "bottomright",
                       legend=c(paste("pmaj = ",OutputNetworkList_passdown[[Slave_i]][[n]]$norm_end_maj),
                                paste("pmin = ",OutputNetworkList_passdown[[Slave_i]][[n]]$norm_end_min),
                                paste("t = ",t_passdown, ";M = ",tmean_passdown,";SD = ",tsd_passdown),
                                paste("m = ",OutputNetworkList_passdown[[Slave_i]][[n]]$m),
                                paste("g = ",OutputNetworkList_passdown[[Slave_i]][[n]]$g),
                                paste("h = ",OutputNetworkList_passdown[[Slave_i]][[n]]$h)),
                       xpd = TRUE,
                       inset = c(0,-0.2),
                       bty = "n")
        }
        
        
        # saving to working directory
        dev.off()
        
        # removing setting of the seed to generate new random numbers
        set.seed(Sys.time())
}

