#Battle


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


battle <- function(N,K,battles){
  p1 = 1
  p2 = 2
  scores=c(0,0)
  
  for(i in 1:battles){
    
    board = matrix(0,N,N)
    moveCounter = N*N
    
    while(moveCounter > 0){
      
      #p1:
      randomMove = getNextMove(board)
      board[randomMove] = 1
      r = randomMove%%N
      c = floor(randomMove/N)
      if(checkResult(board,r,c, 1,K) == TRUE){
        print("wygrał p1")
        scores[p1] = scores[p1] + 1
        scores[p2] = scores[p2] - 2
        break
      }
      
      #p2:
      randomMove = getNextMove(board)
      board[randomMove] = 2
      r = randomMove%%N
      c = floor(randomMove/N)
      
      if(checkResult(board,r,c,2,K) == TRUE){
        print("wygral p2")
        scores[p1] = scores[p1] - 2
        scores[p2] = scores[p2] + 1
        break
      }    
      moveCounter = moveCounter -2
      if(moveCounter == 0){
        print("DRAW")
      }
    }
  }
  
  return(scores)
}