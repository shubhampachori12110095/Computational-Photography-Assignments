clc; clear all ;close all;
%% Designing the average filter
sizeofilter = 3; %size of average filter
filt = fspecial('average', sizeofilter) ; %Creating average filter since average filter produces motion blur effect
%%Loading the image
I2 = imread('image.jpg'); %Reading hte original good image
I2 = rgb2gray(I2); % converting it into the grayscale
figure, imshow([I2]) %Showing the original image 
title('inputimage')

I = (imfilter(I2,filt)); %Convolving our image with gaussian filter to produce defocussed image 
I3 = I;
I = imnoise(I,'gaussian',0.0001);
% Normalizing hte input image matrix
x = double(I);
xnorm = (x - min(min(x)))/(max(max(x)) - min(min(x)));
I = xnorm;
figure(),imshow(xnorm)
title('Blurredimagedefocuswithnoisemotionblur')


%% Paramteres to play with
we=0.00001; % Regulazrizer for the edge derivates will be used in regression
max_it= 600; %Maximum no of iterations for regression below
%%
[n,m]=size(I); % Size of the input image
hfs_x1=floor((size(filt,2)-1)/2); %Half the size of our filter in the vertical direction. This is useful for our zero padding 
hfs_y1=floor((size(filt,1)-1)/2); %Half the size of our filter in the horizontal direction. This is useful for our zero padding
%% Here we will see that the padding is done. This is done to ensure that the repeated convolution 
%doesnot effect the boundary of the orignal image
I = medfilt2(I,[15 15]);

tI = padarray(I,[((hfs_y1)+(sizeofilter-1)) ((hfs_x1)+(sizeofilter-1))],'symmetric'); 
% Derivative filters
dyf=[1 -1]; % Derivative filter in the vertical direction
dxf=dyf'; % Derivative filter in the horizontal direction
%
%%
dy=imfilter(tI,(dyf)); %Calculating the horizontal derivatives and storing it in an array
dx=imfilter(tI,(dxf)); %Calculating the vertical derivatives and storing it in an array
b=imfilter(tI,filt); %Calculating the filtered value of motionblurred

Ax= imfilter(imfilter(tI,filt),filt); %Calculating the filtered value of motionblurred 

Ax=Ax+we*dx; 

Ax=Ax+we*dy;

% Regression starts from here
r = b - Ax; % Residual array
for iter = 1:max_it  % Regression starts from here 
     rho = sum(sum(r.*r)); % Finding the square of the residual matrix
     if ( iter > 1 ),                       
        beta = rho / rho_1; % This will be our weights for regularization 
        p = r + beta*p; 
     else
        p = r; 
     end
     Ap=imfilter(imfilter(p,(filt)),filt); % Convolving residual with average filter. 
     Ap=Ap+we*imfilter(p,(dxf)); % Convolving residual with vertical derivative filter.
     Ap=Ap+we*imfilter(p,(dyf)); % Convolving residual with horizontal derivative filter.
     q = Ap;
     alpha = rho / sum(sum(p.*q ));
     tI = (tI) + alpha * p;                    % update our approximation vector
     r = r - alpha*q;                      % compute residual
     rho_1 = rho;
end
x = tI;  % Our obtained deconvolved image but with padding
[n,m]=size(x);
Answer = (x((3*(hfs_y1))+1:n-(3*(hfs_y1)),(3*(hfs_x1))+1:m-(3*(hfs_y1)))); %Our final deconvolved image
figure, imshow(Answer)
title('DeconvolvedimagewithNoisemotionblur')
drawnow

% Normalizing hte input image matrix
x = double(I3);
xnorm = (x - min(min(x)))/(max(max(x)) - min(min(x)));
I3 = xnorm;
figure()
imshow(xnorm)
title('Blurredimagemotionblurwithoutnoise')

%% Paramteres to play with
we=0.00001; % Regulazrizer for the edge derivates will be used in regression
max_it= 600; %Maximum no of iterations for regression below
%%
[n,m]=size(I3); % Size of the input image
hfs_x1=floor((size(filt,2)-1)/2); %Half the size of our filter in the vertical direction. This is useful for our zero padding 
hfs_y1=floor((size(filt,1)-1)/2); %Half the size of our filter in the horizontal direction. This is useful for our zero padding
%% Here we will see that the padding is done. This is done to ensure that the repeated convolution 
%doesnot effect the boundary of the orignal image

tI = padarray(I3,[((hfs_y1)+(sizeofilter-1)) ((hfs_x1)+(sizeofilter-1))],'symmetric'); 
% Derivative filters
dyf=[1 -1]; % Derivative filter in the vertical direction
dxf=dyf'; % Derivative filter in the horizontal direction
%
%%
dy=imfilter(tI,(dyf)); %Calculating the horizontal derivatives and storing it in an array
dx=imfilter(tI,(dxf)); %Calculating the vertical derivatives and storing it in an array
b=imfilter(tI,filt); %Calculating the filtered value of motionblurred

Ax= imfilter(imfilter(tI,filt),filt); %Calculating the filtered value of motionblurred 

Ax=Ax+we*dx; 

Ax=Ax+we*dy;

% Regression starts from here
r = b - Ax; % Residual array
for iter = 1:max_it  % Regression starts from here 
     rho = sum(sum(r.*r)); % Finding the square of the residual matrix
     if ( iter > 1 ),                       
        beta = rho / rho_1; % This will be our weights for regularization 
        p = r + beta*p; 
     else
        p = r; 
     end
     Ap=imfilter(imfilter(p,(filt)),filt); % Convolving residual with average filter. 
     Ap=Ap+we*imfilter(p,(dxf)); % Convolving residual with vertical derivative filter.
     Ap=Ap+we*imfilter(p,(dyf)); % Convolving residual with horizontal derivative filter.
     q = Ap;
     alpha = rho / sum(sum(p.*q ));
     tI = (tI) + alpha * p;                    % update our approximation vector
     r = r - alpha*q;                      % compute residual
     rho_1 = rho;
end
x = tI;  % Our obtained deconvolved image but with padding
[n,m]=size(x);
Answer = (x((3*(hfs_y1))+1:n-(3*(hfs_y1)),(3*(hfs_x1))+1:m-(3*(hfs_y1)))); %Our final deconvolved image
figure, imshow(Answer)
title('DeconvolvedimagewithoutNoisemotionblur')
drawnow


