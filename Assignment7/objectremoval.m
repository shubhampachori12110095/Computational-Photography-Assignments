clc; clear all;close all;
% Transposing the image according to which of the width or height of
% the mask is greater, so that least no. of seams could be removed and most
% of the image is preserved.
%%
im = imread('image.png');
Mask = imread('Mask.png');
Mask1 = Mask(:,:,1);
Masskk = Mask1; 
im1 = im(:,:,1);
im2 = im(:,:,2);
im3 = im(:,:,3);
[rowsMask,colsMask] = find(Mask1>0.5);
point1 = min(rowsMask);
point2 = min(colsMask);
point3 = max(rowsMask);
point4 = max(colsMask);
width = point4 - point2;
height = point3 - point1;
if (height > width)
    im4 = im;
else 
    im4(:,:,1) = im1'; 
    im4(:,:,2) = im2';
    im4(:,:,3) = im3';
    Mask2(:,:,1) = Mask1'; 
    Mask2(:,:,2) = Mask1';
    Mask2(:,:,3) = Mask1';
    Mask = Mask2;
end    
 im = im4;
 clear im1 im2 im3 im4 Mask1 point1 point3 point2 point4 colsMask rowsMask 
%%
imd = im;
im = im2double(im);
sizetoreduce = 50; % This is equal to the number of seams to be removed horizontally. Same thing could be done for vertically, just to trasnpose the image 
% and everything will be done automatically.
Mask1 = Mask(:,:,1);
while(length(find(Mask1 > 10)))
    [rowss, colss] = find(Mask1 > 10);
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
     x = ceil(length(rowss)/2);
     seam = zeros(size(Mask1,1),1); % The length of the seam is equal to the number of rows.
     seam(rowss(x)) = colss(x); %In case of multiple points of minimum are detected.
%%
     for i = (rowss(x)-1):-1:1
         uu = M(i,max(seam(i+1)-1,1):min(seam(i+1)+1,size(M,2)));
         [endofseam,nn] = min(uu);
         seam(i)=nn+seam(i+1)-1-(seam(i+1)>1);
     end
     
      for i = (rowss(x)+1):length(seam)
          uu = M(i,max(seam(i-1)-1,1):min(seam(i-1)+1,size(M,2)));
          [endofseam,nn] = min(uu);
          seam(i)=nn+seam(i-1)-1-(seam(i-1)>1);
%           im(i,seam(i),:) = bitand(i,1);
      end

%%   % Removing the seam from the image 
     newima = zeros(size(im, 1), (size(im, 2) - 1), size(im, 3));   
     for i=1:length(seam)
         newima(i,1:seam(i)-1,:)=im(i,1:seam(i)-1,:); 
         newima(i,seam(i):end,:)=im(i,seam(i)+1:end,:); %Removing the seam from the image
     end
     im = newima;
     %%   % Removing the seam from the Mask1 
     newimage = zeros(size(Mask1, 1), (size(Mask1, 2) - 1));   
     for i=1:length(seam)
         newimage(i,1:seam(i)-1)=Mask1(i,1:seam(i)-1);
         newimage(i,seam(i):end)=Mask1(i,seam(i)+1:end); %Removing the seam from the image
     end
     Mask1 = newimage;
     
end   
%%

if (height < width)
    im5(:,:,1) = im(:,:,1)';
    im5(:,:,2) = im(:,:,2)';
    im5(:,:,3) = im(:,:,3)';
    im = im5;
    Massk = Masskk';
    Masskk = Massk;
end
imshow(Mask1)
title('Thefinalmask')
figure()
imshow(im)
title('The final Image')
figure()
imshow(imd)
title('The original Image')
figure()
imshow(Masskk)
title('The original Mask')