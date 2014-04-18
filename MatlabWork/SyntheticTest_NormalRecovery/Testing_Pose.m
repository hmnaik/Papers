% Test App

x = [ 1051.08 638.849
    864.513 654.739
    1120.96 731.062
    1112.42 776.967
    1110.62 809.068
    1161.3  814.698];

X = [ -0.107 87.419 -37.057
    -0.091 172.731 -33.256
    20.927 58.324 0.093
    64.131 50.496 0.115
    97.762 42.213 0.084
    107.909 12.123 0.081
    ];

intrinsicMatrix = zeros(3);
intrinsicMatrix(1,1) = 1314.603271484375 ; intrinsicMatrix(2,2) = 1316.956298828125 ; intrinsicMatrix(3,3) =  1 ;
intrinsicMatrix(1,3) =  698.865966796875;
intrinsicMatrix(2,3) = 490.9814453125;
intrinsicMatrix(1,2) = 0 ; intrinsicMatrix(2,1) = 0 ; intrinsicMatrix(3,1) = 0 ; intrinsicMatrix(3,2) = 0 ;

X(:,4) = 1; 
X = X';

x(:,3) = 1 ; 
x = x'; 

% x = K * Rt * X
% inv(k)x = Rt * X
% 

 Rt = intrinsicMatrix\x ;
 
 Rt = Rt\X;
 
 