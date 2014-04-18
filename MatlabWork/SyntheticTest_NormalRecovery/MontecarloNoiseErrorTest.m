
close all;
clear all;
clc; 
%% Test setup Initialisation
% Rotation along : alpha : X , beta : Y , gamma : Z
% Rotation for the plane for ground truth.
alpha = 0 ; beta = 0 ; gamma = 0;
% In meters
xTrans = 0 ; yTrans = 0 ; zTrans = 0;
% Rotation and Translation angles for coordinate axis
xTransWorldPlane = 0.0 ; yTransWorldPlane = 0.0 ; zTransWorldPlane = 0.0;

drawImages = 0;  % To draw images of not
% Guessed intrinsic matrix
K = [1473 0 1200 ; 0 1474 800; 0 0 1];
imageWidth = K(1,3)*2 ;
imageHeight = K(2,3)*2 ;


% Circle related data
centerW = [ 0 0 0 1]';
markerRadius =  2.5 ; % Rad is in mm e.g. 10mm is 0.010 in Meters 

testing = 0 ;
if( testing )
    distRange = 1000;
    angleRange = 50;
    noiseFactorRange = 0.1; 
else
    angleRange = 0:1:70;
    distRange = 500:100:2000;
    noiseFactorRange = 0.1:0.05:0.6; 
end

noiseSize = size(noiseFactorRange,2);
noiseIterator = 1; 

angleSize = size(angleRange,2);
angleIterator = 1;

distSize = size(distRange,2);
distanceIterator = 1;

conicImageWidth = zeros(angleSize,distSize);
conicImageHeight = zeros(angleSize,distSize);
angleAndError1 = zeros(angleSize,distSize,noiseSize);
angleAndError2 = zeros(angleSize,distSize,noiseSize);

normalError1 = zeros(angleSize,distSize,noiseSize);
normalError2 = zeros(angleSize,distSize,noiseSize);

diffErrorMean = zeros(angleSize,distSize,noiseSize);
errorMean = zeros(1,noiseSize);
errorMeanMatrix = zeros(angleSize,distSize);
samplePoints = 100; 

%% Create Points
baseConicPoints = createConic(centerW,markerRadius,samplePoints);


Cw = [1/markerRadius^2 0 0 ; 0 1/markerRadius^2 0 ; 0 0 -1] ;


noiseFactor = 0.3; 
noiseSize = 100; 

fprintf('\n Noise -> %d  , Marker Radius -> %d \n',noiseFactor,markerRadius); 


for noiseIterator = 1 : 1 : noiseSize
    
    %noiseFactor = noiseFactorRange(noiseIterator);
    n = samplePoints;    
    noise = randn(1,samplePoints) ;
    imageNoise = noise.* noiseFactor;
    divNoise(1,noiseIterator) = std(imageNoise);
    %fprintf('\n Std Div %1.5e : Min -> %1.5e , Max -> %1.5e \n',divNoise(noiseIterator),min(noise),max(noise)); 
    
    for distanceIterator = 1:1:distSize
        
        for angleIterator = 1:1:angleSize
            
            alpha = angleRange(angleIterator);
            Zdistance = distRange (distanceIterator);
            %% Tranformation data
            [Rx Ry Rz] = getRotationMatrix(alpha, beta, gamma);
            T = [ xTrans yTrans zTrans+Zdistance]';
            
            % Create rotation Matrix for Direct conic matrix projection
%             Rt = createRotationMatrix(alpha,beta,gamma,T);
%             H = K*Rt;
            % Projected conic : x_ = H*x and x'Cx = 0 then x_'C_x_ = 0 too
            % Hence C_ = inv(H')*C*inv(H) as C = H'C_H
%             Cwi = inv(H)'*Cw*inv(H);
%             Cwi = Cwi ./ Cwi(3,3) ;
            
            %% Rotate Points and create world points
            
            % Rotation M atrix
            circlePlaneRotationMatrix = Rx*Ry*Rz;
            
            % Translation Matrix
            circlePlaneTranslationMatrix = [xTransWorldPlane yTransWorldPlane zTransWorldPlane]';
            
            % Rotate points 
            circlePoints = rotateCirclePoints( circlePlaneRotationMatrix , circlePlaneTranslationMatrix , baseConicPoints) ;

            % Rotate center coordinates 
            center = rotateCirclePoints(circlePlaneRotationMatrix , circlePlaneTranslationMatrix, centerW);
            
            %% If we don't rotate the points on the plane 
%              circlePoints = baseConicPoints;
%              center = centerW ;
             
            % Calculate current surface normal : Normal to the plane

            surfaceNormal = circlePlaneRotationMatrix * [ 0 0 -1]'; 
            
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
            P = createProjectionMatrix(K, eye(3) , T );
            centerCamCoordinate = [ eye(3)  T]* center ; 
            %P = createProjectionMatrix(K, circlePlaneRotationMatrix , T );
            circlePointsImage = createImagePoints(P, circlePoints, imageWidth, imageHeight , drawImages);
            % val1 = checkConicMatrix(Cwi, circlePointsImage); % Checking x'Cx = 0
            
            circlePointsImage(1,:) = circlePointsImage(1,:) + imageNoise ;
            circlePointsImage(2,:) = circlePointsImage(2,:) + imageNoise ;
            
            [Ci fitParam] = createConicMatrix(circlePointsImage, drawImages );
            %val2 = checkConicMatrix(Ci, circlePointsImage);
            
            
            if(~isreal(fitParam))
                error('\n Parameters are Imaginary');
            end
            
            
            conicImageWidth(angleIterator,distanceIterator) = fitParam(1)*2;
            conicImageHeight(angleIterator,distanceIterator) = fitParam(2)*2;
            
            %fprintf('Ci = %1.10e \n',Ci );
            %fprintf('Cwi = %1.10e \n',Cwi );
            
            %% Calculate the parameters Normals and center of backprojected circle
            [n1 n2 center1 center2 measuredRadius] = calculateNormals(Ci,markerRadius,K);
            
            %% Print Data
            calculatedRadius(angleIterator,distanceIterator) = measuredRadius;
            n1;
            n2;
            worldCircleCenter = T + circlePlaneTranslationMatrix ;
            % Center should have a negative Z , but center we get is as per LH
            % coordinate system where camera Z is going towards the object and not away
            % from it. We leave it like this as its simple to compare with the existing
            % translation. Also we need magnitude at the end so dont really need to
            % know signs as long as we keep good with only one frame
            
            
            angleN1SN = acos( dot(surfaceNormal,n1)/ (norm(surfaceNormal)*norm(n1) ) )*180/pi;
            angleN2SN = acos( dot(surfaceNormal,n2)/ (norm(surfaceNormal)*norm(n2) ) )*180/pi;
            angleN1toN2(angleIterator,distanceIterator,noiseIterator) = calculateAngle(n1,n2);
            distC1toC2 (angleIterator,distanceIterator,noiseIterator) = calculateDistance(center1,center2);
            
            center1;
%             if(center1(1) < 0)
%                 center1(1) = center1(1)*-1;
%             end
%             if(center1(3) < 0)
%                 center1(3) = center1(3)*-1;
%             end
%             if(center1(2) < 0)
%                 center1(2) = center1(2)*-1;
%             end
            % Error from GT
            centerError1 = sqrt( sum( (center1- worldCircleCenter).^2 ) );
            center2;
%             if(center2(1) < 0)
%                 center2(1) = center2(1)*-1;
%             end
%             if(center2(3) < 0)
%                 center2(3) = center2(3)*-1;
%             end
%             if(center2(2) < 0)
%                 center2(2) = center2(2)*-1;
%             end
            centerError2 = sqrt( sum( (center2- worldCircleCenter).^2 ) );
            
            if(centerError1 < centerError2)
                angleAndError1(angleIterator,distanceIterator,noiseIterator) = centerError1;
                angleAndError2(angleIterator,distanceIterator,noiseIterator) = centerError2;
            else
                angleAndError1(angleIterator,distanceIterator,noiseIterator) = centerError2;
                angleAndError2(angleIterator,distanceIterator,noiseIterator) = centerError1;
            end
            
            if( angleN1SN < angleN2SN )
                normalError1(angleIterator,distanceIterator,noiseIterator)  = angleN1SN;
                normalError2(angleIterator,distanceIterator,noiseIterator)  = angleN2SN;
            else
                normalError1(angleIterator,distanceIterator,noiseIterator)  = angleN2SN;
                normalError2(angleIterator,distanceIterator,noiseIterator)  = angleN1SN;
            end
            
            
        end        
    end
end

%% Std Div Model 
% Each error is depicted in terms of geometric distance between 
% Actual position X and calculated position X' : Error = Error(X-X')
% Ideal Error Value is IdealErr = 0. 
% Here below we measure how much each error varies from its ideal value

[stdDivErrorMatrix meanError1] = calculateStdDiv(angleAndError1);
[stdDivError2Matrix meanError2] = calculateStdDiv(angleAndError2);
[stdDivNormalErrorMatrix1 meanNormalError1] = calculateStdDiv(normalError1);
[stdDivNormalErrorMatrix2 meanNormalError2] = calculateStdDiv(normalError2);
[stdDivNormalAngles meanNormalAngles] = calculateStdDiv(angleN1toN2);
[stdDivCenterDist meanDistCenters] = calculateStdDiv(distC1toC2);

h = figure(1);
%subplot(1,2,1);
surf(distRange,angleRange,stdDivErrorMatrix);
xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' Center Estimation Error (stdDiv - mm)');
%subplot(1,2,2)
% surf(distRange,angleRange,meanError1);
% xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' Mean error (mm)');
axis tight;
saveas(h,'centerEstimationError1.fig');

h = figure(2);
% subplot(1,2,1)
surf(distRange,angleRange,stdDivError2Matrix);
xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' Center Estimation Error (stdDiv - mm)');
% subplot(1,2,2)
% surf(distRange,angleRange,meanError2);
% xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel(' Mean error (mm)');
axis tight;
saveas(h,'centerEstimationError2.fig');

h=figure(3);
%subplot(1,2,1);
surf(distRange,angleRange,stdDivNormalErrorMatrix1);
xlabel('distance (mm)');ylabel('Angle (degree)');zlabel('Normal Estimation Error 1(stdDiv - Degree)');
% subplot(1,2,2);
% surf(distRange,angleRange,meanNormalError1);
% xlabel('distance (mm)');ylabel('Angle (degree)');zlabel('Mean Normal Error 1(Deg)');
axis tight;
saveas(h,'NormalRecoveryError.fig');

h = figure(4);
% subplot(1,2,1);
surf(distRange,angleRange,stdDivNormalAngles);
xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel('Angle between Normals (stdDiv - Degree)');
% subplot(1,2,2)
% surf(distRange,angleRange,meanNormalAngles);
% xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel('Mean angle (Deg)');
axis tight;
saveas(h,'AngleBetweenNormals.fig');

h = figure(5);
% subplot(1,2,1)
surf(distRange,angleRange,stdDivCenterDist);
xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel('Recovered Centre Separation C1-C2 (stdDiv - mm)');
% subplot(1,2,2)
% surf(distRange,angleRange,meanDistCenters);
% xlabel(' distance (mm) ');ylabel(' Angle (degree) ');zlabel('Mean distance C1-C2(mm)');
axis tight;
saveas(h,'DistanceBetweenCenters.fig');

