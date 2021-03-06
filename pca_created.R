# PCA

# Importing the dataset
dataset = read.csv('Wine.csv')


# Splitting the dataset into the Training set and Test set
library(caTools)
set.seed(123)
split = sample.split(dataset$Customer_Segment, SplitRatio = 0.8)
training_set = subset(dataset, split == TRUE)
test_set = subset(dataset, split == FALSE)


# feature scaling
training_set[-14] = scale(training_set[-14]) #want everything except the dep. var
test_set[-14] = scale(test_set[-14])


# Apply PCA
library(caret)
library(e1071)
#thresh is how much veriance you want from var (60%, put thresh = 0.6)
#since we know we only want 2 features (pcaComp = 2), it'll override thresh
pca = preProcess(x = training_set[-14], method = 'pca', pcaComp = 2)
training_set = predict(pca, training_set) #train. w/ the 2 new features
training_set = training_set[c(2,3,1)] #flipping order of values
test_set = predict(pca, test_set)
test_set = test_set[c(2,3,1)]


# Fitting to training set (from SVM section)
#glm = general linear model, formula based on age and salary
library(e1071)
classifier = svm(formula = Customer_Segment~.,
                 data  = training_set,
                 type = 'C-classification',
                 kernel = 'linear')


#Predicting the test set results
y_pred = predict(classifier, newdata = test_set[-3])


# Making the confusion matrix
cm = table(test_set[,3], y_pred)


# Visualising the Training set results
library(ElemStatLearn)
set = training_set
X1 = seq(min(set[, 1]) - 1, max(set[, 1]) + 1, by = 0.01)
X2 = seq(min(set[, 2]) - 1, max(set[, 2]) + 1, by = 0.01)
grid_set = expand.grid(X1, X2)
colnames(grid_set) = c('PC1', 'PC2')
y_grid = predict(classifier, newdata = grid_set)
plot(set[, -3],
     main = 'SVM (Training set)',
     xlab = 'PC1', ylab = 'PC2',
     xlim = range(X1), ylim = range(X2))
contour(X1, X2, matrix(as.numeric(y_grid), length(X1), length(X2)), add = TRUE)
#  ******** look below, 2 ifelse, important!***************
points(grid_set, pch = '.', col = ifelse(y_grid == 2, 'deepskyblue',ifelse(y_grid == 1, 'springgreen3', 'tomato')))
points(set, pch = 21, bg = ifelse(set[, 3] == 2, 'blue3', ifelse(set[, 3] == 1,'green4', 'red3')))


# Visualising the Test set results
library(ElemStatLearn)
set = test_set
X1 = seq(min(set[, 1]) - 1, max(set[, 1]) + 1, by = 0.01)
X2 = seq(min(set[, 2]) - 1, max(set[, 2]) + 1, by = 0.01)
grid_set = expand.grid(X1, X2)
colnames(grid_set) = c('PC1', 'PC2')
y_grid= predict(classifier, newdata = grid_set)
plot(set[, -3],
     main = 'SVM (Test set)',
     xlab = 'PC1', ylab = 'PC2',
     xlim = range(X1), ylim = range(X2))
contour(X1, X2, matrix(as.numeric(y_grid), length(X1), length(X2)), add = TRUE)
points(grid_set, pch = '.', col = ifelse(y_grid == 2, 'deepskyblue',ifelse(y_grid == 1, 'springgreen3', 'tomato')))
points(set, pch = 21, bg = ifelse(set[, 3] == 2, 'blue3', ifelse(set[, 3] == 1,'green4', 'red3')))
