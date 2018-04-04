
%% Load Images
pathSlug = 'NickApartment/originalSpherePhotographs/';
sceneImg = imread(strcat(pathSlug, 'scene.jpg'));

for i=1:7
    origPath = strcat(pathSlug, 'im', num2str(i), '.jpg');
    origImages{i} = imread(origPath);
end

%% Crop Images

[cropped{i}, rectangle] = imcrop(origImages{2});
rectangle(4) = rectangle(3);

for i=1:7
    [cropped{i}, rectangle] = imcrop(origImages{i}, rectangle);
    
    cropPath = strcat('NickApartment/croppedSphereImages/im', num2str(i), '.jpg');
    imwrite(cropped{i}, cropPath);
end

%% Get EXIF Info and construct vector B
for i=1:7
    origPath = strcat(pathSlug, 'im', num2str(i), '.jpg');
    info = imfinfo(origPath);
    B(i) = info.DigitalCamera.ExposureTime;
end

%% Setup sparse matrix Z

% do this for each image to get each color channel as a vector

im1 = im2double(cropped{1});
[height, width, depth] = size(im1);

im1r = reshape(im1(:,:,1), height*width, 1);
im1g = reshape(im1(:,:,2), height*width, 1);
im1b = reshape(im1(:,:,3), height*width, 1);

% use gsolve to get the log of the input illumination
% [g, le] = gsolve(Z, B, 1)

% get the HDR image by exponentiating the log
% E = exp(le)


    