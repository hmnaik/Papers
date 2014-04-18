function dist = calculateDistance(v1 , v2 )

sqDiff = (v1 - v2).^2 ; 

dist = sqrt ( sum( sqDiff) ); 

end