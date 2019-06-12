### Function for animating evolution of network structures in 3D by creating an HTML widget

HTMLAnimator <- function(NetList,
                      Slave_i = i){
        
        # creating base object (deleting color vector so it doesn´t automatically get chosen)
        net.js <- NetList[[1]]
        net.js <- delete_vertex_attr(net.js, "color")
        
        # creating a static layout so it doesn´t get recreated on each frame
        staticLayout  <- layout_with_fr(net.js,  dim=3)
        
        # creating animation object
        Animation <- graphjs(net.js, bg="gray10",
                             showLabels=F,
                             stroke=F, 
                             layout=replicate(length(NetList),staticLayout, simplify=FALSE),
                             vertex.color=lapply(NetList,function(x){V(x)$color}),
                             main=as.list(rep(paste0("Network ",Slave_i),length(NetList)))
        )
        
        # saving animation object
        saveWidget(Animation, file=paste0("HTML_Network_Evolution_Animation_",Slave_i,".html"))
        
}
