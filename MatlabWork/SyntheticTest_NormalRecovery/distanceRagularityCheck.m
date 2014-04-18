

%% Dist experiment 


Orig = [ 0 0 0 ] ; 
AnyPoint = [ 8 8 8];
AnyPoint2 = [ 16 16 16]; 

A = [ 0 1 1 ; 0 1 0 ; 0 2 3 ; 2 3 4 ] ; 

for i = 1 : size(A,1) 
diff = A(i,:) - O;
dist(:,i) = sqrt(sum( (diff).^2) );
end

for i = 1 : size(A,1) 
diff = A(i,:) - AnyPoint; 
distAnyPoint1(:,i) = sqrt(sum( (diff).^2) );
end

for i = 1 : size(A,1) 
diff = A(i,:) - AnyPoint2; 
distAnyPoint2(:,i) = sqrt(sum( (diff).^2) );
end

ratio1 = dist ./ distAnyPoint1 ; 

ratio2 = dist ./ distAnyPoint2 ; 