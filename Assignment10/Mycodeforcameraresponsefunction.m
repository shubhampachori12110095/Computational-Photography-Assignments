clc; clear all;  close all;
% The first half of the code computes the camera response fnction for the three channels. 
dirName = ('./Calibration/*.tif'); % The main directory where LDR images are stored 
imagespath = ('./Calibration/');
filelist = dir(dirName); %Reading the files in the directory
load ./Calibration/exposure.mat% Loading the exposure values.
% Selecting any image as the base image.
baseimage = imread(strcat(imagespath,filelist(1).name)); %Taking any one of the image as the base image
rows = size(baseimage,1); % Rows of the base image
cols = size(baseimage,2); % Rows of the base image

% Finding the weighting function value for pixel value z.
w = []; % Weight of the pixel in images
Zmin = 0; %Minimum of the ldr image
Zmax = 255; %Maximum of the ldr image

% Creating the weight array for each pixels
for i=1:(Zmax - Zmin + 1)
    if (i <= 0.5*(Zmin + Zmax + 2))        
      w(i) = i - Zmin ;      
    else
      w(i) = (Zmax - i) + 2;  
    end  
end
numSamples = ceil((Zmax - Zmin)/(length(exposure) - 1))*3 ;
 % Number of samples selected
samplepoint  = (randperm((rows*cols),numSamples))'; %Sampling the points from all the images

for i=1:length(exposure)
    image = imread(strcat(imagespath,filelist(i).name)); % Reading the image 
    % sample the image for each color channel
    redChannel = image(:,:,1); % Red channel of the image
    Z(:,i,1) = redChannel(samplepoint); %Sampled points of red channel of the image
    greenChannel = image(:,:,2); % Green channel of the image
    Z(:,i,2) = greenChannel(samplepoint); %Sampled points of green channel of the image
    blueChannel = image(:,:,3); % Blue channel of the image
    Z(:,i,3) = blueChannel(samplepoint); %Sampled points of blue channel of the image
    % build the resulting, small image consisting
    % of samples of the original image
end
L = log(exposure); % The log shutter speed for each image (number of columns)
B = repmat(L,(size(Z,1)*size(Z,2)),1);
l = 50; % Lambda in the original paper, This is the constant that determines the amount of smoothness 
% Solving the camera response function
[g1,lE1] = gsolve(Z(:,:,1), B, l, w);% Camera response function for the red channel
[g2,lE2] = gsolve(Z(:,:,2), B, l, w); % Camera response function for the green channel
[g3,lE3] = gsolve(Z(:,:,3), B, l, w); % Camera response function for the blue channel
x = 0:255;
figure()
plot(x,g1)
title('The camera response function for the red channel')
xlabel('log exposure X') % x-axis label
ylabel('pixel value Z') % y-axis label
figure()
plot(x,g2)
title('The camera response function for the green channel')
xlabel('log exposure X') % x-axis label
ylabel('pixel value Z') % y-axis label
figure()
plot(x,g3)
title('The camera response function for the blue channel')
xlabel('log exposure X') % x-axis label
ylabel('pixel value Z') % y-axis label
save cameraresponse.mat g1 g2 g3