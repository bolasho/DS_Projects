# Importing the libraries
import numpy as np
import pandas as pd
import pickle
import os
from flask import Flask, abort, jsonify, request, render_template
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()

# Preparing the Classifier
cur_dir = os.path.dirname(__file__)
model = pickle.load(open(os.path.join(cur_dir,
			'model.pkl'), 'rb'))
#code which helps initialize our server
app =Flask(__name__)

@app.route("/")
def index():
    return render_template("index.html")

@app.route('/success', methods=['POST'])
def success():
    Age = int(request.form['age'])
    Income = int(request.form['income'])
    input_data = [{'Age': Age, 'Income': Income}]
    data = pd.DataFrame(input_data)
    dat= data.iloc[:, [0, 1]].values
    X_train = sc.fit_transform([[36,36000]])
    dat_sc=sc.transform(dat)
    logreg = model.predict(dat_sc)
    return render_template('success.html', res=['0--No_subscription' if  logreg==0 else '1--subscribe'])
if __name__ == '__main__':
    app.run(port=8080, debug=True)
