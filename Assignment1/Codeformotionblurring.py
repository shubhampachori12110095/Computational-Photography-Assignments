import cv2
from skimage.filters import sobel, prewitt

img1 = cv2.imread('Static_Image.jpg') #Reading the original image
rows,cols = img1.shape[:2]  # calculating the rows and cols of the original image
img2 = cv2.blur(img1,(251,251),90) #Adding the Average Blur large enough to create the motion blur effect
img3 = cv2.imread('Motion_blurred_image.jpg') #Reading the captured blur image
cv2.imwrite('Motion_blur_image_created.jpg',img2) #Writing the created blurred image 
img4 = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY) #Converting from RGB to Grey the Average Blurred image
img5 = cv2.cvtColor(img3, cv2.COLOR_BGR2GRAY) #Converting from RGB to Grey the Captured Motion Blurred image
edge_sobel_Blur_image = sobel(img4) #Applying the sobel operator on the Average blurred image
edge_prewitt_Blur_image = prewitt(img4) #Applying the prewitt operator on the Average blurred image
edge_sobel_Blur_image_captured = sobel(img5) #Applying the sobel operator on the captured Motion blurred image
edge_prewitt_Blur_image_captured = prewitt(img5) #Applying the prewitt operator on the captured Motion blurred image
edge_sobel_Blur_image = cv2.blur(edge_sobel_Blur_image,(5,5)) #Averaging the gradients of average  blurred image for sobel operator
edge_prewitt_Blur_image = cv2.blur(edge_prewitt_Blur_image,(5,5)) #Averaging the gradients of average blurred image for prewitt operator
edge_sobel_Blur_image_captured = cv2.blur(edge_sobel_Blur_image_captured,(5,5)) #Averaging the gradients of captured motion blurred image for sobel operator
edge_prewitt_Blur_image_captured = cv2.blur(edge_prewitt_Blur_image_captured,(5,5)) #Averaging the gradients of captured motion blurred image for prewitt operator
diff_sobel = edge_sobel_Blur_image - edge_sobel_Blur_image_captured # Calculating the difference between the gradients for sobel operator
diff_prewitt = edge_prewitt_Blur_image - edge_prewitt_Blur_image_captured # Calculating the difference between the gradients for prewitt operator
MSE_created_diff_sobel = np.sum(((diff_sobel)**2))/(rows*cols) # Calcuating the MSE of the difference for sobel operator 
MSE_created_diff_prewitt = np.sum(((diff_prewitt)**2))/(rows*cols) # Calcuating the MSE of the difference for prewitt operator
