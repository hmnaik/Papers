function [angle1 angle2 angle3] = getAngleBasedInvariants(vectorSet , normals )


% Theta 1 : Angle with Vc13 vs n1, Vc14 vs n1, Vc21 vs n1 , Vc22 vs n1
angle1 = getAngleNormalwCenter(vectorSet ,normals(:,:,1) ); 

% Theta 2 : Angle with Vc13 vs n2, Vc14 vs n2, Vc21 vs n2 , Vc22 vs n2
angle2 = getAngleNormalwCenter(vectorSet*-1 ,normals(:,:,2)); 

% Theta 3 : Angle with V12 vs (n1xn2)
angle3 = getAngleCrossNormalwCenter(vectorSet ,normals(:,:,1),normals(:,:,2));


end