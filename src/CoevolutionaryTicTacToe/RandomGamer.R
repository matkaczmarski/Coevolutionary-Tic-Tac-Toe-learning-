#Random gamer

blank <- 0
#lockBinding("b", globalenv())
o <- 1
#lockBinding("o", globalenv())
x <- 2
#lockBinding("x", globalenv())


n <- readline(prompt="Enter board size: ")
N <- as.integer(n)
N

k <- readline(prompt="Enter winning line size: ")
K <- as.integer(k)
K

board <- matrix(0, N, N)
moveCounter <- N*N

isIndexValid <- function(x,y){
  return(x > 0 && y > 0 && x <= N && y <= N)
}

checkResult <- function(x,y,character){
  hStart <- y
  hEnd <- y
  #horizontal
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
    cat("Horizontal winning line from ")
    cat("[")
    cat(x)
    cat(", ")
    cat(hStart)
    cat("] to [")
    cat(x)
    cat(", ")
    cat(hEnd)
    cat("]\n")
    return(TRUE)
  }
  
  vStart <- x
  vEnd <- x
  #vertical
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
    cat("Vertical winning line from ")
    cat("[")
    cat(vStart)
    cat(", ")
    cat(y)
    cat("] to [")
    cat(vEnd)
    cat(", ")
    cat(y)
    cat("]\n")
    return(TRUE)
  }
  
  dStart <- 0
  dEnd <- 0
  #diagonal
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
    cat("Diagonal winning line from ")
    cat("[")
    cat(x - dStart)
    cat(", ")
    cat(y - dStart)
    cat("] to [")
    cat(x + dEnd)
    cat(", ")
    cat(y + dEnd)
    cat("]\n")
    return(TRUE)
  }
  
  adStart <- 0
  adEnd <- 0
  #anti-diagonal
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
    cat("Anti-diagonal winning line from ")
    cat("[")
    cat(x + adStart)
    cat(", ")
    cat(y - adStart)
    cat("] to [")
    cat(x - adEnd)
    cat(", ")
    cat(y + adEnd)
    cat("]\n")
    return(TRUE)
  }
  
  if(moveCounter == 0){
    cat("DRAW!\n")
    return(TRUE)
  }
  return(FALSE)
}


getNextMove <- function(){ #(board){
  return(sample(which(board == 0, arr.ind = F),1))
}

move <- function(x,y,character){
  if(board[x,y] != blank){
    return (FALSE)
  }
  
  board[x,y] <<- character
  moveCounter <<- moveCounter - 1
  if(checkResult(x,y,character) == TRUE){
    return(TRUE)
  }
  randomMove = getNextMove()
  board[randomMove] <<- (character + 1)
  r = randomMove%%N
  c = floor(randomMove/N)
  if(checkResult(r,c,character + 1) == TRUE){
    return(TRUE)
  }
  board
}