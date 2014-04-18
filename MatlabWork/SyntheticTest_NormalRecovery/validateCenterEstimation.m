function success = validateCenterEstimation(gtC1,gtC2,estimatedC1,estimatedC2)

dist1 = calculateDistance (gtC1,estimatedC1);
dist2 = calculateDistance (gtC2,estimatedC2);

if( dist1 < 10 && dist2 < 10 )
    success = 1; 
else
    success = 0; 
    
end

end