function [Saligned,Scrop] = alignSource( S,T,topleft,alignedSize )

% alignSource: aligns a source image S to a target image T to give
% an output Saligned
%
%       Saligned = alignSource( S,T )
%
% gives an alignedSource re-aligned to fit within the target. The
% source will be resized if it needs to be bigger or smaller. You
% mark the top-left and bottom-right corners of the source image
% in the target, and the code automatically re-aligns the source
% image to fit within a rectangle drawn from the top-left corner
% to the bottom-right corner.
%
%       Saligned = alignSource( S,T,topleft )
%
% assumes that the top-left corner of the source container
% is prespecified as [top-left-x,top-left-y]. Handy for 'moving'
% the source image with the video on the extra credit portion of
% Short Project 1.
%
%       Saligned = alignSource( S,T,topleft,alignedSize )
%
% also assumes that the size of the aligned image is pre-specified
% as [height, width] (also handy for KLT tracking)
%
%       [Saligned, Scrop] = alignSource( ... ) 
% returns the cropped (and resized) image.

S=im2double(S);
T=im2double(T);

warning off

figure; set(gcf,'windowstyle','docked');
fprintf('Crop source image LOOSELY\n');
Scrop = imcrop(S);

done = false;

while ~done
    
    imshow(T);
    if nargin<3
        title('Click location of top-left point of source');
        [x1,y1]=ginput(1);
        x1=round(x1);
        y1=round(y1);
    else
        x1=topleft(1);
        y1=topleft(2);
    end
    
    if nargin<4
        title('Click location of bottom-right point of source');
        [x2,y2]=ginput(1);
        x2=round(x2);
        y2=round(y2);
        
        ow = (x2-x1)+1;
        oh = (y2-y1)+1;
        
        iw = size(Scrop,2);
        ih = size(Scrop,1);
        
        owa = iw/ih*oh;
        if owa > ow
            oh = ih/iw*ow;
            oh = round(oh);
        end
        
        oha = ih/iw*ow;
        if oha > oh
            ow = iw/ih*oh;
            ow = round(ow);
        end
        
        Scrop = imresize( Scrop,[oh,ow] );
    else
        Scrop = imresize( Scrop,alignedSize );
    end
    
    Saligned = zeros(size(T));
    Saligned( y1-1+(1:size(Scrop,1)),x1-1+(1:size(Scrop,2)),: ) = Scrop;
    Vis = T;
    Vis( y1-1+(1:size(Scrop,1)),x1-1+(1:size(Scrop,2)),: ) = Scrop;
    
    if nargin<4
        imshow(Vis);
        s = input('Press "n" to change the alignment, "y" to keep it: ','s');
        done = s=='y' || s=='Y';
    else
        done = true;
    end    
end

warning on

end