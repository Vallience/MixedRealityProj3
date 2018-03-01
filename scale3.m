function VerticesOut = scale3(VerticesIn, scaleValues)

% VerticesOut = scale3( VerticesIn, scaleValues )
%
% scales 'VerticesIn' by the scale parameters in 'scaleValues' to give 'VerticesOut'
%
% VerticesIn:    Nvertices x 3 matrix of input vertices (each row has x, y, and z values)
% scaleValues:   1x3 vector ( [scale_in_x, scale_in_y, scale_in_z] )
% VerticesOut:   Nvertices x 3 matrix of output vertices
%
% Author: Natasha Banerjee

VerticesOut = VerticesIn * diag(scaleValues);

end