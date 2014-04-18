function [ centerVec dist] = getDistance(detectedCenters1,detectedCenters2)

c1 = detectedCenters1(:,1);
c2 = detectedCenters1(:,2);
c3 = detectedCenters2(:,1);
c4 = detectedCenters2(:,2);

vec1 = c3 - c1; % Vec c1 To c3 
vec2 = c4 - c1; % Vec c1 To c4 
vec3 = c3 - c2; % Vec c2 To c3 
vec4 = c4 - c2; % Vec c2 To c4 

centerVec = [vec1 vec2 vec3 vec4 ]; 

distCenter11 = calculateDistance(c1,c3); 
distCenter12 = calculateDistance(c1,c4); 
distCenter21 = calculateDistance(c2,c3); 
distCenter22 = calculateDistance(c2,c4); 


dist = [distCenter11 distCenter12 distCenter21 distCenter22]; 

end