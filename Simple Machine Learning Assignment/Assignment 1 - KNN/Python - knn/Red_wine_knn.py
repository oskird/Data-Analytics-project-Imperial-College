# import module
import pandas as pd
from sklearn.neighbors import KNeighborsClassifier
from sklearn.preprocessing import StandardScaler 
from sklearn.model_selection import train_test_split 
from sklearn.metrics import confusion_matrix, classification_report 
from sklearn.pipeline import Pipeline
from sklearn.utils import shuffle

# Data Manipulation
data = pd.read_csv("winequality-red.csv")   # import data
good_wine = []
for i in range(len(data)):
    if data.quality[i] >= 6:
        qual = 1    # good wine
    else:
        qual = 0    # bad wine
    good_wine.append(qual)
data["good_wine"] = good_wine                # create column: good_wine
X = data.iloc[:,0:11].values                 # full data
y = data.iloc[:,-1].values                   # full label
X,y = shuffle(X,y)                           # shuffle the dataset

# split train and test set
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.5, random_state=42)

# create ML pipeline
steps = [('Z-score scaling', StandardScaler()), ('knn', KNeighborsClassifier())]
pipeline=Pipeline(steps)

# parameter selection for k
from sklearn.model_selection import GridSearchCV
param_grid = {'knn__n_neighbors': list(range(1,500,5))+[500]}   # potential k: 1 to 500
cv = GridSearchCV(pipeline, param_grid, cv=5)   # search the best k, using cross validation
cv.fit(X_train, y_train)
k_best = cv.best_params_      # best k for model
y_pred = cv.predict(X_test) 
cv.score(X_test, y_test)      # accuracy: 0.73250000000000004
confusion_matrix(y_test, y_pred)    # confusion matrix
classification_report(y_test, y_pred)

# seperate
scale = StandardScaler()
scale.fit(X_train, y_train)
X_train_norm = scale.transform(X_train)
# scale2 = StandardScaler().fit(X_test, y_test)
X_test_norm = scale.transform(X_test)
knn = KNeighborsClassifier(n_neighbors = 56)
knn.fit(X_train_norm, y_train)
pred = knn.predict(X_test_norm)
knn.score(X_test_norm, y_test)   # accuracy: 0.72499999999999998
classification_report(pred, y_test)