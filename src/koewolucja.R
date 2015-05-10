
blank <- '-'
#lockBinding("b", globalenv())
o <- 'o'
#lockBinding("o", globalenv())
x <- 'x'
#lockBinding("x", globalenv())


n <- readline(prompt="Enter board size: ")
N <- as.integer(n)
N

k <- readline(prompt="Enter win line size: ")
K <- as.integer(k)
K

board <- matrix('-', N, N)
moveCounter <- N*N

isIndexValid <- function(x,y){
  return(x > 0 && y > 0 && x <= N && y <= N)
}


move <- function(x,y,character){
  if(board[x,y] != blank){
    return (FALSE)
  }
  
  board[x,y] <<- character
  moveCounter <<- moveCounter - 1
  
  hStart <- y
  hEnd <- y
  #poziom
  for(i in 1:K){
    if(isIndexValid(x, y - i) && board[x,y-i] == character){
      hStart <- (y-i)
    }
    else{
      break
    }
  }
  for(i in 1:K){
    if(isIndexValid(x, y + i) && board[x,y+i] == character){
      hEnd <- (y+i)
    }
    else{
      break
    }
  }
  if(hEnd - hStart + 1 >= K){
    cat("Znaleziono poziom¹ wygran¹ od ")
    cat("[")
    cat(x)
    cat(", ")
    cat(hStart)
    cat("] do [")
    cat(x)
    cat(", ")
    cat(hEnd)
    cat("]\n")
    return(TRUE)
  }
  
  vStart <- x
  vEnd <- x
  #pion
  for(i in 1:K){
    if(isIndexValid(x-i, y) && board[x-i,y] == character){
      vStart <- (x-i)
    }
    else{
      break
    }
  }
  for(i in 1:K){
    if(isIndexValid(x+i, y) && board[x+i,y] == character){
      vEnd <- (x+i)
    }
    else{
      break
    }
  }
  if(vEnd - vStart + 1 >= K){
    cat("Znaleziono pionow¹ wygran¹ od ")
    cat("[")
    cat(vStart)
    cat(", ")
    cat(y)
    cat("] do [")
    cat(vEnd)
    cat(", ")
    cat(y)
    cat("]\n")
    return(TRUE)
  }
  
  dStart <- 0
  dEnd <- 0
  #diag
  for(i in 1:K){
    if(isIndexValid(x-i, y-i) && board[x-i,y-i] == character){
      dStart <- i
    }
    else{
      break
    }
  }
  for(i in 1:K){
    if(isIndexValid(x+i, y+i) && board[x+i,y+i] == character){
      dEnd <- i
    }
    else{
      break
    }
  }
  if(dEnd + dStart + 1 >= K){
    cat("Znaleziono diagonaln¹ wygran¹ od ")
    cat("[")
    cat(x - dStart)
    cat(", ")
    cat(y - dStart)
    cat("] do [")
    cat(x + dEnd)
    cat(", ")
    cat(y + dEnd)
    cat("]\n")
    return(TRUE)
  }
  
  adStart <- 0
  adEnd <- 0
  #anty diag
  for(i in 1:K){
    if(isIndexValid(x+i, y-i) && board[x+i,y-i] == character){
      adStart <- i
    }
    else{
      break
    }
  }
  for(i in 1:K){
    if(isIndexValid(x-i, y+i) && board[x-i,y+i] == character){
      adEnd <- i
    }
    else{
      break
    }
  }
  if(adEnd + adStart + 1 >= K){
    cat("Znaleziono diagonaln¹ wygran¹ od ")
    cat("[")
    cat(x + adStart)
    cat(", ")
    cat(y - adStart)
    cat("] do [")
    cat(x - adEnd)
    cat(", ")
    cat(y + adEnd)
    cat("]\n")
    return(TRUE)
  }
  
  
}



