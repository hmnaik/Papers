%% 2 Conic Test 

%% 
close all;
clear all; 
%clc;
%% Test setup Initialisation

%% Camera Roatation matrix  
alphaCam = 0 ; betaCam = 0 ; gammaCam = 0; 
xTransCam = 0 ; yTransCam = 0 ; zTransCam = 1300;
%%

%% Rotation and Translation angles for coordinate axis
xTransWorldPlane = 0.0 ; yTransWorldPlane = 0.0 ; zTransWorldPlane = 0.0;
alphaPlane = 0 ; betaPlane = 0; gammaPlane = 0; 
%%

%% Debug Oarameters 
drawImages = 1;  % To draw images of not
noiseFactor = 0.5; 
%%

%% Camera and Image Parameters 
K = [3617 0 1273 ; 0 3617 934; 0 0 1];
imageWidth = K(1,3)*2 ;
imageHeight = K(2,3)*2 ;


Kconic = [3317 0 1273 ; 0 3317 934; 0 0 1];
%%

%% World data for Object circles 
worldOrigin = [ 0 0 0 1]';
markerRadius =  10 ; % in Meters : Rad is in mm e.g. 10mm is 0.010
%%

%% Create Points 
baseConicPoints = createConic(worldOrigin,markerRadius,100);
conicWorldMatrix = [1/markerRadius^2 0 0 ; 0 1/markerRadius^2 0 ; 0 0 -1] ; 
%%      

%% getCircleAt : [alpha beta gamma],[Tx Ty Tz],conicPoints , Origin
[circlePoints(:,:,1) center(:,:,1) surfaceNormal(:,:,1)] = getCircleAt([45 2 3],[15 -10 25],baseConicPoints,worldOrigin); 
[circlePoints(:,:,2) center(:,:,2) surfaceNormal(:,:,2)] = getCircleAt([30 -45 0],[-41 200 15],baseConicPoints,worldOrigin); 


distCenters = calculateDistance(center(:,:,1) , center(:,:,2)) ;
%% Invariants 
%% Invariant 1 : Angle between surfaces 
gtSurfaceAngle = calculateAngle(surfaceNormal(:,:,1),surfaceNormal(:,:,2));
%% Invariant 2 : Ration of radius to distance 
gtRatio = markerRadius/ distCenters ; 
%% Invariant 3 : 
% 3.1 : Distance between two cricle centers (scaled)
distCenters ; % = calculateDistance(center(:,:,1) , center(:,:,2)) ;
% 3.2 : Theta1 = Angle between vector joining circle centers and SN of 1st
% circle
gtTheta1 = calculateAngle ( surfaceNormal(:,:,1) , (center(1:3,:,2) - center(1:3,:,1)) ); 
% 3.3 : Theta2 = Angle between vector joining circle centers and SN of 2nd
% circle
gtTheta2 = calculateAngle ( surfaceNormal(:,:,2) , (center(1:3,:,1) - center(1:3,:,2) ) ); 
% 3.4 : Theta3 = Angle between vector joining two centers and cross of two
% normals 
crossVector = cross(surfaceNormal(:,:,1),surfaceNormal(:,:,2));
gtTheta3 = calculateAngle ( crossVector , ( center(1:3,:,1) - center(1:3,:,2) ) ); 

if(drawImages)
    figure(1);
      hold on;
%    axes();
    for i = 1:size(circlePoints,3)
  
    quiver3(center(1,:,i),center(2,:,i),center(3,:,i),surfaceNormal(1,:,i),surfaceNormal(2,:,i),surfaceNormal(3,:,i),3,'r');
    plot3(circlePoints(1,:,i),circlePoints(2,:,i),circlePoints(3,:,i));
    grid on ; 
    end
    hold off;
end

%% Camera Projection Matrix
[Rx Ry Rz] = getRotationMatrix(alphaCam, betaCam, gammaCam);
T = [ xTransCam yTransCam zTransCam]';
cameraRotationMatrix = Rx * Ry * Rz;

projSN1 = cameraRotationMatrix * surfaceNormal(:,:,1);
projSN2 = cameraRotationMatrix * surfaceNormal(:,:,2);

cameraTranslationMatrix = [ xTransCam yTransCam zTransCam]';
P = createProjectionMatrix(K, cameraRotationMatrix , cameraTranslationMatrix );


projectedCenter1 = [cameraRotationMatrix cameraTranslationMatrix] * center(:,:,1);
projectedCenter2 = [cameraRotationMatrix cameraTranslationMatrix] * center(:,:,2);

%% Project Image Points 
for i = 1:size(circlePoints,3)
    
    imagePoints = createImagePoints(P, circlePoints(:,:,i), imageWidth, imageHeight , drawImages);
    % val1 = checkConicMatrix(Cwi, circlePointsImage); % Checking x'Cx = 0
    
    %% Add Noise
    n = size(imagePoints,2);
    noise = randn(1,n)*noiseFactor;
%     if( noise ~= 0)
%         fprintf(' \n Noise is there ');
%     end
    imagePoints(1,:) = imagePoints(1,:) + noise ;
    imagePoints(2,:) = imagePoints(2,:) + noise ;
    
    
    %% Fit Ellipse and Get Conic Matrix
    [Ci fitParam] = createConicMatrix(imagePoints, drawImages );
    val2 = checkConicMatrix(Ci, imagePoints);
    
    
    %% Calculate the parameters Normals and center of backprojected circle
    [n1 n2 center1 center2 measuredRadius] = calculateNormals(Ci,markerRadius,K);
    
    %%% ### Note : Center might be in any octant, problem is that finfding
    %%% distance between centers which exist in different octant might
    %%% obviously come up with larger results 
    %%%
    
    %% Saving all data 
    circlePointsImage(:,:,i) = imagePoints; % With Noise 
    ellipseParam(:,:,i) = fitParam;
    conicMatrixImage(:,:,i) = Ci; 
    detectedNormals(:,1,i) = n1 ;detectedNormals(:,2,i) = n2 ; 
    detectedCenters(:,1,i) = center1 ; detectedCenters(:,2,i) = center2 ; 
    calculatedRadius(:,:,i) = measuredRadius;
    
end




%% Invariants 

%% Invariant 1 : Angle between surface ( For 2 conic we get 4 angles : 2 are likely to be almost equal) 

angles = getSurfaceAngles(detectedNormals(:,:,1),detectedNormals(:,:,2));  

%% Invariant 2 : Distance to Radius ratio (For 2 conic we get 4 distances ) 
[ centerVecSet distSet] = getDistance(detectedCenters(:,:,1),detectedCenters(:,:,2));  

gtRatio;
ratio1 = calculatedRadius(:,:,1)/distSet(1) ; 
ratio2 = calculatedRadius(:,:,1)/distSet(2); 
ratio3 = calculatedRadius(:,:,2)/distSet(3); 
ratio4 = calculatedRadius(:,:,2)/distSet(4); 

%% Angle between vector and the normals 
[theta1 theta2 theta3] = getAngleBasedInvariants(centerVecSet,detectedNormals);

% Print Data
distCenters; 

distSet;
stdDivDistances = sqrt ( sum( (distSet - distCenters).^2 ) ./ 4 ) 

gtSurfaceAngle
angles
%stdDivAngles = sqrt ( sum( (angles - gtSurfaceAngle).^2 ) ./ 4 ); 

projSN1
detectedNormals(:,:,1)

projSN2
detectedNormals(:,:,2)

projectedCenter1
detectedCenters(:,:,1)

projectedCenter2
detectedCenters(:,:,2)

% if( ~exist('Invariant.txt','file') )
%     fileID = fopen('Invariants.txt','A');
%     fprintf(fileID,'\n New Data : \r\n');
% else
%     fileID = fopen('Invariants.txt','w');
% 
% end
% 
% fprintf(fileID,'\n Inavriant 1 : Angle between normals:\r\n');
% fprintf(fileID,'Original Angle : %4f \r\n Measured:',gtSurfaceAngle);
% fprintf(fileID,'%4f ',angles);
% 
% fprintf(fileID,'\n Invariant 2.1 : \n (Dc) Distance Between Centers:\r\n');
% fprintf(fileID,'Original : %4f \r\n Measured:',distCenters);
% fprintf(fileID,'%4f ',distSet);
% 
% fprintf(fileID,'\n Invariant 2.2 : \n Theta 1 : Angle between 1st normal and vector joining center\r\n');
% fprintf(fileID,'Original : %4f \r\n Measured:',gtTheta1);
% fprintf(fileID,'%4f ',theta1);
% 
% fprintf(fileID,'\n Invariant 2.3 : \n Theta 2 : Angle between 2nd normal and vector joining center\r\n');
% fprintf(fileID,'Original : %4f \r\n Measured:',gtTheta2);
% fprintf(fileID,'%4f ',theta2);
% 
% fprintf(fileID,'\n Invariant 2.4 : \n Theta 3 : Angle between cross of two normals and vector joining center\r\n');
% fprintf(fileID,'Original : %4f \r\n Measured:',gtTheta3);
% fprintf(fileID,'%4f ',theta3);
% 
% fclose(fileID); 






