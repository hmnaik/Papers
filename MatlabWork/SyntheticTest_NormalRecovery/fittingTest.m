
%% Test is to check how fitting works with the projection.
%% Compare direct projection of conic matrix vs matrix made by fitting 
%% ellipse to projected points. 

clc; 
close all;
clear all; 
%% Test setup Initialisation
% Rotation along : alpha : X , beta : Y , gamma : Z
% Rotation for the plane for ground truth. 
alpha = 0 ; beta = 0 ; gamma = 0; 
% In meters
xTrans = 0.0 ; yTrans = 0.0 ; zTrans = 0.0;
% Rotation and Translation angles for coordinate axis
xTransWorldPlane = 0.0 ; yTransWorldPlane = 0.0 ; zTransWorldPlane = 0.0;

drawImages = 1;  % To draw images of not
% Guessed intrinsic matrix
K = [1473 0 1200 ; 0 1474 800; 0 0 1];
 
imageWidth = K(1,3)*2 ;
imageHeight = K(2,3)*2 ;


% Circle related data
centerW = [ 0 0 0 1]';
markerRadius =  15 ; % in Meters : Rad is in mm e.g. 10mm is 0.010

angleRange = 90; 
%angleRange = 0:10:45; 
angleSize = size(angleRange,2);
angleIterator = 1;

distRange = 1000;
%distRange = 1:0.5:2;
distSize = size(distRange,2);
distanceIterator = 1;



%% Create Points
baseConicPoints = createConic(centerW,markerRadius);

%% World conic matrix from Geometric Info 
Cw = [1/markerRadius^2 0 0 ; 0 1/markerRadius^2 0 ; 0 0 -1] ; 
%% Fit the conic based on Geometric info 
fitCw = createConicMatrix(baseConicPoints); 



% 1m = 1000 mm 
for distanceIterator = 1:1:distSize
    
    for angleIterator = 1:1:angleSize
        
        alpha = angleRange(angleIterator);
        Zdistance = distRange (distanceIterator); 
        %% Tranformation data
        
        [Rx Ry Rz] = getRotationMatrix(alpha, beta, gamma);
        T = [ xTrans yTrans zTrans+Zdistance]';
        
        
        Rt = createRotationMatrix(alpha,beta,gamma,T); 
        H = K*Rt;        
        Cwi = inv(H)'*Cw*inv(H);
        
        fprintf('Cwi = %1.10e \n ',Cwi ); 
%         fprintf('\n ');
%         fprintf('Cwix = %1.10e \n',Cwix );
%         
        %Normalize 
        Cwi = Cwi ./ Cwi(3,3) ;

        %% Rotate Points and create world points
        circlePlaneRotationMatrix = Rx*Ry*Rz;
        
        circlePlaneTranslationMatrix = [xTransWorldPlane yTransWorldPlane zTransWorldPlane]';
        
        circlePoints = rotateCirclePoints( circlePlaneRotationMatrix , circlePlaneTranslationMatrix , baseConicPoints) ;
        
        center = rotateCirclePoints(circlePlaneRotationMatrix , circlePlaneTranslationMatrix, centerW);
        
        surfaceNormal = calculateSurfaceNormal(circlePoints(1:3,1)',circlePoints(1:3,2)',center(1:3,:)');
        
        if(drawImages)
            figure; hold on
            quiver3(center(1),center(2),center(3),surfaceNormal(1),surfaceNormal(2),surfaceNormal(3),0.1);
            plot3(circlePoints(1,:),circlePoints(2,:),circlePoints(3,:),'ro'); 
            grid on ; axis auto; hold off
        end
        
        %Not required as such but good for verification
        % Cw = createConicMatrix(baseConicPoints);
        
        %% Create image related data
        % At place of eye to move the camera we can always provide relevant matrix i.e. Rx*Ry*Rz or Ry*Ry*Rz in any order
        P = createProjectionMatrix(K, eye(3) , T );
        
        circlePointsImage = createImagePoints(P, circlePoints, imageWidth, imageHeight , drawImages);
        circlePointsImage;
        Ci = createConicMatrix(circlePointsImage);
        
        %[ellipse_t Matrix] = fit_ellipse( circlePointsImage(1,:), circlePointsImage(2,:)); 
        % val1 = checkConicMatrix(Cwi, circlePointsImage);
        % val2 = checkConicMatrix(Ci, circlePointsImage);
        
        
        fprintf('Ci = %1.10e \n',Ci );
        fprintf('Cwi = %1.10e \n',Cwi );
 
        
    end
    

end

