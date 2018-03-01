function VerticesOut = center3( VerticesIn )

% VerticesOut = center3( VerticesIn )
%
% centers the vertices at the origin

% VerticesIn: Nx3 input vertices (first column is x, second column is y,
%               third column is z)
% VerticesOut: Nx3 output vertices centered about origin
%
% Author: Natasha Banerjee

VerticesOut = bsxfun(@minus,VerticesIn,mean(VerticesIn));

end