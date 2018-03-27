
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

