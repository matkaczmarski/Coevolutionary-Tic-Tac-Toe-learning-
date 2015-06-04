startLearning <- function(N, K, nrOfIndividuals, learningTime){
  population_1 = matrix(0, nrOfIndividuals, 3^(N*N))
  population_2 = matrix(0, nrOfIndividuals, 3^(N*N))
  
  for (i in 1:nrOfIndividuals){
    population_1[i,] = generateIndividual(N)
    population_2[i,] = generateIndividual(N)
  }
  
  for (i in 1:learningTime){
    scores_1 = matrix(0, nrOfIndividuals, 1)
    scores_2 = matrix(0, nrOfIndividuals, 1)
    
    for (k in 1:nrOfIndividuals){
      for (k2 in 1:nrOfIndividuals){
        scores = battle(N, K, population_1[k,], population_2[k2,])
        scores_1[k] = scores_1[k] + scores[1]
        scores_2[k2] = scores_2[k2] + scores[2]
      }
    }
  }
  
  return(individual)
}

checkResult <- function(board, x, y, character, K){
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
    return(TRUE)
  }
  
  return(FALSE)
}


battle <- function(N,K,p1_Strategy, p2_Strategy){
  p1 = 1
  p2 = 2
  scores=c(0,0)
  
    board = matrix(0,N,N)
    moveCounter = N*N
    
    while(moveCounter > 0){
      
      #p1:
      randomMove = p1_Strategy[boardToId(board)] #getNextMove(board)
      board[randomMove] = 1
      r = randomMove%%N
      c = floor(randomMove/N)
      if(checkResult(board,r,c, 1,K) == TRUE){
        #print("wygrał p1")
        scores[p1] = scores[p1] + 1
        scores[p2] = scores[p2] - 2
        break
      }
      
      #p2:
      randomMove = p2_Strategy[boardToId(board)] #getNextMove(board)
      board[randomMove] = 2
      r = randomMove%%N
      c = floor(randomMove/N)
      
      if(checkResult(board,r,c,2,K) == TRUE){
        #print("wygral p2")
        scores[p1] = scores[p1] - 2
        scores[p2] = scores[p2] + 1
        break
      }    
      moveCounter = moveCounter -2
    }
    
    while(moveCounter > 0){
      
      #p2:
      randomMove = p2_Strategy[boardToId(board)] #getNextMove(board)
      board[randomMove] = 2
      r = randomMove%%N
      c = floor(randomMove/N)
      
      if(checkResult(board,r,c,2,K) == TRUE){
        #print("wygral p2")
        scores[p1] = scores[p1] - 2
        scores[p2] = scores[p2] + 1
        break
      }    
      
      #p1:
      randomMove = p1_Strategy[boardToId(board)] #getNextMove(board)
      board[randomMove] = 1
      r = randomMove%%N
      c = floor(randomMove/N)
      if(checkResult(board,r,c, 1,K) == TRUE){
        #print("wygrał p1")
        scores[p1] = scores[p1] + 1
        scores[p2] = scores[p2] - 2
        break
      }
      moveCounter = moveCounter -2
    }
  
  return(scores)
}

boardToId <- function(board){
  id = 0
  exponent = 0;
  for(i in 1:nrow(board)){
    for(j in 1:ncol(board)){
      id = (id + board[i,j]*(3^exponent))
      exponent = exponent + 1
    }
  }
  return(id)
}

idToBoard <- function(id, dim){
  board = matrix(0,dim,dim)
  
  for(i in 1:nrow(board)){
    for(j in 1:ncol(board)){
      board[i,j] = (id %% 3 )
      id = floor(id/3)
    }
  }
  return(board)
}

getNextMove <- function(){ #(board){
  possibleMoves = which(board == 0, arr.ind = F)
  if (length(possibleMoves) == 0)
    return(0)
  return(sample(which(board == 0, arr.ind = F),1))
}

generateIndividual <- function(N){
  dim = 3^(N*N)
  moves = matrix(0, 1, dim);
  
  for (i in 1:ncol(moves)){
    board <- idToBoard(i, N)
    moves[1, i] = getNextMove()
  }
  
  return(moves)
}