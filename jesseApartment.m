
%% Load Images
pathSlug = 'JesseApartment2/originalSpherePhotographs/';
sceneImg = imread(strcat(pathSlug, 'scene.jpg'));

numImgs = 11;

for i=1:numImgs
    origPath = strcat(pathSlug, 'im', num2str(i), '.jpg');
    origImages{i} = rot90(imread(origPath),3);
end

%% Crop Images

[cropped{i}, rectangle] = imcrop(origImages{2});
rectangle(4) = rectangle(3);

for i=1:numImgs
    [cropped{i}, rectangle] = imcrop(origImages{i}, rectangle);
    
    cropPath = strcat('JesseApartment2/croppedSphereImages/im', num2str(i), '.jpg');
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
    scene = cropped{i};
    for c = 1:3
        % Get the image for the color channel
        im_c = reshape(im1(:,:,c), height*width, 1);
        start = (c-1)*height*width + 1;
        stop = c*height*width;
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

%% Convert HDR to 3D world coords

[e_xyz, e_rgb] = envmap2Dto3D(imgE);

envmap.vertices = e_xyz;
envmap.colors = e_rgb;


%% Load 3D object and create scene

load chair.mat;

scene = imread('JesseApartment2/originalSpherePhotographs/scene.JPG');
scene = rot90(scene,3);

% Run the GUI in Figure 1
figure(1);
[vx,vy,irx,iry,orx,ory] = TIP_GUI(scene);

% Find the cube faces and compute the expanded image
[expandedim,expanded_alpha,vx,vy,ceilx,ceily,floorx,floory,...
    leftx,lefty,rightx,righty,backrx,backry] = ...
    TIP_get5rects(scene,vx,vy,irx,iry,orx,ory);

% display the expanded image
figure(2);
imshow(expandedim);

% Draw the Vanishing Point and the 4 faces on the image
figure(2);
hold on;
plot(vx,vy,'w*');
plot([ceilx ceilx(1)], [ceily ceily(1)], 'y-');
plot([floorx floorx(1)], [floory floory(1)], 'm-');
plot([leftx leftx(1)], [lefty lefty(1)], 'c-');
plot([rightx rightx(1)], [righty righty(1)], 'g-');
hold off;

% WRITE CODE HERE Use ceilx, ceily, floorx, floory, 
% leftx, lefty, rightx, righty, backx, backy and the vanishing point vx, vy
% together with an estimate of focal length f to compute 3D points
% for a box representing the room. Each set of [__x,__y] points specifies
% a quadrilateral, e.g., [ceilx,ceily] contains the corners for the 
% quadrilateral representing the ceiling.
% 
% You will need to plot each set
% of points (e.g., plot(ceilx,ceily,'b+') ) to see where they
% correspond to in the image.
% SAVE OUT A .mat FILE with your computed 3D points. You should have 
% four 3D points per plane for five plane or 20 3D points in total.

hold on;
plot(floorx(4),floory(4),'b+');
hold off;

Dback = 6000; %About 20ft, ~6m = 6000mm

%Everything is flipped on the y axis
hla1 = abs(vy(1) - lefty(1));
hla2 = abs(vy(1) - lefty(2));
Hla = (hla2/f) * Dback;
hlb1 = abs(lefty(4) - vy(1));
hlb2 = abs(lefty(3) - vy(1));
Hlb = (hlb2/f) * Dback;
Dl = Dback - (hla2/hla1) * Dback;

hra1 = abs(vy(1) - righty(2));
hra2 = abs(vy(1) - righty(1));
Hra = (hra2/f) * Dback;
hrb1 = abs(righty(3) - vy(1));
hrb2 = abs(righty(4) - vy(1));
Hrb = (hrb2/f) * Dback;
Dr = Dback - (hra2/hra1) * Dback;

wca1 = abs(vx(1) - ceilx(2));
wca2 = abs(vx(1) - ceilx(3));
Wca = (wca2/f) * Dback;
wcb1 = abs(ceilx(1) - vx(1));
wcb2 = abs(ceilx(4) - vx(1));
Wcb = (wcb2/f) * Dback;
Dc = Dback - (wca2/wca1) * Dback;

wfa1 = abs(vx(1) - floorx(3));
wfa2 = abs(vx(1) - floorx(2));
Wfa = (wfa2/f) * Dback;
wfb1 = abs(floorx(4) - vx(1));
wfb2 = abs(floorx(1) - vx(1));
Wfb = (wfb2/f) * Dback;
Df = Dback - (wfa2/wfa1) * Dback;

%TL, TR, BL, BR
PL1 = [-Wca,Hla,Dback-Dl];
PL2 = [-Wca,Hla,Dback];
PL3 = [-Wfa,-Hlb,Dback-Dl];
PL4 = [-Wfa,-Hlb,Dback];
leftplane = [PL1;PL2;PL3;PL4];

PR1 = [Wcb,Hra,Dback];
PR2 = [Wcb,Hra,Dback - Dr];
PR3 = [Wfb,-Hrb,Dback];
PR4 = [Wfb,-Hrb,Dback - Dr];
rightplane = [PR1;PR2;PR3;PR4];

PC1 = [-Wca,Hla,Dback - Dc];
PC2 = [Wcb, Hra,Dback - Dc];
PC3 = [-Wca,Hla,Dback];
PC4 = [Wcb,Hra,Dback];
ceilplane = [PC1;PC2;PC3;PC4];

PF1 = [-Wfa,-Hlb,Dback];
PF2 = [Wfb,-Hrb,Dback];
PF3 = [-Wfa,-Hlb,Dback - Df];
PF4 = [Wfb,-Hrb,Dback - Df];
floorplane = [PF1;PF2;PF3;PF4];

PB1 = [-Wca,Hla,Dback];
PB2 = [Wcb,Hra,Dback];
PB3 = [-Wfa,-Hlb,Dback];
PB4 = [Wfb,-Hrb,Dback];
backplane = [PB1;PB2;PB3;PB4];

%% Make planes right-handed and create floorplaneColor
leftplane(:,2) = -leftplane(:,2);
rightplane(:,2) = -rightplane(:,2);
ceilplane(:,2) = -ceilplane(:,2);
floorplane(:,2) = -floorplane(:,2);
backplane(:,2) = -backplane(:,2);

R = roipoly(expandedim, floorx, floory);
vals = reshape(expandedim,[],3);
vals = vals(R,:);

floorplaneColor = [0.54,0.27,0.07];

floorplaneStruct.vertices = floorplane;
floorplaneStruct.color = floorplaneColor;
%% Position 3D model

chair.vertices = scale3(chair.vertices, [3,3,3]);
chair.vertices = rotate3(chair.vertices, 'y', pi/6);
chair.vertices = translate3( chair.vertices, [-150, -2500, 5000] );
figure(3);

plotPlanes( leftplane, 'r-', rightplane, 'g-', ceilplane, 'b-', floorplane, 'c-', backplane, 'y-' );
patch( 'vertices', chair.vertices, 'faces', chair.faces, 'facecolor', 'flat', 'facevertexcdata', chair.colors );

%% Resize image

imageParameters.focalLength = f;
imageParameters.vanishingPoint = [vx, vy];
imageParameters.size = [size(expandedim,1), size(expandedim,2)];

expandedim = imresize( expandedim,1/4 ); imageParameters.focalLength = f/4;
imageParameters.vanishingPoint = [vx/4, vy/4];
imageParameters.size = [size(expandedim,1), size(expandedim,2)];


%% Mex stuff
[IllumImage, ReflectImage, ObjectMask] = RayTracer( chair, floorplaneStruct, envmap, imageParameters );

alpha = 100;
IllumImage = IllumImage * alpha;

[IllumImagePlaneOnly, ReflectImagePlaneOnly] = RayTracerPlaneOnly( floorplaneStruct, envmap, imageParameters );
IllumImagePlaneOnly = IllumImagePlaneOnly * alpha;

RenderWithObject = IllumImage .* ReflectImage;
RenderWithoutObject = IllumImagePlaneOnly .* ReflectImagePlaneOnly;

imwrite(IllumImage,'IllumImage.png');
imwrite(ReflectImage,'ReflectImage.png');
imwrite(IllumImagePlaneOnly,'IllumImagePlaneOnly.png');
imwrite(ReflectImagePlaneOnly,'ReflectImagePlaneOnly.png');
imwrite(RenderWithObject,'RenderWithObject.png');
imwrite(RenderWithoutObject,'RenderWithoutObject.png');

%% Differential rendering

Output = differentialRender(expandedim, RenderWithObject, RenderWithoutObject, ObjectMask);
imwrite(Output,'Output.png');
