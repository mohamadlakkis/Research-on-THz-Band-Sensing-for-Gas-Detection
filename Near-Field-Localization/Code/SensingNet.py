import tensorflow as tf
from tensorflow.keras import layers, models
import numpy as np 

'''We need to normalize the true velcocity and range values '''
# assuming the recieved signal is L x M_RB x 2
# so once we generate these signals we need to actually do some data manipulation before directly using them in this model

M_RB = 8  # NB of blocks
L = 64    # NB of subcarriers per block
P = 3     # NB of significant paths (output vector size)



'''Model for Range estimation'''
input_range = [tf.keras.Input(shape=(L, 2), name=f'input_range_{i}') for i in range(M_RB)]
dense_layers = [layers.Dense(500, activation='relu'), layers.BatchNormalization(),
                layers.Dense(250, activation='relu'), layers.BatchNormalization(),
                layers.Dense(120, activation='relu'), layers.BatchNormalization(),
                layers.Dense(60, activation='relu'), layers.BatchNormalization()]

# here we are processing each block separately
range_outputs = []
for inp in input_range:
    x = layers.Flatten()(inp)
    for dense_layer in dense_layers:
        x = dense_layer(x)
    x = layers.Dense(P, activation='sigmoid')(x) 
    range_outputs.append(x)
range_average = layers.Average()(range_outputs)

range_model = models.Model(inputs=input_range, outputs=range_average)
range_model.compile(optimizer='adam', loss='mse', metrics=['mae'])
range_model.summary()


'''Model for Velocity estimation'''
input_velocity = [tf.keras.Input(shape=(M_RB, 2), name=f'input_velocity_{i}') for i in range(M_RB)]
dense_layers = [layers.Dense(500, activation='relu'), layers.BatchNormalization(),
                layers.Dense(250, activation='relu'), layers.BatchNormalization(),
                layers.Dense(120, activation='relu'), layers.BatchNormalization(),
                layers.Dense(60, activation='relu'), layers.BatchNormalization()]

# here we are processing each subcarrier separately
velocity_outputs = []
for inp in input_velocity:
    x = layers.Flatten()(inp)
    for dense_layer in dense_layers:
        x = dense_layer(x)
    x = layers.Dense(P, activation='sigmoid')(x) 
    velocity_outputs.append(x)
velocity_average = layers.Average()(velocity_outputs)


velocity_model = models.Model(inputs=input_velocity, outputs=velocity_average)
velocity_model.compile(optimizer='adam', loss='mse', metrics=['mae'])
velocity_model.summary()