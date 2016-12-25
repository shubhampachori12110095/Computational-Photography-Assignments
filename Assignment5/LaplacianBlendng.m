clc; clear all; close all;

I1 = imread('apple1.jpg'); % Reading the first image
I2 = imread('orange1.jpg'); % Reading the second image
n = 7; %No. of levels in the image pyramid

% Creating the gaussian pyramid of the image1
for i = 1:n
    if (i ==1)      
      Image1GaussianPyr.(strcat('array',num2str(i))) = I1;
    else 
      Image1GaussianPyr.(strcat('array',num2str(i))) = impyramid(Image1GaussianPyr.(strcat('array',num2str(i-1))),'reduce');  
    end
end    

% Creating the gaussian pyramid of the image2
for i = 1:n
    if (i ==1)
      Image2GaussianPyr.(strcat('array',num2str(i))) = I2;
    else 
      Image2GaussianPyr.(strcat('array',num2str(i))) = impyramid(Image2GaussianPyr.(strcat('array',num2str(i-1))),'reduce');  
    end
end    

% Creating the laplacian pyramid of the image1
for i = n:-1:1
    if (i == n)
        Image1LaplacianPyr.(strcat('array',num2str(n-i+1))) = Image1GaussianPyr.(strcat('array',num2str(i)));     
    else
    G = impyramid(Image1GaussianPyr.(strcat('array',num2str(i+1))), 'expand');
    G = imresize(G,[size(Image1GaussianPyr.(strcat('array',num2str(i))),1) size(Image1GaussianPyr.(strcat('array',num2str(i))),2)]);
    Image1LaplacianPyr.(strcat('array',num2str(n-i+1))) = Image1GaussianPyr.(strcat('array',num2str(i))) - G;
    end
end    

% Creating the laplacian pyramid of the image2
for i = n:-1:1
    if (i == n)
        Image2LaplacianPyr.(strcat('array',num2str(n-i+1))) = Image2GaussianPyr.(strcat('array',num2str(i)));     
    else
    H = impyramid(Image2GaussianPyr.(strcat('array',num2str(i+1))), 'expand');    
    H = imresize(H,[size(Image2GaussianPyr.(strcat('array',num2str(i))),1) size(Image2GaussianPyr.(strcat('array',num2str(i))),2)]);
    Image2LaplacianPyr.(strcat('array',num2str(n-i+1))) = Image2GaussianPyr.(strcat('array',num2str(i))) - H;
    end
end   

%
% Creation of the mask
maskk = uint8(ones(size(I1,1), size(I1,2), 3));
% maskk(:, 1:ceil(cols/2), :) = 0;
maskk(:, 1:ceil((size(I1,2))/2), :) = 0;

figure()
imshow(maskk*255)

% Creating of the mask and its pyramid
for i = 1:n
    if (i ==1)
      mask.(strcat('array',num2str(i))) = maskk;
    else 
      mask.(strcat('array',num2str(i))) = impyramid(mask.(strcat('array',num2str(i-1))),'reduce');  
    end
end    

% Using the mask pyramid to create the blended regions.
for i = 1:n
   [rows, cols, dim] = size(Image2LaplacianPyr.(strcat('array',num2str(i))));
   LH1 = Image2LaplacianPyr.(strcat('array',num2str(i)));
   LG1 = Image1LaplacianPyr.(strcat('array',num2str(i)));
   mas = uint8(mask.(strcat('array',num2str(n-i+1))));
   LSS.(strcat('array',num2str(i))) =  [uint8(~mas).*LG1 + mas.*LH1];
end    

% Upsampling the pyramid to get the final blended image.
for i = 1: n
    if (i==1)
      lss_ = LSS.(strcat('array',num2str(i)));
    else
      lss_ = impyramid(lss_, 'expand');
      lss_ = imresize(lss_,[size(LSS.(strcat('array',num2str(i))),1) size(LSS.(strcat('array',num2str(i))),2)]);
      lss_ = lss_ + LSS.(strcat('array',num2str(i)));
    end
end

%Saving and showing the laplacian blended image.
figure()
imshow(lss_)
imwrite(lss_,'laplacianblended.jpg');
real = [I1(:,1:ceil(cols/2),:),I2(:,(ceil(cols/2)+1):cols,:)];
figure()
imshow(real)
imwrite(real,'withoutlaplacianblending.jpg');



