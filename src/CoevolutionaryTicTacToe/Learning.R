scoresA <<- matrix(0,0,0)
scoresB <<- matrix(0,0,0)


startLearning <- function(N, K, nrOfIndividuals, learningTime){
  if (nrOfIndividuals %% 4 != 0){
    print("Liczba osobników w populacji musi być podzielna przez 4")
    return(NULL)
  }
  
  m = 2000
  probability1 = 0.05
  probability2 = 0.075
  
  scoresA <<- matrix(0,learningTime,3)
  scoresB <<- matrix(0,learningTime,3)
  
  population_1 = matrix(0, nrOfIndividuals, 3^(N*N))
  population_2 = matrix(0, nrOfIndividuals, 3^(N*N))
  
  for (i in 1:nrOfIndividuals){
    population_1[i,] = generateIndividual(N)
    population_2[i,] = generateIndividual(N)
  }
  
  for (t in 1:(learningTime+1)){
    scores_1 = matrix(0, nrOfIndividuals, 1)
    scores_2 = matrix(0, nrOfIndividuals, 1)
    
    for (k in 1:nrOfIndividuals){
      for (k2 in 1:nrOfIndividuals){
        scores = battle(N, K, population_1[k,], population_2[k2,])
        scores_1[k] = scores_1[k] + scores[1]
        scores_2[k2] = scores_2[k2] + scores[2]
      }
    }
    
    best_1_index = sort(scores_1, decreasing = TRUE, index.return = TRUE)[2]
    best_2_index = sort(scores_2, decreasing = TRUE, index.return = TRUE)[2]
    
    best_1 = matrix(0, nrOfIndividuals, 3^(N*N))
    best_2 = matrix(0, nrOfIndividuals, 3^(N*N))
    
    if (t > learningTime){
      bestIndividuals = matrix(0, 2, 3^(N*N))
      bestIndividuals[1,] = population_1[best_1_index[[1]][1],]
      bestIndividuals[2,] = population_2[best_2_index[[1]][1],]
  
      return(bestIndividuals)
    }
    
    for (i in 1:(floor(nrOfIndividuals / 4))){
      best_1[i * 4 - 3,] = population_1[best_1_index[[1]][i * 2 - 1],]
      best_1[i * 4 - 2,] = population_1[best_1_index[[1]][i * 2],]
      children = crossover(population_1[best_1_index[[1]][i * 2 - 1],], population_1[best_1_index[[1]][i * 2],], m)
      best_1[i * 4 - 1,] = children[1]
      best_1[i * 4,] = children[2]
      
      best_2[i * 4 - 3,] = population_2[best_2_index[[1]][i * 2 - 1],]
      best_2[i * 4 - 2,] = population_2[best_2_index[[1]][i * 2],]
      children = crossover(population_2[best_2_index[[1]][i * 2 - 1],], population_2[best_2_index[[1]][i * 2],], m)
      best_2[i * 4 - 1,] = children[1]
      best_2[i * 4,] = children[2]
    }
    
    for (i in 1:nrOfIndividuals){
      best_1[i,] = mutate(best_1[i,],probability1, probability2,  N)
      best_2[i,] = mutate(best_2[i,],probability1, probability2,  N)
    }
    
    population_1 = best_1
    population_2 = best_2
    
    #spr poprawy
    scoresA[t,] <<- testBattle(N,K,10,population_1[best_1_index[[1]][1],])
    scoresB[t,] <<- testBattle(N,K,10,population_2[best_2_index[[1]][1],])
    
  }
  
  return(NULL)
}

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

#algorytm mutacji
mutate <- function(individual, p1, p2, dim){
  if (p1 >= runif(1)){
    for (i in 1:length(individual)){
      if (p2 >= runif(1)){
        individual[i] = getNextMove(idToBoard(i, dim))
      }
    }
  }
  return(individual)
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

battle <- function(N, K, p1_Strategy, p2_Strategy){
  p1 = 1
  p2 = 2
  scores=c(0,0)
  
    board = matrix(0,N,N)
    moveCounter = N*N
    
    while(moveCounter > 0){
      
      #p1:
      randomMove = p1_Strategy[boardToId(board)]#getNextMove(board)
      board[randomMove] = p1
      ind = getIndecies(randomMove,N)
      
      if(checkResult(board,ind[1],ind[2], p1,K) == TRUE){
        scores[p1] = scores[p1] + 1
        scores[p2] = scores[p2] - 2
        break
      }
      
      moveCounter = moveCounter -1
      if(moveCounter <= 0){
        break
      }
      
      #p2:
      randomMove = p2_Strategy[boardToId(board)]#getNextMove(board)
      board[randomMove] = p2
      ind = getIndecies(randomMove,N)
      if(checkResult(board,ind[1],ind[2],p2,K) == TRUE){
        scores[p1] = scores[p1] - 2
        scores[p2] = scores[p2] + 1
        break
      }
      
      moveCounter = moveCounter -1
    }
    
    board = matrix(0,N,N)
    moveCounter = N*N
    
    while(moveCounter > 0){
      
      #p2:
      randomMove = p2_Strategy[boardToId(board)]#getNextMove(board)
      board[randomMove] = p2
      ind = getIndecies(randomMove,N)
      if(checkResult(board,ind[1],ind[2],p2,K) == TRUE){
        scores[p1] = scores[p1] - 2
        scores[p2] = scores[p2] + 1
        break
      }
      
      moveCounter = moveCounter -1
      if(moveCounter <= 0){
        break
      }
      
      #p1:
      randomMove = p1_Strategy[boardToId(board)]#getNextMove(board)
      board[randomMove] = p1
      ind = getIndecies(randomMove,N)
      
      if(checkResult(board,ind[1],ind[2], p1,K) == TRUE){
        scores[p1] = scores[p1] + 1
        scores[p2] = scores[p2] - 2
        break
      }
      
      moveCounter = moveCounter -1
    }
  
  return(scores)
}

testBattle <- function(N, K, battles, bestStrategy){
  p1 = 1
  p2 = 2
  scores=c(0,0,0)
  win = 1
  draw = 2
  loss = 3
  
  for(b in 1:battles){
    
    board = matrix(0,N,N)
    moveCounter = N*N
    if(b%%2 == 0){
      while(moveCounter > 0){
        randomMove = getNextMove(board)
        board[randomMove] = p1
        ind = getIndecies(randomMove,N)
        if(checkResult(board,ind[1],ind[2], p1,K) == TRUE){
          scores[loss] = scores[loss] + 1
          break
        }
        
        moveCounter = moveCounter -1
        if(moveCounter <= 0){
          scores[draw] = scores[draw] + 1
          break
        }
        
        randomMove = bestStrategy[boardToId(board)]
        board[randomMove] = p2
        ind = getIndecies(randomMove,N)
        if(checkResult(board,ind[1],ind[2],p2,K) == TRUE){
          scores[win] = scores[win] + 1
          break
        }
        
        moveCounter = moveCounter -1
        if(moveCounter <= 0){
          scores[draw] = scores[draw] + 1
          break
        }
      }
    }
    else{
      while(moveCounter > 0){
        randomMove = bestStrategy[boardToId(board)]
        board[randomMove] = p2
        ind = getIndecies(randomMove,N)
        if(checkResult(board,ind[1],ind[2],p2,K) == TRUE){
          scores[win] = scores[win] + 1
          break
        }
        
        moveCounter = moveCounter -1
        if(moveCounter <= 0){
          scores[draw] = scores[draw] + 1
          break
        }
        
        randomMove = getNextMove(board)
        board[randomMove] = p1
        ind = getIndecies(randomMove,N)
        if(checkResult(board,ind[1],ind[2], p1,K) == TRUE){
          scores[loss] = scores[loss] + 1
          break
        }
        
        moveCounter = moveCounter -1
        if(moveCounter <= 0){
          scores[draw] = scores[draw] + 1
          break
        }
      }
    }  
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
  return(id + 1)
}

idToBoard <- function(id, dim){
  board = matrix(0,dim,dim)
  id = id - 1
  
  for(i in 1:nrow(board)){
    for(j in 1:ncol(board)){
      board[i,j] = (id %% 3 )
      id = floor(id/3)
    }
  }
  return(board)
}

getNextMove <- function(board){ #(board){
  possibleMoves = which(board == 0, arr.ind = F)
  if (length(possibleMoves) == 0)
    return(0)
  return(sample(which(board == 0, arr.ind = F),1))
}

generateIndividual <- function(N){
  dim = 3^(N*N)
  moves = matrix(0, 1, dim);
  
  for (i in 1:ncol(moves)){
    board = idToBoard(i, N)
    moves[1, i] = getNextMove(board)
  }
  
  return(moves)
}