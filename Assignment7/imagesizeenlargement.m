clc; clear all; close all;
im = imread('peppers.png'); % Reading the images
imd = im;
im = im2double(im);
sizetoenlarge = 100; % This is equal to the number of seams to be removed horizontally. Same thing could be done for vertically, just to trasnpose the image 
% and everything will be done automatically.
seam1 = zeros(size(im,1),sizetoenlarge); % This will store the number of sems to which image is enlaged
for jj=1:sizetoenlarge
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
         aa = M(i,max(seam(i+1)-1,1):min(seam(i+1)+1,size(M,2)));
         [endofseam,uu] = min(aa);
         seam(i)=uu+seam(i+1)-1-(seam(i+1)>1);
         im(i,seam(i),:) = bitand(i,1);
     end
     seam1(:,jj) = seam;
     im1 = im;
end
% Now we are using seam1( top seams to which image should be enlarged to
% enarge the image)
im3 = im2double(imd);
newimage = zeros(size(im, 1), (size(im, 2) + 1), size(im, 3));    
for jj = 1:sizetoenlarge
    im2 = padarray(im3,[0,1]);
    for i = 1:size(seam1,1)
         avg = (im2(i,seam1(i,jj),:)+ im2(i,seam1(i,jj)+1,:) + im2(i,seam1(i,jj)+2,:))/3;  % Averaging the neighbours
         newimage(i,:,:) = [im3(i,1:seam1(i,jj),:), avg, im3(i,seam1(i,jj)+1:end,:)]; % Adding the average value
    end   
    im3 = newimage;
    newimage = zeros(size(im3, 1), size(im3, 2) + 1, size(im3, 3));  
end
%%
Enlargedimage = im3; % New enlarged image
figure
imshow(Enlargedimage)
title('Enlarged Image')
figure
imshow(imd)
title('Original Image')