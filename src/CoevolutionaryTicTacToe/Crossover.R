# Algorytm krzyzowania
crossover <- function(a,b,m){
  if(length(a) != length(b) || m < 1){
    return(FALSE)
  }
  divisions = c(1,sort(sample(2:(length(a)-1),m,replace=F)), length(a))
  children = matrix(0, 2, length(a));
  
  for(i in 1:(length(divisions)-1)){
    if(i%%2 == 0){
      children[1,divisions[i]:divisions[i+1]] = a[divisions[i]:divisions[i+1]]
      children[2,divisions[i]:divisions[i+1]] = b[divisions[i]:divisions[i+1]]
    }
    else{
      children[1,divisions[i]:divisions[i+1]] = b[divisions[i]:divisions[i+1]]
      children[2,divisions[i]:divisions[i+1]] = a[divisions[i]:divisions[i+1]]
    }
  }
  return(children)
}

#aa=cat(1,2,3,4,5,6,7,8,9,10);
#bb=cat(10,9,8,7,6,5,4,3,2,1);
#mm = 2;
#crossover(aa,bb,mm)

