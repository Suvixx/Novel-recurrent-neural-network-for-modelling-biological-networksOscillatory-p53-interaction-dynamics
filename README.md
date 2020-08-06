# Novel-recurrent-neural-network-for-modelling-biological-networksOscillatory-p53-interaction-dynamics
The folders are self explanatory. The steps I followed here was:
- Formulate the ODE description of the system
- Generate data and split them in 80-20 % division to train and test the RNN
- Compare the behaviour of the test and predicted data behaviour after training the RNN model for P53( or x) and mdm2( or y)

The RNN architecture I used consists of - (a) 1 input layer, (b) 1 LSTM layer, (c) 1 output layer. The model predicts the oscillatory motion better which is easily verifiable from the plots. 

The explanation of the images are following:
- Rplot.png represents the training, test and predicted data scenario in RNN model for p53
- Rplot01.png represents the same for Mdm2
- predict&test.png represents the same for both p53 and mdm2
