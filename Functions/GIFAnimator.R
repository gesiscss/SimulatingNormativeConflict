### Animator function for pasting all generated pictures together

GIFAnimator <- function(dir){
        
        # going to directory with files
        setwd(dir)
        
        # list all image files in the subdir
        Plots <- list.files(full.names=TRUE, recursive=TRUE, pattern = ".jpg$")
        
        # order them correctly
        Plots <- Plots[order(nchar(Plots),Plots)]
        
        # creating frames for animation (we can use read_plots() directly because it is vectorized)
        frames <- image_morph(image_read(Plots), frames = 3)
        
        #creating animation
        animation <- image_animate(frames)
        
        # saving animation
        image_write(animation, paste0("Network",substr(dir,14,nchar(dir)),".gif"))
        
        #going up to the main dir again
        setwd("..")
}
