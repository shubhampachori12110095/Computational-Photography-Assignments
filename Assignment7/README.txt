1) In the file imagesizereduction.m I have reduced the size of the image in the horizontal direction.
The similar thing could be done for the vertical direction too, just we need to transpose the original image. Moreover,
the same concept could be implemented for reducing the image in both vertical and horizontal by taking the original image
and its transpose. I have not did for vertical direction. Here the seam is reduced at once at a time. THen new energy is calculated
and then again image is reduced.

Just run the image. I have used peppers image which comes with image toolbox in MATLAB.  


2) In the file imagesizeenlargement.m I have enlarged the size of the image in the horizontal direction.
The similar thing could be done for the vertical direction too, just we need to transpose the original image. Moreover,
the same concept could be implemented for enlarging the image in both vertical and horizontal by taking the original image
and its transpose. Here instead of expnding the image by taking a seam at once, I have
taken k(size till which image is to be enlarged) seams together and expanded using those k seams. Otherwise we will 
observe the artifacts while expanding.

Just run the image. I have used peppers image which comes with image toolboxe in MATLAB.

3) In objectremoval.m code I have reduced the undesired object from the image using the mask. We calculate the size of the
mask whether it is larger in the width or the height. The one which is smaller in that dimenison the image is reduced. 
Just run the code and we will get the result.

References:

Avidan, Shai, and Ariel Shamir. "Seam carving for content-aware image resizing." ACM Transactions on graphics (TOG). Vol. 26. No. 3. ACM, 2007.