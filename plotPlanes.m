function plotPlanes( varargin ) 

for i=1:nargin/2
    p=varargin{2*i-1};
    c=varargin{2*i}; hold on; 
    plot3( p([1,2,4,3,1],1),p([1,2,4,3,1],2),p([1,2,4,3,1],3),c);
end

end