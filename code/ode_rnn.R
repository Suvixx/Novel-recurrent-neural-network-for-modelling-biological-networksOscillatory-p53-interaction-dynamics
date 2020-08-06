library(keras)
library(tensorflow)

ode_data <- read.csv("/media/data6TB/extracted/ode_rnn/ode-data.csv", header = TRUE, sep = ",")
train_ode <- ode_data[1:800,]
test_ode <- ode_data[801:1001,]

diffed_x <- diff(train_ode[,3], differences = 1)
diffed_x_t <- diff(test_ode[,3], differences = 1)

lag_transform <- function(x, k= 1){
  
  lagged =  c(rep(NA, k), x[1:(length(x)-k)])
  DF = as.data.frame(cbind(lagged, x))
  colnames(DF) <- c( paste0('x-', k), 'x')
  DF[is.na(DF)] <- 0
  return(DF)
}
train_x <- lag_transform(diffed_x, 1)
test_x <- lag_transform(diffed_x_t, 1)


scale_data = function(train, test, feature_range = c(0, 1)) {
  x = train
  fr_min = feature_range[1]
  fr_max = feature_range[2]
  std_train = ((x - min(x) ) / (max(x) - min(x)  ))
  std_test  = ((test - min(x) ) / (max(x) - min(x)  ))
  
  scaled_train = std_train *(fr_max -fr_min) + fr_min
  scaled_test = std_test *(fr_max -fr_min) + fr_min
  
  return( list(scaled_train = as.vector(scaled_train), scaled_test = as.vector(scaled_test) ,scaler= c(min =min(x), max = max(x))) )
  
}


Scaled <- scale_data(train_x, test_x, c(-1, 1))

y_train <- Scaled$scaled_train[, 2]
x_train <- Scaled$scaled_train[, 1]

y_test <- Scaled$scaled_test[, 2]
x_test <- Scaled$scaled_test[, 1]

invert_scaling = function(scaled, scaler, feature_range = c(0, 1)){
  min = scaler[1]
  max = scaler[2]
  t = length(scaled)
  mins = feature_range[1]
  maxs = feature_range[2]
  inverted_dfs = numeric(t)
  
  for( i in 1:t){
    X = (scaled[i]- mins)/(maxs - mins)
    rawValues = X *(max - min) + min
    inverted_dfs[i] <- rawValues
  }
  return(inverted_dfs)
}


dim(x_train) <- c(length(x_train), 1, 1)

X_shape2 = dim(x_train)[2]
X_shape3 = dim(x_train)[3]
batch_size = 1                
units = 1 

model <- keras_model_sequential() 
model%>%
  layer_lstm(units, batch_input_shape = c(batch_size, X_shape2, X_shape3), stateful= TRUE)%>%
  layer_dense(units = 1)

model %>% compile(
  loss = 'mean_squared_error',
  optimizer = optimizer_adam( lr= 0.02, decay = 1e-6 ),  
  metrics = c('accuracy')
)

Epochs = 50   
for(i in 1:Epochs ){
  model %>% fit(x_train, y_train, epochs=1, batch_size=batch_size, verbose=1, shuffle=FALSE)
  model %>% reset_states()
}

L = length(x_test)
scaler = Scaled$scaler
predictions = numeric(L)

for(i in 1:L){
  X = x_test[i]
  dim(X) = c(1,1,1)
  yhat = model %>% predict(X, batch_size=batch_size)
  # invert scaling
  yhat = invert_scaling(yhat, scaler,  c(-1, 1))
  # invert differencing
  yhat  = yhat + test_ode[i,3]
  # store
  predictions[i] <- yhat
}

#plotting
predict <- as.data.frame(unlist(predictions))
colnames(predict) <- c("predict")
p <- test_ode[,2:3]
p <- p[2:nrow(p),]
colnames(p) <- c("time", "test")
plot_df_test <- cbind(p,predict)
library(reshape2)
outm_test <- melt(plot_df_test, id.vars='time')
train_ode <- train_ode[,2:ncol(train_ode)]
outm_train <- melt(train_ode, id.vars='time')
q <- outm_train[1:800,]
plot_df <- rbind(q,outm_test)

library(ggplot2)
ggplot(plot_df, aes(x = time, y = value))+
  geom_line(aes(color = variable ), size = 1.25, linetype = "solid")
