function circlePoints = createConic( center , Radius, nPoints)

circlePoints = zeros (4, nPoints) ; 
Xc = center(1);
Yc = center(2);
Zc = center(3);

angleFac = 360 / size(circlePoints,2); 

for i = 1:nPoints
    
    circlePoints(1,i) = Xc + Radius*cos(i*angleFac*pi/180);
    circlePoints(2,i) = Yc + Radius*sin(i*angleFac*pi/180);
    circlePoints(3,i) = Zc ; 
    circlePoints(4,i) = 1; 
    
end



end