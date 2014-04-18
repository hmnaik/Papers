function [n1 n2] = solveNormalAmbiguity(groundTruth, normalSet )

%% Unit Test Data
% groundTruth = 40;
% normalSet = [ 40.3 40.4 40.034 33] ;
%% 

diff = abs(normalSet - groundTruth) ;
[sortedDiff order ]= sort(diff);

if ( order(1) == 1)
    n1 = 1;
    n2 = 1;
elseif (order(1) == 2)
    n1 = 1;
    n2 = 2;
elseif (order(1) == 3)
    n1 = 2;
    n2 = 1;
elseif (order(1) == 4)
    n1 = 2;
    n2 = 2;    
end


end