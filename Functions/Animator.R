### Animator function for pasting all generated pictures together

Animator <- function(dir){
        
        # getting current wd
        mainDir <- getwd()

        # creating subdir
        subDir <- paste0(mainDir,substr(dir,2,nchar(dir)))

        # going to subdir
        setwd(subDir)
        
        # list all image file in the subdir
        Plots <- list.files(full.names=TRUE, recursive=TRUE, pattern = ".jpg$")
        
        # order them correctly
        Plots <- Plots[order(nchar(Plots),Plots)]
        
        # creating frames for animation (we can use read_plots() directly because it is vectorized)
        frames <- image_morph(image_read(Plots), frames = 3)
        
        #creating animation
        animation <- image_animate(frames)
        
        # saving animation
        image_write(animation, paste0("Network",substr(dir,14,nchar(dir)),".gif"))
        
        # print status message ( we don´t need this because we´re using the statusbar from pcmclapply)
        # print("Finished Animation for 1 Network")
        
        # going up to the mainDir again
        setwd('..')
}
