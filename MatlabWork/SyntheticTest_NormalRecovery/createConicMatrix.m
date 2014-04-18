function [ C elipseParam ] = createConicMatrix( baseConicPoints , drawEllipse)

% %% Test Data
% close all;
% maj_a =  4; % 1/sqrt(2);
% min_b =  2 ; % 1/sqrt(4);
% rotAngle = 45 *pi/180;
% trans_x = 3;
% trans_y = 3;
%
% % Now
% c_conic = 1 ;
% lamda1 = 1/maj_a^2 ;
% lamda2 = 1/min_b^2 ;
% D = [ lamda1 0 ; 0 lamda2 ]
% R = [cos(rotAngle) -sin(rotAngle) ; sin(rotAngle) cos(rotAngle)]
% A = R' * D * R
% v = [trans_x trans_y]';
% B = A * v ;
% d = ( v' * A * v )- c_conic;
%
% % c1 x^2 + c2 y^2 + c3 xy + c4 x + c5 y + c6 = 0
% para1 = A(1,1); % x^2
% para2 = A(1,2)*2 ; % xy
% para3 = A(2,2); % y^2
% para4 = 2*B(1,1); % x
% para5 = 2*B(2,1) ; % y
% para6 = d ; % f
%
% param = [ para1 para2 para3 para4 para5 para6 ];
% param = param ./ para6 ;
%
% conicMatx = [para1 para2/2 para4/2;
%             para2/2 para3 para5/2;
%             para4/2 para5/2 para6];
%
% fprintf('Ellipse eq : \n %d x^2 + %d xy + %d y^2 + %d x + %d y + (%d )= 0 \n', param ) ;  % para1,para2, para3, para4, para5, para6 );
%
% 
% maj_a =  4;
% min_b =  2 ;
% rotangle = 45 *pi/180;
% trans_x = 333;
% trans_y = 445;
% drawellipse = 1 ; 
% i = 1;
% for theta = 0:10:360
%     conicpoints(1,i) = maj_a * cos(theta*pi/180) ;
%     conicpoints(2,i) = min_b * sin(theta*pi/180) ;
%     i = i+1;
% end
% r = [cos(rotangle) -sin(rotangle) ; sin(rotangle) cos(rotangle)]
% baseconicpoints = r* [ conicpoints(1,:) ;conicpoints(2,:) ];
% 
% baseconicpoints(1,:) = baseconicpoints(1,:) + trans_x ;
% baseconicpoints(2,:) = baseconicpoints(2,:) + trans_y ;
% 
% figure;
% hold off
% plot(conicPoints(1,:),conicPoints(2,:),'*' );
% hold on
% plot(baseConicPoints(1,:),baseConicPoints(2,:),'o' );
% hold off

%% Function Begins
nw = size(baseConicPoints,2);
Aw = zeros(nw,5);
Bw = ones(nw,1)*-1; % -1

x_points = baseConicPoints(1,:) ;
y_points = baseConicPoints(2,:) ;

%% 2 July Test Setup 
% x_points = [ 1838.0125 1836.8296 1863.0977 1871.4541 1846.0073 1840.0 1823.1223 1818.9384 1817.0516 1815.2021];
% y_points = [1723.0541 1723.3801 1776.1351 1739.7909 1722.8335 1723.0 1732.1132 1736.9639 1741.0206 1749.9417];
% Aw = zeros(10,5);
% Bw = ones(10,1)*-1; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% meanx = mean(x_points);
% meany = mean(y_points);

% x_points = x_points - meanx;
% y_points = y_points - meany;

% A = [x^2 y^2 xy x y] ; B = [ -1 -1 -1 -1 -1 -1] --> Solve Ax = B ;
Aw(:,1) = x_points.^2 * (+1) ;
Aw(:,2) = y_points.^2 * (+1) ;
Aw(:,3) = x_points.* y_points * (+1) ;
Aw(:,4) = x_points * (+1);
Aw(:,5) = y_points * (+1) ;

Aw = Aw * 1 ;
xw = Aw\Bw;

%% Return Math
% a x^2 + b xy + c y^2 + d x + e y + f = 0 ---- General eq ..... eq (2)
a = xw(1); c = xw(2) ; b = xw(3) ; d = xw(4); e = +xw(5); f = 1;

%% 2 July Test Setup 
% a = 1.57e-7;
% c = 1.58e-7;
% b = -6.83e-9;
% d = -0.000567;
% e = -0.0005441; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
calculatedParam = [a b c d e f];
%fprintf('Fitted Ellipse eq \n : %d x^2 + %d xy + %d y^2 + %d x + %d y + (%d )= 0 \n', calculatedParam ) ;


% paramNew = fitellip(x_points,y_points) ;
% fprintf('New method Ellipse :  eq \n : %d x^2 + %d xy + %d y^2 + %d x + %d y + (%d )= 0 \n', paramNew ) ;
%
% a = paramNew(1);
% b = paramNew(2);
% c = paramNew(3);
% d = paramNew(4);
% e = paramNew(5);
% f = paramNew(6);

C = [ a b/2 d/2 ;
    b/2 c e/2 ;
    d/2 e/2 f] ;

% Verification
%
% Mat = [ x_points ; y_points ; ones(1,size(x_points,2))];
% for i = 1:size(Mat,2)
%     Sol(i,:) = Mat(:,i)' * C * Mat(:,i);
% end

%% Paraetric check to get the 5 parameters for ellipse

Acalc = [a b/2 ;b/2 c];
bcalc = [d/2 e/2]';
dcalc = f;

vTrans =  -(Acalc \ bcalc); % B = Av --> v = inv(A)*B;

checkMat = vTrans' * Acalc; 
cTemp = checkMat * vTrans ; 

c = vTrans' * Acalc * vTrans - dcalc ; % d = v' * A * v - c

[rotAngle , Diag] = eig(Acalc);
rotAngle = rotAngle';
rotatedAngle = atan2(rotAngle(1,2), rotAngle(1,1));
angleDegree = rotatedAngle * 180/pi;
if(angleDegree < 0 )
    angleDegree = angleDegree+180;
    rotatedAngle = angleDegree * pi/180;
end
maj_axis = sqrt(c/Diag(1,1));
min_axis = sqrt(c/Diag(2,2));
if(maj_axis < min_axis)
    t = maj_axis;
    maj_axis = min_axis;
    min_axis = t ;
    
    angleDegree = angleDegree-90;
    rotatedAngle = angleDegree * pi/180;
    
end

elipseParam = [ maj_axis min_axis vTrans(1) vTrans(2) angleDegree] ;

N = 100;
dx = 2*pi/N;
theta = rotatedAngle;
R = [ [ cos(theta) sin(theta)]', [-sin(theta) cos(theta)]'];
for i = 1:N
    ang = i*dx;
    x = maj_axis*cos(ang);
    y = min_axis*sin(ang);
    d1 = R*[x y]';
    X(i) = d1(1) + vTrans(1);
    Y(i) = d1(2) + vTrans(2) ;
end

% Draw the original points and the fitted conic
if(drawEllipse)
    figure(2);
    hold off
    plot(x_points,y_points,'ro')
    hold on
    plot(X,Y,'b')
    hold off
    axis equal; 
    
end

%%




end