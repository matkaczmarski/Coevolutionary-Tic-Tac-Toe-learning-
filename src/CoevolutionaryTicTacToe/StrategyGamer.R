#Rozgrywka

blank <- 0
#lockBinding("b", globalenv())
o <- 1
#lockBinding("o", globalenv())
x <- 2
#lockBinding("x", globalenv())

N <- 0
K <- 0

board <- matrix(0, N, N)
moveCounter <- N*N

getNextMove <- function(board){
  return(sample(which(board == 0, arr.ind = F),1))
}

isIndexValid <- function(board,x,y){
  return(x > 0 && y > 0 && x <= nrow(board) && y <= ncol(board))
}

checkResult <- function(board, x,y,character, K){
  hStart <- y
  hEnd <- y
  #horizontal
  for(i in 1:K){
    if(isIndexValid(board,x, y - i) && board[x,y-i] == character){
      hStart <- (y-i)
    }
    else{
      break
    }
  }
  for(i in 1:K){
    if(isIndexValid(board,x, y + i) && board[x,y+i] == character){
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
    if(isIndexValid(board,x-i, y) && board[x-i,y] == character){
      vStart <- (x-i)
    }
    else{
      break
    }
  }
  for(i in 1:K){
    if(isIndexValid(board,x+i, y) && board[x+i,y] == character){
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
    if(isIndexValid(board,x-i, y-i) && board[x-i,y-i] == character){
      dStart <- i
    }
    else{
      break
    }
  }
  for(i in 1:K){
    if(isIndexValid(board,x+i, y+i) && board[x+i,y+i] == character){
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
    if(isIndexValid(board,x+i, y-i) && board[x+i,y-i] == character){
      adStart <- i
    }
    else{
      break
    }
  }
  for(i in 1:K){
    if(isIndexValid(board,x-i, y+i) && board[x-i,y+i] == character){
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
  
  return(FALSE)
}

getIndecies <- function(fieldId, N){
  row=0
  col=0
  row = fieldId %% N 
  if(row==0){
    row = N
    col = fieldId/N
  }
  else{
    col = ceiling(fieldId/N)
  }
  return(c(row,col))
}

strategy = 0
playerSymbol <- 1
computerSymbol <- 2

startGame <- function(str){
  strategy <<- str
  
  n <<- readline(prompt="Enter board size: ")
  N <<- as.integer(n)
  if(length(str) != 3^(N*N)){
    print("Error. Given strategy is compatible with this board size")
    return(FALSE)
  }
  
  k <<- readline(prompt="Enter winning line size: ")
  K <<- as.integer(k)
  
  board <<- matrix(0, N, N)
  moveCounter <<- N*N
  
  whoFirst <- readline(prompt="Choose your symbol '1' or '2' (player with '1' always plays first): ")
  if(whoFirst == '2'){
    print("COMPUTER starts. Your symbol is '2'.")
    playerSymbol <<- 2
    computerSymbol <<- 1
    randomMove = strategy[boardToId(board)]
    board[randomMove] <<- computerSymbol
    print(board)
  }
  else{
    print("You start. Your symbol is '1'.")
    playerSymbol <<- 1
    computerSymbol <<- 2
    print(board)
  }
  
}

move <- function(x,y){
  if(board[x,y] != blank){
    return (FALSE)
  }
  
  board[x,y] <<- playerSymbol
  moveCounter <<- moveCounter - 1
  if(checkResult(board,x,y,playerSymbol,K) == TRUE){
    print("You won!")
    print(board)
    return(TRUE)
  }
  
  if(moveCounter <= 0){
    print("REMIS")
    return(TRUE)
  }
  
  randomMove = strategy[boardToId(board)]
  board[randomMove] <<- computerSymbol
  ind = getIndecies(randomMove,N)
  
  if(checkResult(board,ind[1],ind[2], computerSymbol,K) == TRUE){
    print("You lost!")
    print(board)
    return(TRUE)
  }
  
  moveCounter <<- moveCounter -1
  if(moveCounter <= 0){
    print("Draw!")
    print(board)
    return(TRUE)
  }
  print(board)
}