setwd("D:/extended_ara/iiit-D")
x_df <- read.csv("plot-x.csv", header = TRUE,  sep = ",")
y_df <- read.csv("plot-y.csv", header = TRUE,  sep = ",")
library(sqldf)
x_pred <- sqldf("select time,value from x_df where variable = 'predict'")
y_pred <- sqldf("select time,value from y_df where variable = 'predict'")
x_pred$variable <- as.factor(c(rep("P53_predicted", 200)))
y_pred$variable <- as.factor(c(rep("Mdm2_predicted", 200)))
x <- sqldf("select time,value from x_df where variable = 'test'")
y <- sqldf("select time,value from y_df where variable = 'test'")
x$variable <- as.factor(c(rep("P53", 200)))
y$variable <- as.factor(c(rep("Mdm2", 200)))
df_plot <- rbind(x_pred,y_pred,x,y)

library(ggplot2)
ggplot(df_plot, aes(x = time, y = value ))+
  geom_line(aes(color = variable ), size = 0.5, linetype = "solid")+
  scale_color_manual(values = c("orange","green","steelblue","cyan"))+
  theme_classic()