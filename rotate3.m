function VerticesOut = rotate3( VerticesIn, axisName, theta )

% VerticesOut = rotate3( VerticesIn, axisName, theta )
%
% rotates 'VerticesIn' by the angle 'theta' around the axis 'axisName',
% where 'axisName' should be either 'x', 'y', or 'z'
%
% VerticesIn:    Nvertices x 3 matrix of input vertices (each row has x, y, and z values)
% axisName:      String character for axis ('x' for x-axis, 'y' for y-axis, or 'z' for z-axis, no other values allowed)
% theta:         angle of rotation around axis (in radians)
% VerticesOut:   Nvertices x 3 matrix of output vertices
%
% Author: Natasha Banerjee

if axisName(1)=='x'
    k=[1,0,0]';
elseif axisName(1)=='y'
    k=[0,1,0]';
elseif axisName(1)=='z'
    k=[0,0,1]';
end

Kx=[0,-k(3),k(2);k(3),0,-k(1);-k(2),k(1),0];
R=eye(3)+sin(theta)*Kx+(1-cos(theta))*(k*k'-eye(3));
VerticesOut = VerticesIn * R';

end