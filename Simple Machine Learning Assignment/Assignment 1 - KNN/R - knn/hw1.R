# import packages
library(readr)
library(ggplot2)
library(class)
library(dplyr)
library(gmodels)

# import data and manipulation
data <- read_csv("E:/oskird/course/Machine Learning/assignment/hw1/R/winequality-white.csv")
random <- sample(nrow(data))   # shuffle
data$good_wine <- ifelse(data$quality >= 6, 1, 0)   # create column good_wine
# split data
X <- data[,c(1:11)]; y <- data[,13]
X_train <- X[random[1:1959],]
X_valid <- X[random[1960:3429],]
X_test <- X[random[3430:4898],]
y_train <- y[random[1:1959],]$good_wine
y_valid <-  y[random[1960:3429],]$good_wine
y_test <- y[random[3430:4898],]$good_wine

# normalization
norm_by_train <- function(dataset, trainset){
  for (i in 1:length(dataset)) {
    mean <- mean(trainset[[i]])
    sd <- sd(trainset[[i]])
    dataset[i] <- (dataset[i] - mean) / sd
  }
  return(dataset)
}

X_train_norm <- data.frame(scale(X[random[1:1959],]))
X_valid_norm <- norm_by_train(X_valid, X_train)
X_test_norm <- norm_by_train(X_test, X_train)


# k selection
k_num <- c(1:80)
accuracy <- c()
for (k in 1:80) {
  model <- knn(train = X_train_norm, test = X_valid_norm, cl = y_train, k = k)
  acc <- sum(model == y_valid) / nrow(X_valid_norm)
  accuracy <- c(accuracy, acc)
}
accuracy_set <- data.frame(k_number = k_num, accuracy = accuracy)
best_k <- filter(accuracy_set, accuracy == max(accuracy_set$accuracy))$k_number
ggplot(accuracy_set, aes(k_number, accuracy)) + geom_point()

# predict test
model_test <- knn(train = X_train_norm, test = X_test_norm, cl = y_train, k = best_k[1])
acc_test <- sum(model_test == y_test) / nrow(X_test_norm)
CrossTable(model_test , y_test )