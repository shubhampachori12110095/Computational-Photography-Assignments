clc; clear all;  close all;

dirName = ('*.png'); % The main directory where LDR images are stored 
filelist = dir(dirName); %Reading the files in the directory
load exposure.mat% Loading the exposure values.

% Selecting any image as the base image.
baseimage = imread(filelist(1).name); %Taking any one of the image as the base image
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
    image = imread(filelist(i).name); % Reading the image 
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

L = log(exposure)'; % The log shutter speed for each image (number of columns)
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
% Making the hdr image
outputimage = zeros(size(baseimage)); % The matrix for hdr image
aggweight = zeros(size(baseimage)); % THis matrix counters the weighting factor that we do repeatedly
for i=1:length(exposure) 
        image = double(imread(filelist(i).name)); % Reading each image
        map(:,:,1) = (g1(image(:,:,1) + 1) - L(i)); 
        map(:,:,2) = (g2(image(:,:,2) + 1) - L(i));
        map(:,:,3) = (g3(image(:,:,3) + 1) - L(i));        
        % finding the saturated pixels.
        satpixels = ones(size(image));
        [rowssatRed, colssatRed] = find(image(:,:,1) >= 255); 
        [rowssatGreen, colssatGreen] = find(image(:,:,2) >= 255);
        [rowssatBlue, colssatBlue] = find(image(:,:,3) >= 255);
        for t = 1:length(rowssatRed)
            satpixels(rowssatRed(t),colssatRed(t),:) = 0 ;
        end       
        for t = 1:length(rowssatGreen)
            satpixels(rowssatGreen(t),colssatGreen(t),:) = 0 ;
        end
        for t = 1:length(rowssatBlue)
            satpixels(rowssatBlue(t),colssatBlue(t),:) = 0 ;
        end
        outputimage = outputimage + (w(image+1).* map); % Adding the weighted image to obtain the final output hdr radiance map
        % remove saturated pixels from the radiance map and the aggweight (saturated pixels
        % are zero in the satpixels matrix, all others are one i.e. it is like a mask)
        outputimage = outputimage.* satpixels; 
        aggweight = (aggweight + w(image+1)).* satpixels;
end

% Those pixels with the smallest exposure time will be saturated to zero therefore those
% pixel values are approximated from the picture with the highest exposure
% time i.e. with minimum exposure value.
satpixelIndex = find(outputimage == 0); 
u = find(exposure == min(exposure)); % finding the minimum exposure value.
image = double(imread(filelist(u).name)) ; % Reading the image with minimum exposure value
map(:,:,1) = (g1(image(:,:,1) + 1) - L(u)); 
map(:,:,2) = (g2(image(:,:,2) + 1) - L(u));
map(:,:,3) = (g3(image(:,:,3) + 1) - L(u));
outputimage(satpixelIndex) = map(satpixelIndex);
aggweight(satpixelIndex) = 1; %t Keep the aggweight for the saturated pixels to avoid division by zero 
outputimage = outputimage./ aggweight; % % normalizing the obtained hdr image 
hdrimage = exp(outputimage); % final hdr map. Since we did the calculation in the log domain.
save('hdr.mat','hdrimage')

%%

% The tonemapping code using bilateral filter starts from here

clear all; clc;

load hdr

image = hdrimage; % Reading the hdr image
R = image(:,:,1); % Separating the R component of the HDR image
G = image(:,:,2); % Separating the G component of the HDR image
B = image(:,:,3);  % Separating the B component of the HDR image
I = (20*R + 40*G + B)/61; %Finding the lumaninance map
r = R./I; g = G./I; b = B./I; %Fninding the 
logi = log10(I); % Finding the log component of the luminanace map
% Bilateral filtering starts from here.
w = 11; % Size of the bilateral filter
sigma_d = 2; % Sigma_d of the bilateral image
sigma_r = 0.12; % Sigma_r of the bilateral image

% Gaussian filter weights.
doG = fspecial('gaussian',w, sigma_d); % Gaussian Filter
doG = doG/max(max(doG)); % Normalizing the gaussian weights.
logf = zeros(size(logi)); % The filtered repsonse from bilateral filter
for i = (1+floor(w/2)):(size(logi,1)-floor(w/2))
   for j = (1+floor(w/2)):(size(logi,2)-floor(w/2))
         %Extrat the patch of size of the bilateral filter
         K = logi((i - floor(w/2)):(i + floor(w/2)),(j - floor(w/2)):(j + floor(w/2)),:); % Picking up the neighbourhood
         % Compute Gaussian range weights.
         dL = K(:,:,1)- logi(i,j);
         H = exp(-(dL.*dL)/(2*sigma_r^2));
         % Calculate bilateral filtered response.        
         bilateralfilter = H.*doG(((i - floor(w/2)):(i + floor(w/2)))-i+floor(w/2)+1,((j - floor(w/2)):(j + floor(w/2)))-j+floor(w/2)+1);
         bilateralfilter = bilateralfilter / sum(bilateralfilter(:)); % Normalized bilateral filter
         logf(i,j) = sum(sum(bilateralfilter.*K(:,:,1))); % Pixelwise correlation
    end
end    

logdetail = logi - logf ; %Prserving the details like edge etc.
delta = max(max(logf)) - min(min(logf)); % Normalizing value for the filtered luminance map by taking 
% the maximum and minimum component of the biltered image. This will be
% used for normalizing
compressfactor = log10(255)/delta; % Compressing the dynamic range of the luminance image 
logoutput = ((compressfactor*logf + logdetail)); % Obtaining the ompressed luminance image

tonemapped(:,:,1) = r.* ((10).^((logoutput))); % R component of the tone mapped image
tonemapped(:,:,2) = g.* ((10).^((logoutput))); % G component of the tone mapped image
tonemapped(:,:,3) = b.* ((10).^((logoutput))); % B component of the tone mapped image
figure() % Showing the tone mapped image 
imshow(tonemapped) 
title('tonemapped image')


