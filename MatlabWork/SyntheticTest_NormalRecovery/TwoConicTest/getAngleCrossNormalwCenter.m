function theta = getAngleCrossNormalwCenter(centerVecSet ,detectedNormals1,detectedNormals2)

n1 = detectedNormals1(:,1); 
n2 = detectedNormals1(:,2);

n3 = detectedNormals2(:,1); 
n4 = detectedNormals2(:,2);


vec13 = centerVecSet(:,1); % c1- c3 
vec14 = centerVecSet(:,2); % c1 - c4
vec23 = centerVecSet(:,3); % c2 -c3
vec24 = centerVecSet(:,4); % c2 - c4

normalCross13 = cross(n1,n3);
normalCross14 = cross(n1,n4);
normalCross23 = cross(n2,n3);
normalCross24 = cross(n2,n4);
 
theta(1) = calculateAngle( normalCross13 , vec13) ; 
theta(2) = calculateAngle( normalCross14 , vec14) ; 
theta(3) = calculateAngle( normalCross23 , vec23) ; 
theta(4) = calculateAngle( normalCross24 , vec24) ; 

end