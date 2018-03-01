function [Illum, Ref, ObjectMask] = RayTracer( object, plane, envmap, imageParameters )
%
% [Illum, Ref, ObjectMask] = RayTracer( object, floorplaneStruct, envmap, imageParameters);
%
% performs ray tracing for a single object on a floor plane using an
% environment map and parameters of the output image. 
%
% Inputs:
%       object: struct with Nverts x 3 matrix object.vertices, 
%               Nfaces x 3 matrix object.faces,
%               Nfaces x 3 matrix object.colors,
%       floorplaneStruct: struct with 4 x 3 matrix floorplaneStruct.vertices,
%               1 x 3 vector floorplaneStruct.color,
%       envmap: struct with Nenvmapverts x 3 matrix envmap.vertices,
%               Nenvmapverts x 3 matrix envmap.colors
%       imageParameters: struct with scalar imageParameters.focalLength,
%                1 x 2 vector imageParameters.vanishingPoint
%                imageParameters.size
%
% Author: Natasha Banerjee

if ~iscell(object)
    % single object
    incell{1} = object.vertices;
    incell{2} = object.faces;
    incell{3} = object.colors;
else    
    % multiple objects... not fully implemented
    incell = cell( 3*length(object),1 );
    for i=1:length(object)
        incell{3*i-2} = object{i}.vertices;
        incell{3*i-1} = object{i}.faces;
        incell{3*i  } = object{i}.colors;
    end
    
end

[Illum,Ref,ObjectMask] = RayTracerMEX( incell{:}, plane.vertices, plane.color,...
    envmap.vertices, envmap.colors,...
    imageParameters.size, imageParameters.focalLength, imageParameters.vanishingPoint,1 );

end