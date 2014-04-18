function [descriptorSuccess distMatched angleMatched] = matchDescriptor(gtSurfaceAngle,gtDistCenters,surfaceAngles,distSet,angleMatchingThreshold,distMatchingThreshold)

avgDist = sum(distSet)/4;
distDiff = abs(gtDistCenters - avgDist);
descriptorSuccess = 0; 
distMatched = 0; 
angleMatched = 0; 

if( distDiff < distMatchingThreshold )
    
    % angleIndex = 0;
    % minDiff = 5;
    distMatched = 1; 
    for i = 1:size(surfaceAngles,2)
        
        angleDiff = abs(gtSurfaceAngle - surfaceAngles(i)) ;
        if( angleDiff < angleMatchingThreshold)
            angleMatched = 1;
        end
        
    end

end

if ( distMatched && angleMatched)
    
    descriptorSuccess = 1; 

end