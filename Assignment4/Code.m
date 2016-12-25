%% Code reference
%http://in.mathworks.com/help/vision/examples/feature-based-panoramic-image-stitching.html

clc; clear all; close all;

srcFiles = dir('images\*.jpg');  % the folder in which ur images are stored

for i = 1 : length(srcFiles)
    filename = strcat('images\',srcFiles(i).name); % Reading the images
    I = imread(filename);
    if (ndims(I) > 2) % Converting them into the gray scale if they are RGB
    FEATURES(i).grayimage = rgb2gray(I);
    FEATURES(i).points = detectSURFFeatures(FEATURES(i).grayimage); % Calculating their SURF keypoints
    [FEATURES(i).features, FEATURES(i).points] = extractFeatures(FEATURES(i).grayimage, FEATURES(i).points); % Calculating their SURF features from keypoints
    else 
    FEATURES(i).grayimage = I;
    FEATURES(i).points = detectSURFFeatures(FEATURES(i).grayimage); % Calculating their SURF keypoints
    [FEATURES(i).features, FEATURES(i).points] = extractFeatures(FEATURES(i).grayimage, FEATURES(i).points); % Calculating their SURF features from keypoints 
    end
end    

transforms(length(srcFiles)) = projective2d(eye(3)); % Getting the projective transformation matrix

for i = 1:(length(srcFiles)-1)
   points1 = FEATURES(i).points; %Calculating the feature points of the previous image
   points2 = FEATURES(i+1).points; %Calculating the feature points of the previous image  
   features1 = FEATURES(i).features; %Extracting the features corresponding to the feature points of the previous image
   features2 = FEATURES(i+1).features; %Extracting the features corresponding to the feature points of the previous image
   indexPairs = matchFeatures(features2, features1, 'Unique', true); % Calculating the features which match.
   matched1 = points2(indexPairs(:,1), :); % Calculating the points location correspondng to features which match in image 1
   matched2 = points1(indexPairs(:,2), :); % Calculating the points location correspondng to features which match in image 2
   % Estimate the transformation between I(n+1) and I(n)
   transforms(i+1) = estimateGeometricTransform(matched1, matched2,...
     'projective', 'Confidence', 99.999, 'MaxNumTrials', 200); %Estimating the transformation Geometry
   transforms(i+1).T = transforms(i).T * transforms(i+1).T;   % Estimating all the tranformations with respect to the first image
end    

% Computing the size of the image required for creaing the panorama

for i = 1:length(srcFiles)
    filename = strcat('images\',srcFiles(i).name);
    [xlim(i,:), ylim(i,:)] = outputLimits(transforms(i), [1  size(imread(filename),2)], [1 size(imread(filename),1)]);
end

imageSize = size(imread(filename)); 
avgXLim = mean(xlim, 2);
[~, idx] = sort(avgXLim);
centerIdx = floor((length(srcFiles)+1)/2);
centerImageIdx = idx(centerIdx);
Tinv = invert(transforms(centerImageIdx));

for i = 1:length(srcFiles)
    transforms(i).T = Tinv.T * transforms(i).T;
end

for i = 1:length(srcFiles)
    filename = strcat('images\',srcFiles(i).name);
    [xlim(i,:), ylim(i,:)] = outputLimits(transforms(i), [1  size(imread(filename),2)], [1 size(imread(filename),1)]);
end

% Find the minimum and maximum output limits
xMin = min([1; xlim(:)]);
xMax = max([imageSize(2); xlim(:)]);
yMin = min([1; ylim(:)]);
yMax = max([imageSize(1); ylim(:)]);

% Width and height of panorama
width  = ceil(xMax - xMin);
height = ceil(yMax - yMin);

% Initialize the "empty" panorama.
panorama = uint8(zeros([height width 3]));
blender = vision.AlphaBlender('Operation', 'Binary mask', ...
    'MaskSource', 'Input port');

% Create a 2-D spatial reference object defining the size of the panorama.
xLimits = [xMin xMax];
yLimits = [yMin yMax];
panoramaView = imref2d([height width], xLimits, yLimits); % Defining the size of the panorama.

% Create the panorama.
for i = 1:length(srcFiles)
    filename = strcat('images\',srcFiles(i).name);
    I = imread(filename);
    warpedImage = imwarp(I, transforms(i), 'OutputView', panoramaView); % Warping the image to create the panorama.
    panorama = step(blender, panorama, warpedImage, warpedImage(:,:,1)); %Overlaying the warped image onto the panoram
end

figure()
imshow(panorama)
