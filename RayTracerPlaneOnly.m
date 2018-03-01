function [Illum,Ref] = RayTracerPlaneOnly( plane, envmap, imageParameters )
%
% [IllumPlaneOnly, RefPlaneOnly] = RayTracerPlaneOnly( floorplaneStruct, envmap, imageParameters);
%
% performs ray tracing for a floor plane without an object using an
% environment map and parameters of the output image. 
%
% Inputs:
%       floorplaneStruct: struct with 4 x 3 matrix floorplaneStruct.vertices,
%               1 x 3 vector floorplaneStruct.color,
%       envmap: struct with Nenvmapverts x 3 matrix envmap.vertices,
%               Nenvmapverts x 3 matrix envmap.colors
%       imageParameters: struct with scalar imageParameters.focalLength,
%                1 x 2 vector imageParameters.vanishingPoint
%                imageParameters.size
%
% Author: Natasha Banerjee

[Illum,Ref] = RayTracerPlaneOnlyMEX( plane.vertices,plane.color,...
    envmap.vertices,envmap.colors,...
    imageParameters.size,imageParameters.focalLength,imageParameters.vanishingPoint );

end