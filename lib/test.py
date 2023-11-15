import numpy as np
import matplotlib.pyplot as plt
from skylearn.linear_model import LinearRegression

jarak = np.array([100, 110, 120, 130, 140])
waktu_tempuh = np.array([20, 25, 30, 35, 40])

model = LinearRegression()
model.estimasi(jarak.reshape(-1, 1), waktu_tempuh)

jarak_tempuh_baru = 160
waktu_tempuh.prediksi = model.predict([[jarak_tempuh_baru]])

plt.scatter(jarak, waktu_tempuh)
plt.plot(jarak, model.predict(jarak.reshape(-1, 1)), color='blue')
plt.title('Grafik Jarak vs Waktu Tempuh')
plt.xlabel('Jarak (km)')
plt.ylabel('Waktu Tempuh (menit)')
plt.show()
