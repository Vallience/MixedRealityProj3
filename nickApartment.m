pathSlug = 'JesseApartment/originalSpherePhotographs/';
sceneImg = imread(strcat(pathSlug, 'scene.jpg'));

for i=1:7
    exposures{i} = imread(strcat(pathSlug, 'im', num2str(i), '.jpg'));
    [cropped{i}, rects{i}] = imcrop(exposures{i});
    imwrite(cropped{i}, strcat('JesseApartment/croppedSphereImages/im', ...
        num2str(i), '.jpg'));
end