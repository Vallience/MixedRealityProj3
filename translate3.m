function VerticesOut = translate3(VerticesIn, translateValues)

% VerticesOut = scale3( VerticesIn, translateValues )
%
% moves 'VerticesIn' by the translation parameters in 'translateValues' to give 'VerticesOut'
%
% VerticesIn:    Nvertices x 3 matrix of input vertices (each row has x, y, and z values)
% translateValues:   1x3 vector ( [translation_in_x, translation_in_y, translation_in_z] )
% VerticesOut:   Nvertices x 3 matrix of output vertices
%
% Author: Natasha Banerjee

VerticesOut = bsxfun(@plus,VerticesIn,translateValues(:)');

end