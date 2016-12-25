import numpy as np
import cv2
im3 = cv2.imread('GreenBack.png')
im4 = cv2.imread('BlueBack.png')
im1 = cv2.imread('Greenice.png')
im2 = cv2.imread('Blueice.png')
alpha = 1 - np.divide(np.multiply((im1- im2),(im3- im4)), np.multiply((im3- im4),(im3- im4)));
alpha2 = alpha
alpha2[alpha == 0] = 1
alpha = 1 - np.divide(np.multiply((im1- im2),(im3- im4)), np.multiply((im3- im4),(im3- im4)));
Foreground = im2 - np.divide(np.multiply((1 - alpha),im4),(alpha2))
cv2.imwrite('Foreground.jpg',Foreground) 
mm = alpha;
mm[mm>0] = 255;
cv2.imwrite('Mask.jpg',mm) 