function [e_xyz, e_rgb] = envmap2Dto3D(E)
    e_xyz = [];
    e_rgb = [];
    [width,height,~] = size(E);
    for u = 1:width
        u_prime = 2*u/(width-1);
        for v = 1:height
            v_prime = 2*v/(height-1);
            r = sqrt(u_prime^2 + v_prime^2);
            if r <= 1
                theta = atan2(u_prime,v_prime);
                phi = 2*asin(r);
                x = sin(phi) .* sin(theta);
                y = sin(phi) .* cos(theta);
                z = -cos(phi);
                xyz = [x,y,z];
                rgb = [E(u,v,1),E(u,v,2),E(u,v,3)];
                e_xyz = [e_xyz;xyz];
                e_rgb = [e_rgb;rgb];
            end
        end
    end
end

%[e_xyz,e_rgb] = envmap2Dto3D(E);
%ptcloud = pointCloud(e_xyz,'Color',e_rgb)
%pcshow(ptcloud)

%envmap.vertices = e_xyz;
%envmap.colors = e_rgb;