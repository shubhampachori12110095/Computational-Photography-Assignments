clc; clear all; close all;
im = imread('peppers.png'); % Reading the images
imd = im;
im = im2double(im);
sizetoreduce = 40; % This is equal to the number of seams to be removed horizontally. Same thing could be done for vertically, just to trasnpose the image 
% and everything will be done automatically.
for jj=1:sizetoreduce
    img = rgb2gray(im); %Converting rgb into grey for finding out the energy
    energy = abs(imfilter(img, [-1,0,1], 'replicate')) + abs(imfilter(img, [-1;0;1], 'replicate')); %Calculating the energy
    M = zeros(size(energy,1),size(energy,2)); % THis is the minimum function used for calculating the energy
    M(1,:) = energy(1,:);
    % Detecting the minimum in the neighbourhood of the pixel
    [rows, cols] = size(energy);    
    for m = 2 :rows
      for n = 1:cols
            if(n ==1)
                neighbour=[M(m-1,n),M(m-1,n+1)];
                M(m,n)= energy(m,n)+min(neighbour);
            elseif(n == cols)
                neighbour=[M(m-1,n),M(m-1,n-1)];
                M(m,n)= energy(m,n)+min(neighbour);
            else
                neighbour =[M(m-1,n),M(m-1,n+1),M(m-1,n-1)];
                M(m,n)= energy(m,n)+min(neighbour);
            end
       end
    end
     
%%
% Finding the optimal seam at a particular step
     seam = zeros(size(M,1),1); % The length of the seam is equal to the number of rows.
     endofseam = min(M(end,:)); %The minimum value at the end of the seam
     points = find(M(end,:) == endofseam); % Finding the position of the minimum value at the end of the seam to start with to connect the seam 
     seam(end) = points(ceil(rand*length(points))); %In case of multiple points of minimum are detected.
%%     
     for i = (size(M,1)-1):-1:1
         uu = M(i,max(seam(i+1)-1,1):min(seam(i+1)+1,size(M,2)));
         [endofseam,aa] = min(uu);
         seam(i)=aa+seam(i+1)-1-(seam(i+1)>1);
         
     end
%%   % Removing the seam from the image 
     newima = zeros(size(im, 1), (size(im, 2) - 1), size(im, 3)); 
     for i=1:size(im,1)
         newima(i,1:seam(i)-1,:)=im(i,1:seam(i)-1,:); 
         newima(i,seam(i):end,:)=im(i,seam(i)+1:end,:); %Removing the seam from the image
     end
      im = newima;
end
imshow(imd)
title('Original Image')
figure()
imshow(im)
title('Reduced Image')
