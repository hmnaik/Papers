function angle = calculateAngle(v1, v2)

%% Test Data
% v1 = [ 0 1 0 ]; 
% v2 = [ 1 0 0] ; 

if( all(v1 == 0) || all(v2 == 0) )
    
    angle = 0;
    
else
    angle = dot ( v1 , v2) / ( norm(v1) * norm(v2) );
    angle = acos(angle) * 180 /pi;
end
end