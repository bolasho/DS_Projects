import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import pickle
from flask import Flask, abort, jsonify, request, render_template

# Importing the dataset
dataset = pd.read_csv('Social_Network_Ads.csv')
X = dataset.iloc[:, [2, 3]].values
y = dataset.iloc[:, 4].values

# Splitting the dataset into the Training set and Test set
from sklearn.cross_validation import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.25, random_state = 0)
features=list(X_test)
# Feature Scaling
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
X_train = sc.fit_transform(X_train)
X_test = sc.transform(X_test)
# Fitting Logistic Regression to the Training set
from sklearn.linear_model import LogisticRegression
classifier = LogisticRegression(random_state = 0)
classifier.fit(X_train, y_train)
y_pred = classifier.predict(X_test)
# Making the Confusion Matrix
from sklearn.metrics import confusion_matrix
cm = confusion_matrix(y_test, y_pred)
print("Confusion Matrix" + "-"*110)
print(cm)
print("-"*125)

from sklearn.metrics import classification_report
target_names = ['class 0', 'class 1']
print("Classification Reports" + "-"*100)
print(classification_report(y_test, y_pred, target_names=target_names))
print("-"*120)
#print(classifier.predict(X_test))
pickle.dump(classifier, open("model.pkl","wb"))
#loading a model from a file called model.pkl
model = pickle.load(open("model.pkl","rb"))
