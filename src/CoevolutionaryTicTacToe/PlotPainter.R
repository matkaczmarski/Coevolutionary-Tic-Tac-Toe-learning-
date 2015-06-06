#Rysowanie wykresów

drawAllDataPlot <- function(scores){
  wins = scores[,1]
  draws = scores[,2]
  losses = scores[,3]
  
  g_range <- range(0, wins, draws,losses)

  plot(wins, type="o", col="green", ylim=g_range,  axes=FALSE, ann=FALSE)
  
  axis(2, las=1, at=0:g_range[2])
  
  box()
  
  lines(draws, type="o", pch=22, lty=2, col="blue")
  lines(losses, type="o", pch=22, lty=2, col="red")
  
  title(main="Results", col.main="red", font.main=4)
  
  title(xlab="Iterations", col.lab=rgb(0,0.5,0))
  title(ylab="Results count", col.lab=rgb(0,0.5,0))
  
  legend(1, g_range[2], c("wins","draws","losses"), cex=0.8, col=c("green","blue","red"), pch=21:22, lty=1:2);
}

drawOnlyWinsPlot <- function(scores){
   
  wins = scores[,1]
  draws = scores[,2]
  losses = scores[,3]
  g_range <- range(0, wins, draws,losses)
  
  plot(wins, type="o", col="green")
  box()
  title(main="Results for 10 games each iteration", col.main="red", font.main=4)
  title(xlab="Iterations", col.lab=rgb(0,0.5,0))
  title(ylab="Results count", col.lab=rgb(0,0.5,0))
  
  legend(1, g_range[2], c("wins"), cex=0.8, col=c("green"), pch=21:22, lty=1:2);
}