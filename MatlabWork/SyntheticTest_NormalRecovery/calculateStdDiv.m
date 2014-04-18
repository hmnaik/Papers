function [stdDivErrorMatrix errorMeanMatrix] = calculateStdDiv( matrix )

angleSize = size(matrix,1);
distSize = size(matrix,2);
noiseSize = size(matrix,3);

errorMean = zeros ( 1, noiseSize) ;
errorMeanMatrix = zeros(angleSize,distSize); 
diffErrorMean = zeros ( size(matrix) ); 

% Error w.r.t all noise factors
% Calculating mean error for a configuration @ different noise
% i.e. ang = a, dist = b @ all noise range
for k = 1:1:angleSize
    for l = 1:1:distSize
        for m = 1:1:noiseSize
            errorMean(1,m) = matrix (k,l,m) ;
        end
        
        meanVal = mean(errorMean);
        errorMeanMatrix(k,l) = meanVal;
    end
end

% for m = 1:1:noiseSize
%      diffErrorMean(:,:,m) = matrix(:,:,m) - errorMeanMatrix;
% end

diffErrorMean = matrix;
sqDiffErrorMean = diffErrorMean.^2; % || Xi - X ||^2

sumSqDiffErrorMean = sum(sqDiffErrorMean,3); % sum ( || Xi,j - X ||^2 )j=1ton 
stdDivErrorMatrix = sqrt( sumSqDiffErrorMean ./ (noiseSize)) ; % or sqrt(  sum ( || Xi,j - X ||^2 )j=1ton / n  ) 




end