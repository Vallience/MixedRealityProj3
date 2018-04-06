% Z = digital value between 0 and 255 inclusive in a matrix of size numpixels*3 x numimages,
% B = log of shutter times (e.g., log(1/519)), size is 1xnum_images
% l = weight on amount of smoothing on g (higher weight => more smoothing)
%
% Slightly modified from Debevec & Malik to have no individual weights on g
function [g,lE]=gsolve(Z,B,l) 
n = 256;

[height, width] = size(Z);

%values for sparse matrix A
rList = zeros(height*width,1);
cList = zeros(height*width,1);
vList = zeros(height*width,1);
entryIndex = 1;
%A = zeros(size(Z,1)*size(Z,2)+n+1,n+size(Z,1));
%b = zeros(size(A,1),1);
b = zeros(size(Z,1)*size(Z,2)+n+1, 1);

%% Include the data-fitting equations
k = 1;
for i=1:height
  for j=1:width
      % A(k,Z(i,j)+1) = 1;  A(k,n+i) = -1; PREVIOUS CODE
      rList(entryIndex) = k; cList(entryIndex) = Z(i,j) + 1; vList(entryIndex) = 1;
      entryIndex = entryIndex + 1;
      rList(entryIndex) = k; cList(entryIndex) = n + i;      vList(entryIndex) = -1;
      entryIndex = entryIndex + 1;
      
      b(k,1) = B(j);
      k=k+1;
  end
end
%% Fix the curve by setting its middle value to 0
% A(k,129) = 1; PREVIOUS CODE
rList(entryIndex) = k;
cList(entryIndex) = 129;
vList(entryIndex) = 1;
entryIndex = entryIndex + 1;
k=k+1;
%% Include the smoothness equations
for i=1:n-2
  % A(k,i)=l;        A(k,i+1)=-2*l;  A(k,i+2)=l; PREVIOUS CODE
  rList(entryIndex) = k;
  cList(entryIndex) = i;
  vList(entryIndex) = l;
  entryIndex = entryIndex + 1;
  
  rList(entryIndex) = k;
  cList(entryIndex) = i+1;
  vList(entryIndex) = -2*l;
  entryIndex = entryIndex + 1;
  
  rList(entryIndex) = k;
  cList(entryIndex) = i+2;
  vList(entryIndex) = l;
  entryIndex = entryIndex + 1;
  
  k=k+1;
end

rList = rList(1:entryIndex-1,1);
cList = cList(1:entryIndex-1,1);
vList = vList(1:entryIndex-1,1);

A = sparse(rList, cList, vList, size(Z,1)*size(Z,2)+n+1,n+size(Z,1));
size(A)
size(b)

%% Solve the system using least-squares solve
size(A)
size(b)
x = A\b;
g = x(1:n);
lE = x(n+1:size(x,1));
end