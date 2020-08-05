library(deSolve)

time <- seq(from=0, to=1000, by = 1)
parameters <- c(gma = 2, alxy = 3.7, bitx = 1.5 , alzero = 1.1 , ay = 0.9)
state <- c(x = 1, y0 = 0, y1 = 0.54)

odernn <- function(t, state, parameters){
  with(as.list(c(state, parameters)), {
    dx = gma * x - alxy * x * y1
    dy0 = bitx * x  - alzero * y0
    dy1 = alzero * y0 - ay * y1
    return(list(c(dx, dy0, dy1)))
  })
}

out <- ode(y = state, times = time, func = odernn, parms = parameters)
outdf <- as.data.frame(out)

library(reshape2)
outm <- melt(outdf, id.vars='time')

library(ggplot2)
p <- ggplot(outm, aes(time, value, color = variable)) + geom_point()+geom_line()
print(p)

write.csv(outdf, "D:/extended_ara/iiit-D/ode-data.csv", sep = ",")