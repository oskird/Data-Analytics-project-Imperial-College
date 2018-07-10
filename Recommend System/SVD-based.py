import pandas as pd  
import numpy as np
import scipy.sparse as sp
from scipy.sparse.linalg import svds
from sklearn.metrics import mean_squared_error

def svd_cf(train_matrix, k=2, penalty=0, call=10, max_iter=1000, step=0.01, tolerate=0.0001, early_stopping=True):
    '''
    prediction, output factor p and q
    train_maxtrix: the sparse matrix
    k: # of latent factors
    penalty: l2 penalty to control overfitting, default: 0 (no penalty)
    call: show the SSE and Gradient every n round, default: 10
    max_iter: max iteration of gradient descent, default: 1000
    step: step size of gradient descent, default: 0.01
    tolerate: stop when SSE reduction is less than tolerate%, default: 0.01%
    early_stopping: whether to stop if SSE can't reduce, default: True
    '''
    # matrix factorization
    mean = train_matrix.mean(axis=1)
    train_matrix = train_matrix - mean
    p, s, q = svds(train_matrix, k = k)
    s_diag_matrix = np.diag(s)
    penalty = penalty
    l = step
    count = 0
    sse_old = float('inf')
    print('------------start iteration------------')
    while True:
        gradient_sum = 0
        count = count + 1
        x_pred = np.dot(np.dot(p, s_diag_matrix), q) + mean.values
        error = (train_matrix + mean - x_pred).fillna(0)
        sse = np.sum(error**2).sum()
        if sse*(1+tolerate) > sse_old:
            if early_stopping==True:
                print('------------could decrease anymore, Finish at round '+str(count)+'!------------')
                print('Sum of squared error is: '+str(sse_old))
                break
        sse_old = sse
        p = p + l*(np.dot(error, q.T)-penalty*p)
        q = q + l*(np.dot(p.T, error)-penalty*q)
        gradient_sum = gradient_sum + np.sum((np.dot(error, q.T))**2) + np.sum((np.dot(p.T, error))**2)
        if count%call == 0:
            print('SSE:', str(sse_old), 'Gradient:',gradient_sum)
        if count == max_iter: 
            print('------------max iteration, Finish at round '+str(count)+'!------------')
            print('Sum of squared error is: '+str(sse_old))
            break
    return p, s_diag_matrix, q
	
def mf_predict(p, s, q):
    pred_matrix = np.dot(np.dot(p, s), q)+df.fillna(0).mean(axis=1).values
    final_SSE=((pred_matrix-df)**2).fillna(0).sum().sum()
    count = (~np.isnan(df)).sum().sum()
    rmse_mf = np.sqrt(final_SSE/count)
    return rmse_mf

df = pd.read_csv('data.csv', header=None)
matrix = np.array(df)
p_final, S, q_final = svd_cf(df.fillna(0), k=10, call=1, max_iter=100,step=0.000001)
print(np.dot(np.dot(p_final, S), q_final))
print('rmse:', str(mf_predict(p_final, S, q_final)))