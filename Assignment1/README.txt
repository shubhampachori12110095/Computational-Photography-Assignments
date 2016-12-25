# Codeforblurring.py contains the code for creating the blur images simialr to the defocussed image of the planar scene. Images corresponding to it are:
1) Blur_image: Captured blur image from the camera
2) Blur_image_created: Blur image created form the nonblur image using code
3) NonBlurIMage: Image without any blur, captured using camera
I have calculated the average gradient using prewitt and sobel filter. And Calculated the MSE between the Blur_image_created and Blur_image using them.
# Codeforcreatingnoise.py contains the code for adding the noise in the images. I have used salt and pepper noise and gaussian noise to add inot my image. The images corresponding to this question are :
1) nonnoisyimage : Original non noisy image captured using the camera
2) noisyimage: Original noisy image captured using the camera
3) noisy_image_created_Gaussian : Noisy image created by adding the gaussian noise using code
4) noisy_image_created_saltandpepper : Noisy image created by the salt and pepper noise using code
I have calculated PSNR for the noisy image and noisy_image_created_Gaussian and noisy_image_created_saltandpepper
 #Codeformotionblurring.py contains the creating the blur image which looks like captured from a dynamic scene. Images associated with it are:
1) Static_image: Image captured for a static scene.
2) Motion_blurred_image : Image captured using the camera for dynamic scene
3) Motion_blurred_image_created: Motion blurred image generated using the code. Here I have simply used Gaussian filter rather than finding the nonblurry regions. I have convolved with the whole image. I am not able to produce the regions similar to static regions in the static regions part because of lack of my knowledge on the topic. 
I have calculated the average gradient using prewitt and sobel filter. And Calculated the MSE between the motion_blurred_image_created and motion_blurred_image using them.

References:
http://docs.opencv.org/3.0-beta/doc/py_tutorials/py_tutorials.html
http://scikit-image.org/
http://in.mathworks.com/help/vision/ref/psnr.html
http://www.numpy.org/

