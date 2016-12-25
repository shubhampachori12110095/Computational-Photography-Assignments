clc; clear all; close all;
HH = hdrread('memorial.hdr'); % Loading an hdr image
lab= rgb2lab(HH);
%HHH = double(0.299*HH(:,:,1) +  0.587*HH(:,:,2) + 0.114*HH(:,:,3)); %Converting it into luminance (Y) space 
HHH = lab(:,:,1);
H0 = log10(HHH); % Taking the logarithm of the luminanace space.
figure(); imshow(H0,[]); title('Logarithmic Image in grayscale');

%% Creating the pyramid of luminance of the image. The minimum size is 32 for any edge.
iter = 1;
H.(strcat('array',num2str(iter))) = H0;
while (((min(size(H.(strcat('array',num2str(iter))),1),size(H.(strcat('array',num2str(iter))),2)))/2) >= 32)
   iter = iter + 1;
   H.(strcat('array',num2str(iter))) = impyramid(H.(strcat('array',num2str(iter-1))), 'reduce');
end
%%
for i = 1:iter
  G = padarray(H.(strcat('array',num2str(i))),[1 1],'symmetric');
  % Calculating the gradient in x direction
  for j = 2:(size(G,1)-1)
    for k = 2:(size(G,2)-1)
      gx(j-1,k-1) = double((G(j+1,k) - G(j-1,k))/((2^(i)))); 
    end
  end
  % Calculating the gradient in y direction
  for j = 2:(size(G,1)-1)
    for k = 2:(size(G,2)-1)
    gy(j-1,k-1) = double((G(j,k+1) - G(j,k-1))/((2^(i)))); 
    end
  end
  Gx.(strcat('array',num2str(i))) = gx;
  Gy.(strcat('array',num2str(i))) = gy;  
  Grad = sqrt(double(gx.*gx + gy.*gy)) + eps;
  Gradient.(strcat('array',num2str(i))) = Grad;
  alpha = 0.1*(sum(sum(Grad)))/(size(Grad,1)*size(Grad,2));
  beta = 0.85;
  psi.(strcat('array',num2str(i))) = (alpha./Grad).*((Grad./alpha).^beta);
  clear gx gy Grad ;
end

%%
for i = (iter-1):-1:1
    phi.(strcat('array',num2str(i))) = imresize(psi.(strcat('array',num2str(i+1))),[size(psi.(strcat('array',num2str(i))),1) size(psi.(strcat('array',num2str(i))),2)],'bilinear').*psi.(strcat('array',num2str(i)));
end  

Gxx = double(Gx.(strcat('array',num2str(1)))).*phi.(strcat('array',num2str(1))); 
Gyy = double(Gy.(strcat('array',num2str(1)))).*phi.(strcat('array',num2str(1)));

for i = 2:size(Gxx,1)
    for j = 2:size(Gxx,2)
        divG(i,j) = Gxx(i,j) - Gxx(i-1,j) + Gyy(i,j) - Gyy(i,j-1);
    end
end    
divG = imresize(divG, [size(H0,1) size(H0,2)]);

%%
% divergence between 0 and 1.
U = zeros((size(divG,1)),  (size(divG,2))); % Forming the true output image matrix. 
U = H0; % Intialization of U matrix

% From here poisson solving using Jacobi iteration has been initialized.
U(2,:) = H0(1,:);
U(1,:) = H0(1,:);
U(:,2) = H0(:,1);
U(:,1) = H0(:,1);
U(size(U,1)-1,:) = H0(size(U,1),:);
U(size(U,1),:) = H0(size(U,1),:);
U(:,size(U,2)-1) = H0(:,size(U,2));
U(:,size(U,2)) = H0(:,size(U,2));
V = U; 

K = [0,1,0;1,0,1;0,1,0];
for k = 1:15000
    V = U;
    V = imfilter(U,K,'replicate');  
    U = (V + divG)/4;
    % The below expressions impose the Neumann conditions that is
    % derivatives around the boundaries is equal to zero.
    U(2,:) = H0(1,:);
    U(1,:) = H0(1,:);
    U(:,2) = H0(:,1);
    U(:,1) = H0(:,1);
    U(size(U,1)-1,:) = H0(size(U,1),:);
    U(size(U,1),:) = H0(size(U,1),:);
    U(:,size(U,2)-1) = H0(:,size(U,2));
    U(:,size(U,2)) = H0(:,size(U,2));
end    
%% Generating the color of the output map.
UU = 10.^U;
M = UU;
s = 0.5;

OUT(:,:,1) = (((HH(:,:,1)./(HHH)).^s).*(M));
OUT(:,:,2) = (((HH(:,:,2)./(HHH)).^s).*(M));
OUT(:,:,3) = (((HH(:,:,3)./(HHH)).^s).*(M));
OUT(OUT>1)=1;
%%
RGB = tonemap(HH);
figure;
imshow(uint8(OUT*255))
title('Gradient domain Compressed Map')
imwrite(OUT,'tonemap.jpg');
figure()
imshow(RGB)
title('Tonemap by MATLAB')
imwrite(RGB,'tonemapMATLAB.jpg');