function theta = getAngleNormalwCenter(centerVecSet ,detectedNormals)

n1 = detectedNormals(:,1); 
n2 = detectedNormals(:,2);

vec1 = centerVecSet(:,1); 
vec2 = centerVecSet(:,2); 
vec3 = centerVecSet(:,3); 
vec4 = centerVecSet(:,4); 

theta(1) = calculateAngle( n1, vec1); 
theta(2) = calculateAngle( n1, vec2); 
theta(3) = calculateAngle( n2, vec3); 
theta(4) = calculateAngle( n2, vec4); 

end