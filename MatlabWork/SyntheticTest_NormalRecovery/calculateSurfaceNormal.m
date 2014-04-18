function surfaceNormal = calculateSurfaceNormal(pt1, pt2, center)


%% Create Surface normals for the original point 
surfaceNormal = cross( (pt1 - center ),(pt2 - center )); 
surfaceNormal = surfaceNormal / norm(surfaceNormal);
if(surfaceNormal(3) < 0 )
    error('Surface of world circle is facing negative Z, circle cant be visible');
end



end