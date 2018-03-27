
%% Load Images
pathSlug = 'JesseApartment2/originalSpherePhotographs/';
sceneImg = imread(strcat(pathSlug, 'scene.jpg'));

for i=1:11
    origPath = strcat(pathSlug, 'im', num2str(i), '.jpg');
    origImages{i} = rot90(imread(origPath),3);
end

%% Crop Images

[cropped{i}, rectangle] = imcrop(origImages{2});
rectangle(4) = rectangle(3);

for i=1:11
    [cropped{i}, rectangle] = imcrop(origImages{i}, rectangle);
    
    cropPath = strcat('JesseApartment2/croppedSphereImages/im', num2str(i), '.jpg');
    imwrite(cropped{i}, cropPath);
end

%% Get EXIF Info and construct vector B
for i=1:11
    origPath = strcat(pathSlug, 'im', num2str(i), '.jpg');
    info = imfinfo(origPath);
    B(i) = info.DigitalCamera.ExposureTime;
end

%% Setup sparse matrix Z

