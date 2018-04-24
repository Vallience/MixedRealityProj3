
%% Load Images
pathSlug = 'NickApartment/originalSpherePhotographs/';
sceneImg = imread(strcat(pathSlug, 'scene.jpg'));

numImgs = 7;

for i=1:numImgs
    origPath = strcat(pathSlug, 'im', num2str(i), '.jpg');
    origImages{i} = imread(origPath);
end

%% Crop Images

[cropped{i}, rectangle] = imcrop(origImages{2});
rectangle(4) = rectangle(3);

for i=1:numImgs
    cropped{i} = imcrop(origImages{i}, rectangle);
    
    cropPath = strcat('NickApartment/croppedSphereImages/im', num2str(i), '.jpg');
    imwrite(cropped{i}, cropPath);
end

%% Get EXIF Info and construct vector B
for i=1:numImgs
    origPath = strcat(pathSlug, 'im', num2str(i), '.jpg');
    info = imfinfo(origPath);
    B(i) = info.DigitalCamera.ExposureTime;
end

%% Setup Z Matrix

% do this for each image to get each color channel as a vector

im1 = cropped{1};
[height, width, depth] = size(im1)

Z = zeros(height*width*3, numImgs); 

for i = 1:numImgs
    im = cropped{i};
    for c = 1:3
        % Get the image for the color channel
        im_c = reshape(im(:,:,c), height*width, 1);
        start = (c-1)*height*width + 1
        stop = c*height*width
        Z(start:stop, i) = im_c;
    end
end

%% Get the HDR image using gsolve
% use gsolve to get the log of the input illumination

%B = log(B);

[g, le] = gsolve(Z, B, 1);

% get the HDR version properly by exponentiating the log
E = exp(le);

% rebuild E into an image
% which is the opposite of setting up Z

imgE = zeros(height, width);

k = 1;
for c = 1:3
    for y = 1:height
        for x = 1:width
            imgE(y,x,c) = E(k);
            k = k + 1;
        end
    end
end