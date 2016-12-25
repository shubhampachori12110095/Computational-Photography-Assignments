clc; clear all; close all;

% Reading the three images
img1 = imread('img1.jpg');
if (ndims(img1) ==3)
  img1 = rgb2gray(img1);
end

img2 = imread('img2.jpg');
if(ndims(img2) ==3)
  img2 = rgb2gray(img2);
end

img3 = imread('img3.jpg');
if (ndims(img3) ==3)
  img3 = rgb2gray(img3);
end

% Detecting the harris features
C1 = detectHarrisFeatures(img1);
C2 = detectHarrisFeatures(img2);
C3 = detectHarrisFeatures(img3);

% Detecting the harris features and corners points corresponding to that.
[features1, valid_points1] = extractFeatures(img1, C1);
[features2, valid_points2] = extractFeatures(img2, C2);
[features3, valid_points3] = extractFeatures(img3, C3);

%Extracting the corner feature vectors 
Features1 = features1.Features;
Features2 = features2.Features;
Features3 = features3.Features;

% Making the coorealation matrix between the three feature vectors
d12 = correlationmatrix(Features1,Features2);
d23 = correlationmatrix(Features2,Features3);
d31 = correlationmatrix(Features3,Features1);

% The points are considered valid only if they are correlated above the
% threshold
threshold = 0.4;
[rows12,cols12] = find(d12>threshold);
[rows23,cols23] = find(d23>threshold);
[rows31,cols31] = find(d31>threshold);

% Obtaining the spatial location of correspondence points
[q112_12,q212_12] = cornerdescriptorpoints(rows12,cols12,valid_points1,valid_points2);
[q223_23,q323_23] = cornerdescriptorpoints(rows23,cols23,valid_points2,valid_points3);
[q331_31,q131_31] = cornerdescriptorpoints(rows31,cols31,valid_points3,valid_points1);

% Plotting the corner feature points on the three images
imshow(img1);
hold on
plot(q112_12(:,1), q112_12(:,2), 'r*');
plot(q131_31(:,1), q131_31(:,2), 'r*');
hold off
title('Image1')

figure()
imshow(img2);
hold on
plot(q212_12(:,1), q212_12(:,2), 'c*');
plot(q223_23(:,1), q223_23(:,2), 'c*');
hold off
title('Image2')

figure()
imshow(img3);
hold on
plot(q331_31(:,1), q331_31(:,2), 'b*');
plot(q323_23(:,1), q323_23(:,2), 'b*');
hold off
title('Image3')

% Plotting the two images together for the correspondence feature matching

rows1 = size(img1,1);
rows2 = size(img2,1);
rows3 = size(img3,1);

if (rows1<=rows2)
   img4 = [img1 ; zeros(rows2-rows1,size(img1,2))];
   img5 = img2;
elseif (rows1>=rows2)
   img5 =  [img2 ; zeros(rows1-rows2,size(img2,2))];
   img4 = img1;
end    
y = [img4 img5];
figure()
imshow(y);
hold on
title('Image1 and Image2')

q2_12(:,1) = q212_12(:,1)+size(img1,2);
q2_12(:,2) = q212_12(:,2);

plot(q2_12(:,1), q2_12(:,2), 'r*');
plot(q112_12(:,1), q112_12(:,2), 'c+');
for i = 1:size(q112_12,1)
    A = [q112_12(i,2),q2_12(i,2)];
    B = [q112_12(i,1),q2_12(i,1)];
    plot(B,A,'Y--')
end 

if (rows2<=rows3)
   img4 = [img2 ; zeros(rows3-rows2,size(img2,2))]; 
   img5 = img3;
elseif (rows2>=rows3)
   img5 =  [img3 ; zeros(rows2-rows3,size(img3,2))];
   img4 = img2;
end    
y = [img4 img5];
figure()
imshow(y);
hold on
title('Image2 and Image3')

q3_23(:,1) = q323_23(:,1)+size(img2,2);
q3_23(:,2) = q323_23(:,2);
plot(q3_23(:,1), q3_23(:,2), 'r*');
plot(q223_23(:,1), q223_23(:,2), 'c+');
for i = 1:size(q223_23,1)
    A = [q223_23(i,2),q3_23(i,2)];
    B = [q223_23(i,1),q3_23(i,1)];
    plot(B,A,'Y--')
end 

if (rows1<=rows3)
   img4 = [img1 ; zeros(rows3-rows1,size(img1,2))];
   img5 = img3;
elseif (rows1>=rows3)
   img5 =  [img3 ; zeros(rows1-rows3,size(img3,2))];
   img4 = img1;
end    
y = [img4 img5];
figure()
imshow(y);
hold on
title('Image1 and Image3')

q3_31(:,1) = q331_31(:,1)+size(img1,2);
q3_31(:,2) = q331_31(:,2);
plot(q3_31(:,1), q3_31(:,2), 'r*');
plot(q131_31(:,1), q131_31(:,2), 'c+');

for i = 1:size(q131_31,1)
    A = [q131_31(i,2),q3_31(i,2)];
    B = [q131_31(i,1),q3_31(i,1)];
    plot(B,A,'Y--')
end 


% Plotting the three images together for the correspondence feature matching
rows1 = size(img1,1);
rows2 = size(img2,1);
rows3 = size(img3,1);

if ((rows1<=rows2) && (rows3<=rows2))
   img1 = [img1 ; zeros(rows2-rows1,size(img1,2))]; 
   img3 = [img3 ; zeros(rows2-rows3,size(img3,2))];    
elseif ((rows1>=rows3) && (rows1>=rows2))
   img2 =  [img2 ; zeros(rows1-rows2,size(img2,2))];
   img3 =  [img3 ; zeros(rows1-rows3,size(img3,2))];
elseif ((rows3>=rows2) && (rows3>=rows1))
   img1 =  [img1 ; zeros(rows3-rows1,size(img1,2))];
   img2 =  [img2 ; zeros(rows3-rows2,size(img2,2))];   
end    
y = [img1 img2 img3];
figure()
imshow(y);
hold on
title('Figure with three images joined')

% Marking the correspondence points on the figure with three joint images.
q2_12(:,1) = q212_12(:,1)+size(img1,2);
q2_12(:,2) = q212_12(:,2);
q2_23(:,1) = q223_23(:,1)+size(img1,2);
q2_23(:,2) = q223_23(:,2);
q3_23(:,1) = q323_23(:,1)+size(img1,2)+size(img2,2);
q3_23(:,2) = q323_23(:,2);
q3_31(:,1) = q331_31(:,1)+size(img1,2)+size(img2,2);
q3_31(:,2) = q331_31(:,2);

plot(q2_12(:,1), q2_12(:,2), 'r*');
plot(q2_23(:,1), q2_23(:,2), 'y+');
plot(q112_12(:,1), q112_12(:,2), 'r*');
plot(q131_31(:,1), q131_31(:,2), 'c*');
plot(q3_23(:,1), q3_23(:,2), 'y+');
plot(q3_31(:,1), q3_31(:,2), 'c*');


% Plotting the lines between the correspondence points
for i = 1:size(q112_12,1)
    A = [q112_12(i,2),q2_12(i,2)];
    B = [q112_12(i,1),q2_12(i,1)];
    plot(B,A,'Y--')
end 

for i = 1:size(q131_31,1)
    A = [q131_31(i,2),q3_31(i,2)];
    B = [q131_31(i,1),q3_31(i,1)];
    plot(B,A,'C--')
end 

for i = 1:size(q223_23,1)
    A = [q2_23(i,2),q323_23(i,2)];
    B = [q2_23(i,1),q323_23(i,1)];
    plot(B,A,'B--')
end 

