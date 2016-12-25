import cv2
import numpy as np
import skimage

img1 = cv2.imread('nonnoisyimage.jpg') #Reading the original image
rows,cols = img1.shape[:2] # calculating the rows and cols of the original image
img2 = (skimage.util.random_noise(img1, mode='s&p', seed=0, clip=True, amount= 0.061)) #adding salt and pepper noise in original image
img7 = (skimage.util.random_noise(img1, mode='Gaussian', seed=0, clip=True, var= 0.03)) #adding gaussian noise in original image
img7 = np.uint8(img7*255) # convering from float to int
img3 = np.uint8(img2*255) # convering from float to int
img4 = cv2.imread('noisyimage.jpg') # reading the captured noisy image
cv2.imwrite('noisy_image_created_saltandpeper.jpg',img3) #saving the salt and pepper noised image
cv2.imwrite('noisy_image_created_Gaussian.jpg',img7)  #saving the gaussian noised image

#Calculating PSNR for noisy captured image
img5 = img1 - img4
MSE_captured_noisy = np.sum(((img5)**2))/(rows*cols)
PSNR_captured_noisy = 10 * np.log10(((255*255)/(MSE_captured_noisy)))
#Calculating PSNR for salt and pepper added noisy image
img6 = img1 - img3
MSE_captured_noisy_saltandpepper = np.sum(((img6)**2))/(rows*cols)
PSNR_captured_noisy_saltandpepper = 10 * np.log10(((255*255)/(MSE_captured_noisy_saltandpepper)))
#Calculating PSNR for Gaussian added noisy image
img8 = img1 - img7
MSE_captured_noisy_Gaussian = np.sum(((img8)**2))/(rows*cols)
PSNR_captured_noisy_Gaussian = 10 * np.log10(((255*255)/(MSE_captured_noisy_Gaussian)))