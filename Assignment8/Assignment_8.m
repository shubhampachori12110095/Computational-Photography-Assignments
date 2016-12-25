clc; clear all; close all; clear all;
I =imread('peppers.png'); % Our image to be read. Use three channel image
M = I;
imshow(M);
title('Original Image')
w  = 15;  % size bilateral filter
% Converting input RGB image to Lab image.
I = rgb2lab(I);
I = padarray(I,[floor(w/2) floor(w/2)],'replicate'); %Padding the array for the booundary region patch
% Setting  the paramenters for bilateral filter
sigma_d = 3; % bilateral filter standard deviations
sigma_r = 10; % bilateral filter standard deviations% Creating bilateral filter
% Gaussian filter weights.
doG = fspecial('gaussian',w, sigma_d); % Gaussian Filter
doG = doG/max(max(doG)); % Normalizing the gaussian weights.

filteredimage = zeros(size(I)); % The filtered repsonse from bilateral filter
for i = (1+floor(w/2)):(size(I,1)-floor(w/2))
   for j = (1+floor(w/2)):(size(I,2)-floor(w/2))
         %Extrat the patch of size of the bilateral filter
         K = I((i - floor(w/2)):(i + floor(w/2)),(j - floor(w/2)):(j + floor(w/2)),:); % Picking up the neighbourhood
         % Compute Gaussian range weights.
         dL = K(:,:,1)- I(i,j,1);
         da = K(:,:,2)- I(i,j,2);
         db = K(:,:,3)- I(i,j,3);
         H = exp(-(dL.*dL+da.*da+db.*db)/(2*sigma_r^2));
         % Calculate bilateral filtered response.        
         bilateralfilter = H.*doG(((i - floor(w/2)):(i + floor(w/2)))-i+floor(w/2)+1,((j - floor(w/2)):(j + floor(w/2)))-j+floor(w/2)+1);
         bilateralfilter = bilateralfilter / sum(bilateralfilter(:)); % Normalized bilateral filter
         filteredimage(i,j,1) = sum(sum(bilateralfilter.*K(:,:,1))); % Pixelwise correlation
         filteredimage(i,j,2) = sum(sum(bilateralfilter.*K(:,:,2))); % Pixelwise correlation
         filteredimage(i,j,3) = sum(sum(bilateralfilter.*K(:,:,3))); % Pixelwise correlation
    end
end    

ff1 = lab2rgb(filteredimage);
ff = ff1(floor(w/2)+1:(size(I,1)-floor(w/2)),floor(w/2)+1:(size(I,2)-floor(w/2)),:);
figure()
imshow(ff)
title('Bilateral filtered image')
[Grad,Gdir] = imgradient(filteredimage(:,:,1)); % Calculating the gradient of the bilateral filtered image
Grad = Grad/max(max(Grad));
% Target sharpness range
lamba_phi = 3;
omega_phi = 14;
S = (omega_phi - lamba_phi)*Grad + lamba_phi;
% Apply the quantization to the luminance channel.
dq = 10; % Size of the quantization bin
filteredimage(:,:,1) = (1/dq)*filteredimage(:,:,1); 
filteredimage(:,:,1) = dq*floor(filteredimage(:,:,1));
filteredimage(:,:,1) = filteredimage(:,:,1)+(dq/2)*tanh(S.*(filteredimage(:,:,1)-filteredimage(:,:,1)));
output1 = lab2rgb(filteredimage); %Converting back Lab into RGB space
% Highlighting edges to the abstracted image.%
% Taking doG of the bilateral filtered image
mingrad = 0.01 ; % Change this value for obtaining better boundary
maxgrad = 0.03 ; % Change this value for obtaining better boundary
h = fspecial('gaussian', 11, 3);
MotionBlur = imfilter(ff(:,:,1),h,'replicate');
doG = - MotionBlur + (ff(:,:,1));
doG = doG/max(max(doG));
doG(doG>maxgrad) = 1;
doG(doG<mingrad) = 0;
figure()
imshow(1-doG)
title('Difference of Gaussia Edge')
output =  output1(floor(w/2)+1:(size(I,1)-floor(w/2)),floor(w/2)+1:(size(I,2)-floor(w/2)),:); % Removing the padding of the image
% Add doG edges to quantized bilaterally-filtered image.
C(:,:,1) = (1-doG).*output(:,:,1);
C(:,:,2) = (1-doG).*output(:,:,2);
C(:,:,3) = (1-doG).*output(:,:,3);
C(C<0) = 0;
C(C>1) = 1;
figure()
imshow(C)
title('abstracted image')