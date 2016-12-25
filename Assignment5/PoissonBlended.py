import cv2
import numpy as np

def imgrad(im):
    gradfilterh = (np.array([[ 0.0, 0, 0],[ 0, -1, 1],[ 0, 0, 0]])) # Horizontal Gradient filter
    gradfilterv = (np.array([[0.0,0, 0], [0,-1,0], [0,1,0]])) # Vertical Gradient filter
    FinalImageh = cv2.filter2D(im,-1,gradfilterh) 
    rows, cols = FinalImageh.shape[:2] # Horizontal filtered image
    FinalImageh[:,(cols-1),:] = 0 
    FinalImagev = cv2.filter2D(im,-1,gradfilterv) # Vertical filtered image
    rows, cols = FinalImagev.shape[:2] 
    FinalImagev[(rows-1),:,:] = 0
    return FinalImageh, FinalImagev


def grad2flip(FinalImageh,FinalImagev):
    lap = np.roll(FinalImageh, 1, axis=1) + np.roll(FinalImagev, 1, axis=0) - FinalImageh - FinalImagev
    return lap


#$$
#Loading the two images
im1 = np.double(cv2.imread('orange1.jpg'))
im2 = np.double(cv2.imread('apple1.jpg'))
rows, cols = im1.shape[:2]

# Taking the horizontal and vertical derivatives of the two images
Image2h, Image2v = imgrad(im2); # horizontal and vertical derivatives of the image2
Image1h, Image1v = imgrad(im1); # horizontal and vertical derivatives of the image1

#%%

# Defining the mask. You could define your own mask here.
msk = (np.zeros((rows,cols,3)))
msk[:,210:(cols),:] = 1 # Create your own mask here.
cv2.imwrite('Mask.jpg',np.uint8(255*msk)) 

# Creating the unblended image.
X = np.multiply(im2,np.float64(np.logical_not(msk)))  + np.multiply(im1,msk) # This is the image without blending.  
FinalImageh = np.multiply(Image2h,np.float64(np.logical_not(msk)))  + np.multiply(Image1h,msk) # The horizontal gradients of the unblended image. This will be useful later
FinalImagev = np.multiply(Image2v,np.float64(np.logical_not(msk)))  + np.multiply(Image1v,msk) # The vertical gradients of the unblended image. This will be useful later
rows, cols = X.shape[:2]
rows, cols = X.shape[:2]
cv2.imwrite('WithoutPoissonBlending.jpg',np.uint8(X))  # Unblended image
#%%
# Using the Jacobi Iteration to solve the equation. Other numerical methods too could be used like Gauss Seidel 
# or Successive Over Relaxation Method.
itr = 2000 # No. of iterations for Jacobi algorithm

K = np.array([[ 0, 1, 0], [1, 0, 1], [0,1,0]]) # This takes the 4 neighbourhood of the pixel, which is then used to smoothly blend
# the boundary.

p = ( msk.T > 0 ) # Those values where mask is greater than zero.
lap = grad2flip(FinalImageh,FinalImagev)

#df0 = np.double(10**32)
dst0 = X # THis is the unblended image. 
output = X # This is the final output (our desired image)

# Jacobi Algorithm for finding the value of output image starts from here.
for i in range(itr):
   lpf = cv2.filter2D(output,-1,K)  
   KK = output.T
   KK[p] = (lap.T[p] + lpf.T[p])/4
   output = KK.T
   dif = np.abs(output-dst0)
   dst0 = output
    
cv2.imwrite('PoissonBlended.jpg',output) 
