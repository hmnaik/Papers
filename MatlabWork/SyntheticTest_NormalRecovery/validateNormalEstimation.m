function success = validateNormalEstimation(gt1,gt2,measured1,measured2)


theta1 = calculateAngle(gt1,measured1);
theta2 = calculateAngle(gt2,measured2);

if( theta1 < 5 && theta2 < 5 )
   success = 1; 
else
   success = 0; 
end




end