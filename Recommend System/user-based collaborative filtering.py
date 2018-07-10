import pandas as pd  
import numpy as np
import scipy.sparse as sp
from scipy.sparse.linalg import svds
from sklearn.metrics import mean_squared_error
import warnings
warnings.filterwarnings('ignore')

# define algorithm
def robust_coef(a, b):
    '''compute pearson correlation, ignore missing values'''
    corr = np.corrcoef(a[(~np.isnan(a)) & (~np.isnan(b))], b[(~np.isnan(a)) & (~np.isnan(b))])[0][1]
    return corr

def coef_matrix(mat):
    '''calculate corrlation matrix'''
    size = mat.shape[0]
    coef_mat = np.zeros((size,size))
    for i in range(size):
        for j in range(size):
            if i == j: 
                break
            # compute the correlation
            coef_temp = robust_coef(mat[i], mat[j])
            # put it at the right position
            coef_mat[i, j] = coef_mat[j, i] = coef_temp
    # impute the missing value
    coef_mat = np.nan_to_num(coef_mat) # if na, means the pair never score same item, so impute with 0
    return coef_mat

def pred_matrix(mat, k_max=20):
    '''prediction, output the predict matrix'''
    # should claim the number of most silimar users, default 20
    # correlation matrix
    coef_mat = coef_matrix(mat)
    # initialize the predict matrix
    score_pred_matrix = mat.copy()
    for i in range(score_pred_matrix.shape[0]): # user i
        # user's mean score, neglect missing value
        user_mean = np.mean(mat[i][~(np.isnan(mat[i]))])
        for j in range(score_pred_matrix.shape[1]): # item j
            # find the similarity, order from highest to lowest
            similar_list = np.argsort(coef_mat[i])[::-1]
            # find k most similar users to user i
            similar_final = []
            k_count = 0
            for k in similar_list:
                # the selected user should score the film j, or check the next one
                if np.isnan(mat[k, j]):
                    continue
                else:
                    k_count = k_count + 1
                    similar_final.append(k)
                # continue until we find the highest k (who score film j)
                if k_count == k_max:
                    break
            # calculate the average score for similar users, and their score for item j
            mean_list = []
            item_list = []
            for row in similar_final:
                # mean score
                row_mean = np.mean(mat[row, :][~np.isnan(mat[row, :])])
                mean_list.append(row_mean)
                # score for item j
                item_list.append(mat[row, j])
            # make prediction
            final_pred = user_mean+np.sum(coef_mat[i][similar_final]*(np.array(item_list)-np.array(mean_list)))\
            /np.sum(np.abs(coef_mat[i])[similar_final])
            # put the result in the same position
            score_pred_matrix[i, j] = final_pred
    return score_pred_matrix

def rmse_matrix(initial, pred):
    '''performance evaluation'''
    # calculate error; if nan, use 0 to impute, becasue nan means we don't know the actual value, so can't evaluate
    diff = np.nan_to_num(initial - pred)
    # sum of squared error
    rss = np.sum(diff**2)
    # RMSE, notice: we need to divide by the number of valid values
    rmse = np.sqrt(rss / np.sum(~np.isnan(initial)))
    return rmse

# get data
df = pd.read_csv('data.csv', header=None)
matrix = np.array(df)
# prediction
predict_matrix = pred_matrix(matrix)
print(pd.DataFrame(predict_matrix))
print('rmse:', str(rmse_matrix(matrix, predict_matrix)))