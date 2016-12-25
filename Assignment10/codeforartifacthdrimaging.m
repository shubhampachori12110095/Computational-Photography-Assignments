%% Creating the artifact free hdr image
clear all ; clc; 
load cameraresponse
imagespath = ('./ArchSequence/'); % Put the path for images here.
dirName = (strcat(imagespath,'*.tif')); % The main directory where LDR images are stored 
load (strcat(imagespath,'exposure.mat'));
load (strcat(imagespath,'relexposure.mat'));
filelist = dir(dirName); %Reading the files in the directory
ref = ceil(length(filelist)/2); % Taking the middle one image as the reference or base image

baseimage = imread(strcat(imagespath,filelist(ref).name)); % Reading the base image
rows = size(baseimage, 1); 
cols = size(baseimage, 2);
for k = 1:length(exposure) 
  image = imread(strcat(imagespath,filelist(ref).name));
  image2 = imread(strcat(imagespath,filelist(k).name)); 
  logE3{:,:,1,k} = (g1(double(image(:,:,1)) + 1) - log(exposure(k)));
  logE3{:,:,2,k} = (g1(double(image(:,:,2)) + 1) - log(exposure(k)));
  logE3{:,:,3,k} = (g1(double(image(:,:,3)) + 1) - log(exposure(k)));
  logE{:,:,1,k} = (g1(double(image2(:,:,1)) + 1)) ; % Log Exposure of the captured images red channel
  logE{:,:,2,k} = (g1(double(image2(:,:,2)) + 1)) ; % Log Exposure of the captured images green channel
  logE{:,:,3,k} = (g1(double(image2(:,:,3)) + 1)) ; % Log Exposure of the captured images blue channel
  logE2{:,:,1,k} = (g1(double(image(:,:,1)) + 1)) + relexposure(k); % Log Exposure of the image with relative exposure to ground truth red channel
  logE2{:,:,2,k} = (g1(double(image(:,:,2)) + 1)) + relexposure(k); % Log Exposure of the image with relative exposure to ground truth green channel
  logE2{:,:,3,k} = (g1(double(image(:,:,3)) + 1)) + relexposure(k); % Log Exposure of the image with relative exposure to ground truth blue channel
end    
gmap = zeros(rows, cols, length(filelist)); % Creating the ghost maps by finding the deviation between exposure maps of 
% captured images and calculated exposure with base image using relative exposure. 

% Finding the ghost maps;
threhold = 0.2;
for k = 1:length(exposure)
    rr(:,:,1) = logE2{:,:,1,k};
    rr(:,:,2) = logE2{:,:,2,k};
    rr(:,:,3) = logE2{:,:,3,k};
    ss(:,:,1) = logE{:,:,1,k};
    ss(:,:,2) = logE{:,:,2,k};
    ss(:,:,3) = logE{:,:,3,k};
    if (k>=ref)
        dd = ss - rr;
        ans1 = dd(:,:,1);
        ans1(ans1>=(k-ref+threhold))=1;
        ans1(ans1<=(ref-k-threhold))=1;
        ans1(ans1~=1)=0;
        ans2 = dd(:,:,2);
        ans2(ans2>=(k-ref+threhold))=1;
        ans2(ans2<=(ref-k-threhold))=1;
        ans2(ans2~=1)=0;
        ans3 = dd(:,:,3);
        ans3(ans3>=(k-ref+threhold))=1;
        ans3(ans3<=(ref-k-threhold))=1;
        ans3(ans3~=1)=0;
        ans4 = ans1+ans2+ans3;
        ans4(ans4>=1) = 1;
        gmap(:,:,k) = ~(ans4);
    else
        dd = rr - ss;
        ans1 = dd(:,:,1);
        ans1(ans1<=(k-ref-threhold))=1;
        ans1(ans1>=(ref-k+threhold))=1;
        ans1(ans1~=1)=0;
        ans2 = dd(:,:,2);
        ans2(ans2<=(k-ref-threhold))=1;
        ans2(ans2>=(ref-k+threhold))=1;
        ans2(ans2~=1)=0;
        ans3 = dd(:,:,3);
        ans3(ans3<=(k-ref-threhold))=1;
        ans3(ans3>=(ref-k+threhold))=1;
        ans3(ans3~=1)=0;
        ans4 = ans1+ans2+ans3;
        ans4(ans4>=1) = 1;
        gmap(:,:,k) = ~(ans4);
    end    
end    
gmap(:,:,ref) = 1; % Since The reference image doesn't contain any ghosting artifacts

% Since the ghost images could be noisy it requires dilation and erosion so
% that the ghost artiffact doesn't affect the neighbouring pixels and they
% are removed. Thus ghost regions are enlarged using erosion(since
% ghosting pixels are black in color)
for k = 1:length(filelist)
    if k ~= ref
        se = strel('disk',2);
        gmap(:,:,k) = imerode(gmap(:,:,k),se);
        se = strel('disk',1);
        gmap(:,:,k) = imdilate(gmap(:,:,k),se);
    end
end

% Creating HDR image

hdr = zeros(rows,cols,3); 

% Finding the weighting function value for pixel value z.
weight = []; % Weight of the pixel in images
Zmin = 0; %Minimum of the ldr image
Zmax = 255; %Maximum of the ldr image

% Creating the weight array for each pixels
for i=1:(Zmax - Zmin + 1)
    if (i <= 0.5*(Zmin + Zmax + 2))        
      weight(i) = i - Zmin ;      
    else
      weight(i) = (Zmax - i) + 2;  
    end  
end

for i = 1:3
    num = zeros(rows,cols);
    den = zeros(rows,cols);
    for k = 1:length(filelist)
        image = imread(strcat(imagespath,filelist(k).name));
        w = gmap(:,:,k).*weight(image(:,:,i) + 1);
        den = den + w;
        num = num + w .* exp(logE3{:,:,i,k});
    end
    Ei = ones(rows,cols); %Exposure for the ith color channel.
    j = find(den>0);
    Ei(j) = num(j) ./ den(j);     
    hdr(:,:,i) = Ei;
end
hdrimage = (hdr - min(min(min(hdr))))/(max(max(max(hdr))) - min(min(min(hdr))));

save('hdr.mat','hdrimage')


%% Producing the tonemapped image using the bilateral filtering.
clear all; clc; close all;
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



