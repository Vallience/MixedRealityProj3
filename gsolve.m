% Z = digital value between 0 and 255 inclusive in a matrix of size numpixels*3 x numimages,
% B = log of shutter times (e.g., log(1/519)), size is 1xnum_images
% l = weight on amount of smoothing on g (higher weight => more smoothing)
%
% Slightly modified from Debevec & Malik to have no individual weights on g
function [g,lE]=gsolve(Z,B,l) 
n = 256;
A = zeros(size(Z,1)*size(Z,2)+n+1,n+size(Z,1));
b = zeros(size(A,1),1);
%% Include the data-fitting equations
k = 1;
for i=1:size(Z,1)
  for j=1:size(Z,2)
    A(k,Z(i,j)+1) = 1;  A(k,n+i) = -1;       b(k,1) = B(j);
    k=k+1;
  end
end
%% Fix the curve by setting its middle value to 0
A(k,129) = 1;
k=k+1;
%% Include the smoothness equations
for i=1:n-2
  A(k,i)=l;        A(k,i+1)=-2*l;  A(k,i+2)=l;
  k=k+1;
end
%% Solve the system using least-squares solve
x = A\b;
g = x(1:n);
lE = x(n+1:size(x,1));
end