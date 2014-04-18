
%% Gives angles between the vectors 
%% Task is to answer with all possible ambiguity 

function angles = getSurfaceAngles(normalSet1,normalSet2)

n1 = normalSet1(:,1); 
n2 = normalSet1(:,2); 
n3 = normalSet2(:,1); 
n4 = normalSet2(:,2); 

angle11 = calculateAngle(n1,n3); 
angle12 = calculateAngle(n1,n4); 
angle21 = calculateAngle(n2,n3); 
angle22 = calculateAngle(n2,n4);

angles = [angle11 angle12 angle21 angle22]; 

end