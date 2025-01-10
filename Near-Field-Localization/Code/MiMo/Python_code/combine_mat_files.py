import numpy as np
from scipy.io import loadmat

Y_mat_location = 'Matlab_Data/Y.mat'
r_q_all_location = 'Matlab_Data/r_q_all.mat'
Y = loadmat(Y_mat_location)  
Y = Y['Y']
Y = np.transpose(Y,(2,0,1))

# now the shape is 50000, 16, 20 , I want to make it 50000 x 16, 20
Y = np.reshape(Y,(50000*16,20))
print(f"the shape of Y = {Y.shape}")

r_q_all = loadmat(r_q_all_location)
r_q_all = r_q_all['r_q_all']

r_q_all = np.transpose(r_q_all,(1,0))
r_q_all = np.reshape(r_q_all,50000* 16)
print(f"the shape of r_q_all = {r_q_all.shape}")