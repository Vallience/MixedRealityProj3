
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

im1 = cropped{1};
[height, width, depth] = size(im1);

rList = zeros(height*width*3*7,1);
cList = zeros(height*width*3*7,1);
columnIndex = 1;

vList = zeros(height*width*3*7,1);
entryIndex = 1;

for i = 1:7
    im = cropped{i};
    for c = 1:3
        % Get the image for the color channel
        im_c = reshape(im1(:,:,c), height*width, 1);
        for j = 1:height*width
            if(im_c(j,1) ~= 0)
                %the row is the position of the element in the vector
                rList(entryIndex) = j; 
                cList(entryIndex) = columnIndex;
                vList(entryIndex) = im_c(j,1);
                entryIndex = entryIndex + 1;
            end
        end
        columnIndex = columnIndex + 1;
    end
end

rList = rList(1:entryIndex-1, 1);
cList = cList(1:entryIndex-1, 1);
vList = vList(1:entryIndex-1, 1);

Z = sparse(rList, cList, vList, height*width, 21);

%% Get the HDR image using gsolve
% use gsolve to get the log of the input illumination

% due to how gsolve works, you have to triple B to match the width of
% Z
B2 = zeros(size(B,1)*3,1);
index = 1;

for i = 1:size(B,1)
    B2(index) = B(i);
    B2(index+1) = B(i);
    B2(index+1) = B(i);
    index = index + 3;
end

[g, le] = gsolve(Z, B2, 1);

% get the HDR image by exponentiating the log
% E = exp(le)


    