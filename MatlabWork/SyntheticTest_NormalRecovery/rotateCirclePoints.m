function rotatedCirclePoints = rotateCirclePoints(R ,T, circlePoints)

Translation = T;
Rotation = [R Translation];
Rotation = [Rotation ; 0 0 0 1];


[m n] = size(circlePoints);

if(m == 4)
    rotatedCirclePoints = Rotation * circlePoints ;
else
    rotatedCirclePoints = Rotation * circlePoints' ;
end

end