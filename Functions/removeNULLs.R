# create function to remove null elements from sublists (for cleaning up OutputNetworkList structure)

removeNULLs <- function(x){
  
  # Getting indices of null elements
  GetIndices <- function(y){return(length(y) == 0)}
  
  # if sublist contains null elements, remove them, if it doesnt, do nothing
  
  if(sum(sapply(x,GetIndices)) > 0){
    
    # overwriting the sublist
    x <- x[-c(which(sapply(x, GetIndices)))]
    
  } else{}
  
  #returning updated element
  return(x)
}