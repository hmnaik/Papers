function meanVal = checkConicMatrix(C , ImagePoints)

[m n] = size(ImagePoints);

% Homogenize 
if( m == 2) 
    ImagePoints(3,:) = 1; 
    
    for k = 1:n
    J(1,k) = ImagePoints(:,k)' * C * ImagePoints(:,k); 
    end
    
else
    ImagePoints(:,3) = 1; 
    ImagePoints = ImagePoints'; 
    J = ImagePoints' * C * ImagePoints; 
end

meanVal = mean(J);

    
end