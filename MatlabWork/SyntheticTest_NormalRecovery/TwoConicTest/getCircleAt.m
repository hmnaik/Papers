function [circlePoints center surfaceNormal] = getCircleAt(rot, trans, baseConicPoints, worldOrigin)

alpha = rot(1); beta = rot(2); gamma = rot(3); 
tx = trans(1); ty =  trans(2); tz = trans(3); 

%% Rotation matrix for creating world circles on diffrent planes 
[Rx Ry Rz] = getRotationMatrix(alpha, beta, gamma);
circlePlaneRotationMatrix = Rx*Ry*Rz;
circlePlaneTranslationMatrix = [tx ty tz]';


% Rotate point plane and Center 
circlePoints = rotateCirclePoints( circlePlaneRotationMatrix , circlePlaneTranslationMatrix , baseConicPoints) ;
center = rotateCirclePoints(circlePlaneRotationMatrix , circlePlaneTranslationMatrix, worldOrigin);  
% We always start with basic conic in XY plane , Along Z axis 
surfaceNormal = circlePlaneRotationMatrix * [ 0 0 -1]'; % Changed 24.06.13 

% Conventional way 
% surfaceNormal = calculateSurfaceNormal(circlePoints(1:3,1)',circlePoints(1:3,3)',center(1:3,:)');


end