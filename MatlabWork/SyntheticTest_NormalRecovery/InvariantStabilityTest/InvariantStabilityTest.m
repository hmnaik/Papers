%% Testing stability of Invariants

%% 2 Conic Test

%%
%close all;
clear all;
%clc;
%% Test setup Initialisation

%% Camera Roatation matrix
alphaCam = 0 ; betaCam = 0 ; gammaCam = 0;
xTransCam = 0 ; yTransCam = 0 ; zTransCam = 0;
%%

%% Rotation and Translation angles for coordinate axis
xTransWorldPlane = 0.0 ; yTransWorldPlane = 0.0 ; zTransWorldPlane = 0.0;
alphaPlane = 0 ; betaPlane = 0; gammaPlane = 0;
%%

%% Debug Oarameters
drawImages = 0;  % To draw images or not
noiseFactor = 0.3;
angleMatchingThreshold = 5;
distMatchingThreshold = 10;
noOfIterations = 1000;
minCameraDistance = 1200;
maxCameraDistance = 2000;
markerRadius =  2.5 ; % in Meters : Rad is in mm e.g. 10mm is 0.010
fileName = 'InvarianStabilityTest_5mm_1200_2000mm_3Noise.txt'; 
conicRotationRange = 10:10:90;
conicDistRange = 10:10:160;

% Camera Parameters 
minXCameraTranlation = -100;
maxXCameraTranslation = 100;
minYCameraTranslation = -100;
maxYCameraTranslation = 100;
minRotationRange = -65;
maxRotationRange = 65;

%%

%% Camera and Image Parameters : Real Calibration Data Used
K = [3617 0 1273 ; 0 3617 934; 0 0 1];
imageWidth = 2560 ;  % K(1,3)*2 ; % 2560 x 1920
imageHeight = 1920 ; % K(2,3)*2 ;
%%

%% World data for Object circles
worldOrigin = [ 0 0 0 1]';
%%



%% Create Points
baseConicPoints = createConic(worldOrigin,markerRadius,100);
conicWorldMatrix = [1/markerRadius^2 0 0 ; 0 1/markerRadius^2 0 ; 0 0 -1] ;
%%



matchingResults = zeros(size(conicRotationRange,2),size(conicDistRange,2));

distanceMatchingResults = zeros(size(conicRotationRange,2),size(conicDistRange,2));
angleMatchingResults = zeros(size(conicRotationRange,2),size(conicDistRange,2));

failedExperiment = zeros(size(conicRotationRange,2),size(conicDistRange,2));

anglesPrepared = 0;

for conicRotationIterator = 1:size(conicRotationRange,2)
    
    for conicDistIterator = 1:size(conicDistRange,2)
        failedIteration = 0;
        iterator = 0;
        %for iterator = 1 : noOfIterations
        while iterator < noOfIterations;
            
            iterator = iterator +1 ;
            %% getCircleAt : [alpha beta gamma],[Tx Ty Tz],conicPoints , Origin
            [circlePoints(:,:,1) center(:,:,1) surfaceNormal(:,:,1)] = getCircleAt([conicRotationRange(conicRotationIterator) 0 0],[conicDistRange(conicDistIterator) 0 0],baseConicPoints,worldOrigin);
            [circlePoints(:,:,2) center(:,:,2) surfaceNormal(:,:,2)] = getCircleAt([0 0 0],[0 0 0],baseConicPoints,worldOrigin);
            
            
            %% Invariants : Distance Between Centers And Angle Between Surface
            gtDistCenters = calculateDistance(center(:,:,1) , center(:,:,2)) ;
            gtSurfaceAngle = calculateAngle(surfaceNormal(:,:,1),surfaceNormal(:,:,2));
            %%
            
            %% Visualisation
            if(drawImages)
                figure(1);
                hold on;
                for i = 1:size(circlePoints,3)
                    quiver3(center(1,:,i),center(2,:,i),center(3,:,i),surfaceNormal(1,:,i),surfaceNormal(2,:,i),surfaceNormal(3,:,i),3,'r');
                    plot3(circlePoints(1,:,i),circlePoints(2,:,i),circlePoints(3,:,i));
                    grid on ;
                    axis equal;
                end
                hold off;
            end
            %%
            %% Random Test Data Generator
            %if(anglesPrepared == 0)
            camAngles(:,iterator) = randi([minRotationRange maxRotationRange], 3 , 1 );
            alphaCam = camAngles(1,iterator);
            betaCam = camAngles(2,iterator);
            gammaCam = camAngles(3,iterator);
            
            camTrans(1,iterator) = randi([minXCameraTranlation maxXCameraTranslation], 1 , 1 );
            xTransCam = camTrans(1,iterator);
            camTrans(2,iterator) = randi([minYCameraTranslation maxYCameraTranslation], 1 , 1 );
            yTransCam = camTrans(2,iterator);
            camTrans(3,iterator) = randi([minCameraDistance maxCameraDistance], 1 , 1 );
            zTransCam = camTrans(3,iterator);
            % end
     
            
            %% Fixed Cam Calculator
              alphaCam = 0 ; betaCam = 3; gammaCam = 11 ;
              xTransCam = 58; yTransCam=53; zTransCam = 2058;
            
%               alphaCam = 61 ; betaCam = 69; gammaCam = 32 ;
%               xTransCam = 58; yTransCam=53; zTransCam = 958;
            %%
            
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
                
                if(imagePoints(1) == 0)
                    break;
                end
                %% Add Noise
                n = size(imagePoints,2);
                noise = randn(1,n)*noiseFactor;
                imagePoints(1,:) = imagePoints(1,:) + noise ;
                imagePoints(2,:) = imagePoints(2,:) + noise ;
                
                
                %% Fit Ellipse and Get Conic Matrix
                [Ci fitParam] = createConicMatrix(imagePoints, drawImages );
                val2 = checkConicMatrix(Ci, imagePoints);
                
                if(fitParam(1) < 7 && fitParam(2) < 7)
                    imagePoints = 0; 
                    break;
                end
                
                %% Calculate the parameters Normals and center of backprojected circle
                [n1 n2 center1 center2 measuredRadius] = calculateNormals(Ci,markerRadius,K);
                
                %% Saving all data
                circlePointsImage(:,:,i) = imagePoints; % With Noise
                ellipseParam(:,:,i) = fitParam;
                conicMatrixImage(:,:,i) = Ci;
                detectedNormals(:,1,i) = n1 ;detectedNormals(:,2,i) = n2 ;
                detectedCenters(:,1,i) = center1 ; detectedCenters(:,2,i) = center2 ;
                calculatedRadius(:,:,i) = measuredRadius;
                
            end
            if(imagePoints(1) == 0 )
                % failedIteration = failedIteration+1;
                iterator = iterator - 1 ;
                continue;
            end
            
            %% Invariants
            
            %% Invariant 1 : Angle between surface ( For 2 conic we get 4 angles : 2 are likely to be almost equal)
            surfaceAngles = getSurfaceAngles(detectedNormals(:,:,1),detectedNormals(:,:,2));
            
            %% Invariant 2 : Distance to Radius ratio (For 2 conic we get 4 distances )
            [centerVecSet distSet] = getDistance(detectedCenters(:,:,1),detectedCenters(:,:,2));
            
            % Print Data
            stdDivDistances(iterator) = sqrt ( sum( (distSet - gtDistCenters).^2 ) ./ 4 );
            
            
            %angle1(iterator) = calculateAngle(detectedNormals(:,1,1),detectedNormals(:,2,1) );
            %angle2(iterator) = calculateAngle(detectedNormals(:,1,2),detectedNormals(:,2,2) );
            
            [ n1Key n2Key ] = solveNormalAmbiguity(gtSurfaceAngle,surfaceAngles);
            
            estimatedNormal1 = detectedNormals(:,n1Key,1);
            estimatedNormal2 = detectedNormals(:,n2Key,2);
            
            estimatedCenter1 = detectedCenters(:,n1Key,1);
            estimatedCenter2 = detectedCenters(:,n2Key,2);
            
            [descriptorMatchingSuccess(iterator) distanceMatchingSuccess(iterator) angleMatchingSuccess(iterator)] ...
                = matchDescriptor(gtSurfaceAngle,gtDistCenters,surfaceAngles,distSet,angleMatchingThreshold,distMatchingThreshold);
            
            
            normalSuccess(iterator) = validateNormalEstimation(projSN1,projSN2,estimatedNormal1,estimatedNormal2);
            centerSuccess(iterator) = validateCenterEstimation(projectedCenter1,projectedCenter2,estimatedCenter1,estimatedCenter2);
        
%             if(centerSuccess(iterator) == 0 && distanceMatchingSuccess(iterator) == 1)
%                 gtDistCenters
%                 distSet
%                 abs(projectedCenter1) - abs(estimatedCenter1)
%                 abs(projectedCenter2) - abs(estimatedCenter2)
%                 
%                 
%             end
            
        end
      
        if ( iterator == noOfIterations)
            
            anglesPrepared = 1;
            
            positiveDescriptorMatch = sum(descriptorMatchingSuccess);
            positiveDescriptorMatch = positiveDescriptorMatch / noOfIterations * 100; 
            
            distComponantMatch = sum(distanceMatchingSuccess);
            distComponantMatch = distComponantMatch / noOfIterations * 100; 
            
            angleComponantMatch = sum(angleMatchingSuccess);
            angleComponantMatch  = angleComponantMatch  / noOfIterations * 100; 
            
            positiveN = sum(normalSuccess);
            positiveC = sum(centerSuccess);
            combineResult = normalSuccess & centerSuccess;
            combineSuccess = sum(combineResult) ;
            
            maxDiv = max(stdDivDistances);
            minDiv = min(stdDivDistances);
            
        end
        
        matchingResults(conicRotationIterator,conicDistIterator) = positiveDescriptorMatch;
        angleMatchingResults (conicRotationIterator,conicDistIterator) = angleComponantMatch;
        distanceMatchingResults(conicRotationIterator,conicDistIterator) = distComponantMatch;
        
        
        failedExperiment(conicRotationIterator,conicDistIterator) = failedIteration;
        %         if( exist('InvarianStabilityTest_05_10_13.txt','file') )
        %             fileID = fopen('InvarianStabilityTest_05_10_13.txt','A');
        %             fprintf(fileID,'\n New Data : \r\n');
        %         else
        %             fileID = fopen('InvarianStabilityTest_05_10_13.txt','w');
        %
        %         end
        %
        %         fprintf(fileID,'\n No of Experiments : %4f \r ',noOfIterations);
        %         fprintf(fileID,'\n Failed of Experiments : %4f \r ',failedIteration);
        %         fprintf(fileID,'\n Marker Radius : %4f \r ',markerRadius);
        %         fprintf(fileID,'\n Marker Descriptor : Dc : %4f , Theta = %4f \r\n',gtDistCenters,gtSurfaceAngle);
        %         fprintf(fileID,'\n Noise Factor : %4f \r ',noiseFactor);
        %         fprintf(fileID,'\n Angle Range : %4f to %4f \r\n', minRotationRange , maxRotationRange );
        %         fprintf(fileID,'\n Translation Range x : %4f to %4f \r', minXCameraTranlation, +maxXCameraTranslation);
        %         fprintf(fileID,'\n Translation Range Y : %4f to %4f \r', minYCameraTranslation, +maxYCameraTranslation);
        %         fprintf(fileID,'\n Translation Range z : %4f to %4f \r',minCameraDistance,maxCameraDistance);
        %
        %         fprintf(fileID,'\n Descriptor Matching Results \r');
        %         fprintf(fileID,'Matching success : %4f \r',positiveDescriptorMatch);
        %
        %         fprintf(fileID,'\n Positive Normal Results \r');
        %         fprintf(fileID,'Normal Success : %4f \r',positiveN);
        %
        %         fprintf(fileID,'\n Positive Center Results \r');
        %         fprintf(fileID,'Center Success : %4f \r',positiveC);
        %
        %         fprintf(fileID,'\n Positive Combined Results \r');
        %         fprintf(fileID,'Both Success : %4f \r',combineSuccess);
        %
        %         fclose(fileID);
    end
    
end
h = figure(1);
surf(conicDistRange,conicRotationRange,matchingResults);
xlabel(' distanceRange (mm) ');ylabel(' RotationRange (degree) ');zlabel(' Matching Success');
saveas(h,'descriptorMatchingPattern.fig');
axis tight;

h = figure(2);
surf(conicDistRange,conicRotationRange,angleMatchingResults);
xlabel(' distanceRange (mm) ');ylabel(' RotationRange (degree) ');zlabel(' Theta matching success');
saveas(h,'angleMatchingPattern.fig');
axis tight;

h = figure(3);
surf(conicDistRange,conicRotationRange,distanceMatchingResults);
xlabel(' distanceRange (mm) ');ylabel(' RotationRange (degree) ');zlabel(' dc matching success');
saveas(h,'distanceMatchingPattern.fig');
axis tight;

h = figure(4);
surf(conicDistRange,conicRotationRange,failedExperiment);
xlabel(' distanceRange (mm) ');ylabel(' RotationRange (degree) ');zlabel(' Failure 1000');
axis tight;

fileID = fopen(fileName,'w');

fprintf(fileID,'\n No of Experiments : %4f \r ',noOfIterations);
fprintf(fileID,'\n Marker Radius : %4f \r ',markerRadius);
fprintf(fileID,'\n Noise Factor : %4f \r ',noiseFactor);
fprintf(fileID, '\n Angle matching threshold : %4f , Distance Matching Threshold %4f \r', angleMatchingThreshold,distMatchingThreshold);
fprintf(fileID, '\n Conic Rotation Range : %4f : %4f \r', min(conicRotationRange),max(conicRotationRange));
fprintf(fileID, '\n Conic Distance Range : %4f : %4f \r', min(conicDistRange),max(conicDistRange));
fprintf(fileID,'\n Angle Range : %4f to %4f \r\n', minRotationRange , maxRotationRange );
fprintf(fileID,'\n Translation Range X - Y - Z : \n x : %4f to %4f \n y : %4f to %4f \n z : %4f to %4f  \r', ...
    minXCameraTranlation, +maxXCameraTranslation , minYCameraTranslation, +maxYCameraTranslation ,minCameraDistance,maxCameraDistance );

fclose(fileID);