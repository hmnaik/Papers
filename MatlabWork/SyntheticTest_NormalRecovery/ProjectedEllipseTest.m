%% Test Setup : 
% Includes projecting ellises on image plane from world at different
% distance and axis angle , to test variation in output from ground truth.
% This script enables us to understand how the size of marker will behave
% in real world. 

%% Features : 
% -->Can add noise 
% -->Ellipse fitting can be seen
% -->Can compare fitting results with projecting world conic direcly on image
% plane


close all;
clear all; 
%% Test setup Initialisation
% Rotation along : alpha : X , beta : Y , gamma : Z
% Rotation for the plane for ground truth. 
alpha = 0 ; beta = 0 ; gamma = 0; 
% In meters
xTrans = 0 ; yTrans = 50 ; zTrans = 0;
% Rotation and Translation angles for coordinate axis
xTransWorldPlane = 0.0 ; yTransWorldPlane = 0.0 ; zTransWorldPlane = 0.0;

drawImages = 0;  % To draw images of not
% Guessed intrinsic matrix
K = [1473 0 1200 ; 0 1474 800; 0 0 1];
imageWidth = K(1,3)*2 ;
imageHeight = K(2,3)*2 ;


% Circle related data
centerW = [ 0 0 0 1]';
markerRadius =  15 ; % in Meters : Rad is in mm e.g. 10mm is 0.010

testing = 0 ; 
if( testing ) 
    distRange = 1500;
    angleRange = 53;
else
    angleRange = 5:2:80;
    distRange = 500:200:2000;
end

angleSize = size(angleRange,2);
angleIterator = 1;

distSize = size(distRange,2);
distanceIterator = 1;

conicImageWidth = zeros(size(angleRange,distSize));
conicImageHeight = zeros(size(angleRange,distSize));
angleAndError1 = zeros(size(angleRange,distSize));
angleAndError2 = zeros(size(angleRange,distSize));

%% Create Points
baseConicPoints = createConic(centerW,markerRadius,100);
noiseFactor = 0.3; 

Cw = [1/markerRadius^2 0 0 ; 0 1/markerRadius^2 0 ; 0 0 -1] ; 

% 1m = 1000 mm 
for distanceIterator = 1:1:distSize
    
    for angleIterator = 1:1:angleSize
        
        alpha = angleRange(angleIterator);
        Zdistance = distRange (distanceIterator); 
        %% Tranformation data        
        [Rx Ry Rz] = getRotationMatrix(alpha, beta, gamma);
        T = [ xTrans yTrans zTrans+Zdistance]';
        
        % Create rotation Matrix for Direct conic matrix projection  
        Rt = createRotationMatrix(alpha,beta,gamma,T); 
        H = K*Rt;
        % Projected conic : x_ = H*x and x'Cx = 0 then x_'C_x_ = 0 too 
        % Hence C_ = inv(H')*C*inv(H) as C = H'C_H
        Cwi = inv(H)'*Cw*inv(H); 
        Cwi = Cwi ./ Cwi(3,3) ;

        %% Rotate Points and create world points
        
        % Rotation M atrix 
        circlePlaneRotationMatrix = Rx*Ry*Rz;
        
        % Translation Matrix 
        circlePlaneTranslationMatrix = [xTransWorldPlane yTransWorldPlane zTransWorldPlane]';
%         
%         % Rotate points 
%         circlePoints = rotateCirclePoints( circlePlaneRotationMatrix , circlePlaneTranslationMatrix , baseConicPoints) ;
%         
%         % Rotate center coordinates 
%         center = rotateCirclePoints(circlePlaneRotationMatrix , circlePlaneTranslationMatrix, centerW);
        
        circlePoints = baseConicPoints;
        center = centerW ; 
        
        % Calculate current surface normal : Normal to the plane 
        surfaceNormal = calculateSurfaceNormal(circlePoints(1:3,1)',circlePoints(1:3,3)',center(1:3,:)');
        
        if(drawImages)
            figure(1);
            hold on; 
            quiver3(center(1),center(2),center(3),surfaceNormal(1),surfaceNormal(2),surfaceNormal(3),0.1);
            plot3(circlePoints(1,:),circlePoints(2,:),circlePoints(3,:));
            grid on ; hold off; 
        end
        
        %Not required as such but good for verification
        % Cw = createConicMatrix(baseConicPoints);
        
        %% Create image related data
        % At place of eye to move the camera we can always provide relevant matrix i.e. Rx*Ry*Rz or Ry*Ry*Rz in any order
        % Since point are already rotated, we dont have to rotate them
        % again
%         P = createProjectionMatrix(K, eye(3) , T );
         P = createProjectionMatrix(K, circlePlaneRotationMatrix , T );
        circlePointsImage = createImagePoints(P, circlePoints, imageWidth, imageHeight , drawImages);
        % val1 = checkConicMatrix(Cwi, circlePointsImage); % Checking x'Cx = 0
        
        n = size(circlePointsImage,2);
        noise = randn(1,n)*noiseFactor;
        
        circlePointsImage(1,:) = circlePointsImage(1,:) + noise ;
        circlePointsImage(2,:) = circlePointsImage(2,:) + noise ;       
        
        [Ci fitParam] = createConicMatrix(circlePointsImage, drawImages );
        val2 = checkConicMatrix(Ci, circlePointsImage);
        
        
        if(~isreal(fitParam))
            error('\n Parameters are Imaginary');
        end

        
        conicImageWidth(angleIterator,distanceIterator) = fitParam(1)*2; 
        conicImageHeight(angleIterator,distanceIterator) = fitParam(2)*2; 
        
        fprintf('Ci = %1.10e \n',Ci );
        fprintf('Cwi = %1.10e \n',Cwi );
        
        %% Calculate the parameters Normals and center of backprojected circle
        [n1 n2 center1 center2 measuredRadius] = calculateNormals(Ci,markerRadius,K);
        
        %% Print Data
        calculatedRadius(angleIterator,distanceIterator) = measuredRadius;
        n1;
        n2;
        worldCircleCenter = [T + circlePlaneTranslationMatrix] ;
        % Center should have a negative Z , but center we get is as per LH
        % coordinate system where camera Z is going towards the object and not away
        % from it. We leave it like this as its simple to compare with the existing
        % translation. Also we need magnitude at the end so dont really need to
        % know signs as long as we keep good with only one frame
        
        %     %  Not used as of now
        angle1(angleIterator,distanceIterator)  = acos( dot(center1,n1)/ (norm(center1)*norm(n1) ) )*180/pi;
        angle2(angleIterator,distanceIterator)  = acos( dot(center2,n2)/ (norm(center2)*norm(n2) ) )*180/pi;
        
%         cameraCenter = [ 0 0 0]; % Cam center in cam coordinate system 
%         dist1 = 
%         
        center1;
        if(center1(1) < 0)
            center1(1) = center1(1)*-1;
        end
        if(center1(3) < 0)
            center1(3) = center1(3)*-1;
        end
        if(center1(2) < 0)
            center1(2) = center1(2)*-1;
        end
        % Error from GT
        centerError1 = sqrt( sum( (center1- worldCircleCenter).^2 ) );
        center2;
        if(center2(1) < 0)
            center2(1) = center2(1)*-1;
        end
        if(center2(3) < 0)
            center2(3) = center2(3)*-1;
        end
        if(center2(2) < 0)
            center2(2) = center2(2)*-1;
        end
        centerError2 = sqrt( sum( (center2- worldCircleCenter).^2 ) );
            
        if(centerError1 < centerError2)
            angleAndError1(angleIterator,distanceIterator) =  centerError1 ;
            angleAndError2(angleIterator,distanceIterator) = centerError2 ;
        else
            angleAndError1(angleIterator,distanceIterator) =  centerError2 ;
            angleAndError2(angleIterator,distanceIterator) = centerError1 ;
        end             
    
        
    end
    
    
end


figure;
surf(distRange,angleRange,angleAndError1);
xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' Error (mm)');
axis tight;

figure;
surf(distRange,angleRange,angleAndError2);
xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' Error (mm)');
axis tight;

figure;
 surf(distRange,angleRange,calculatedRadius);
 xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' calculated radius ( pix )');
 axis tight;

% figure;
% surf(distRange,angleRange,angle1);
% xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' Angle(n-T) ( deg )');
% axis tight;
% 
% 
% figure;
% surf(distRange,angleRange,angle2);
% xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' Angle(n-T) ( deg )');
% axis tight;

figure;
surf(distRange,angleRange,conicImageHeight);
xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' Conic Height ( pix )');
axis tight;

figure;
surf(distRange,angleRange,conicImageWidth);
xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' conic width ( pix )');
axis tight;

% figure;
% plot(conicImageHeight(2,:),conicImageWidth(2,:));
% xlabel('Ellipse Height (pix)');ylabel('Ellipse Width (pix)');


%%


