#Funkcje konwertujące plansze do liczb i liczby do plansz



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