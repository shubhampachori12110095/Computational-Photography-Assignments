clc; clear all; close all;

%%Making the filter
sizeoffilter = 5;
filt = fspecial('average',sizeoffilter);
filt = filt/sum(sum(filt));
%%Reading the image
I2 = imread('image.jpg'); %Reading hte original good image
I2 = rgb2gray(I2); % converting it into the grayscale
I1 = I2;
[m,n]=size(I2);
I4 = double(I2);
I3 = (I4 - min(min(I4)))/(max(max(I4)) - min(min(I4)));
figure, imshow([I3]) %Showing the original image 
title('inputimage')
I2 = (imfilter(I2,filt));

psnr = 30;
sigma=256*10^(-psnr/20);
noise=randn(m,n)*sigma;   %Creating gaussian noise


I2 = double(I2) + noise;
I5 = double(I2);
I6 = (I5 - min(min(I5)))/(max(max(I5)) - min(min(I5)));
figure, imshow([I6]) %Showing the original image 
title('BlurredImagemotion')
drawnow
G = fft2(I2);
H = fft2(filt,m,n);

normG = abs(G).^2/(m*n);
HHf = H.*(abs(H)>0)+(abs(H)==0);
inverseHf = 1./HHf;
inverseHf = inverseHf.*(abs(H)>1)+abs(HHf).*inverseHf.*(abs(HHf)<=1);
normG = normG.*(normG>sigma^2)+sigma^2*(normG<=sigma^2);
Weinerfilt = inverseHf.*(normG-sigma^2)./(normG);
eXf = Weinerfilt.*G;
ex = real(ifft2(eXf));
Answer = (ex - min(min(ex)))/(max(max(ex)) - min(min(ex)));
figure()
title('DeconvolvedImageMotionWienerfilter')
imshow(Answer)
