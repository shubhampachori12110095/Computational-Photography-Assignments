import cv2
import numpy as np
img = cv2.imread('image.jpg',0) #Reading the original image as gray scale. THough the same process could be done for R,G,B channel also
img1 = np.double(img) #Convering uint8 into double form
rows,cols = img.shape[:2] # Extracting the rows and cols of the image
u, d, v = np.linalg.svd(img1, full_matrices=True) # Finding the svd of the image
compressed_image = np.zeros([rows,cols]) #This will be our compressed image
v = np.transpose(v) 
d_square = np.square(d);
threshold = 0.9999995 # Percentage of eigenvalues which capture the information present in the image
trace_d = np.sum(d_square) #Sum of the square of eigenvalues
sum_trace = 0
k = 1
# From the following loop we will get the value of k that will capture the threshold*100% of the information in the image.

for i in range(len(d_square)):
     if ( sum_trace < (trace_d)*threshold):
         sum_trace = sum_trace + d_square[i]
         k = k+1
     else :
         break

#Otherwise put the desired value of k yourself.
#k = 200

for i in range(k):
    compressed_image = compressed_image+ d[i]* ((np.matrix(u[:,i]).T)*np.matrix(np.reshape(v[:,i],(1,len(v[:,i])))))


compressed_image = np.uint8(compressed_image) # This will be our compressed image
#Compresiion ratio obtained 
compression_ratio = np.double((k*(cols+rows+1)))/(np.double(cols)*np.double(rows))   # This is the compression ratio that we have obtained

cv2.imwrite('compressedimage.jpg',compressed_image) #Writing the compressed image as compressed_image

# Validating the result

mse = (np.double(compressed_image) - np.double(img))
mse = np.sum(np.square(mse))/(rows*cols)

psnr=10*np.log10(((256*256)/(mse))) #This is the peak signal to noise ration obtained.
