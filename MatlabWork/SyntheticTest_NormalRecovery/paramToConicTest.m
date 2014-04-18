
%% Test from Conic to Parametric data and back 
%% We give angles and axis length ans then we convert back to main equation. 

%% Test Data 
close all; 
maj_a =  4; % 1/sqrt(2); 
min_b =  2 ; % 1/sqrt(4); 
rotAngle = 45 *pi/180; 
trans_x = 3; 
trans_y = 3; 


% Create points 
i = 1; 
for theta = 0:10:360
    conicPoints(1,i) = maj_a * cos(theta*pi/180) ;
    conicPoints(2,i) = min_b * sin(theta*pi/180) ;
    i = i+1; 
end
% figure;
% plot(conicPoints(1,:),conicPoints(2,:),'*' );   % Plot normal points 
% Applied Rotation 
R = [cos(rotAngle) -sin(rotAngle) ; sin(rotAngle) cos(rotAngle)];
baseConicPoints = R * [ conicPoints(1,:) ;conicPoints(2,:) ]; 
% figure;
% plot(baseConicPoints(1,:),baseConicPoints(2,:),'*' ); % plot rotated points 
% Applied Translation 
x_points = baseConicPoints(1,:) + trans_x ; 
y_points = baseConicPoints(2,:) + trans_y ;

figure;
hold on
% plot(x_points, y_points,'ro'); 
plot(x_points, y_points,'b'); 
hold off

% Conic to Parametric  
c_conic = 1 ; 
lamda1 = 1/maj_a^2 ; 
lamda2 = 1/min_b^2 ; 
% D = [lam 0 ; 0 lam]; Only in case where c is assumed 1 
D = [ lamda1 0 ; 0 lamda2 ];
R = [cos(rotAngle) -sin(rotAngle) ; sin(rotAngle) cos(rotAngle)];
A = R' * D * R ; 

[ test test2 ] = eig( A) 

v = [trans_x trans_y]';
B = A * v ; 

d = ( v' * A * v )- c_conic;

% c1 x^2 + c2 y^2 + c3 xy + c4 x + c5 y + c6 = 0
% x A x + 2x Av 
para1 = A(1,1); % x^2
para2 = A(1,2)*2 ; % xy
para3 = A(2,2); % y^2
para4 = 2*B(1,1); % x
para5 = 2*B(2,1) ; % y
para6 = d ; % f

param = [ para1 para2 para3 para4 para5 para6 ]; 
param = param ./ para6 ; 

conicMatx = [para1 para2/2 para4/2;
            para2/2 para3 para5/2;
            para4/2 para5/2 para6]; 
 
fprintf('Ellipse eq : \n %d x^2 + %d xy + %d y^2 + %d x + %d y + (%d )= 0 \n', param ) ;  % para1,para2, para3, para4, para5, para6 ); 



%% Function Begins 
nw = size(baseConicPoints,2);
Aw = zeros(nw,5);
Bw = ones(nw,1)*-1; % -1 



points = [ x_points ; y_points ;ones(1,size(x_points,2)) ]; 

for i = 1:size(points,2)
    % Solss(i,:) = points(:,i)' * A * points(:,i) + 2* points(:,i)' *B + d; 
    Sol(i,:) = points(:,i)' *conicMatx * points(:,i); 
end 



% eq for any conic with center at h,k 
%
%% Return Math 
% x^2 / a^2 + y^2 / b^2 = 1 .... ellipse 
% b^2 x^2 + a^2 y^2 - a^2 b^2 = 0 ..... eq (1) 
% A x^2 + B xy + C y^2 + Dx + Ey + F = 0 ---- General eq ..... eq (2)
% Now comparing 
% A = b^2 , B = 0, C = a^2 , D = 0 , E = 0 , F = - a^2 * b^2 
Aw(:,1) = x_points.^2 * (+1) ;
Aw(:,2) = y_points.^2 * (+1) ;
Aw(:,3) = x_points.* y_points * (+1) ;
Aw(:,4) = x_points * (+1);
Aw(:,5) = y_points * (+1) ;

Aw = Aw * 1 ; 
xw = Aw\Bw; 


%% Return Math 
% a x^2 + b xy + c y^2 + d x + e y + f = 0 ---- General eq ..... eq (2)
% a = xw(1); c = xw(2) ; b = xw(3) ; d = -xw(4); e = -xw(5); f = 1; 
 a = xw(1); c = xw(2) ; b = xw(3) ; d = xw(4); e = +xw(5); f = 1; 
C = [ a b/2 d/2 ; 
    b/2 c e/2 ; 
    d/2 e/2 f] ;  

calculatedParam = [a b c d e f]; 
fprintf('Fitted Ellipse eq \n : %d x^2 + %d xy + %d y^2 + %d x + %d y + (%d )= 0 \n', calculatedParam ) ;

% Verification 

Mat = [ x_points ; y_points ; ones(1,size(x_points,2))]; 
for i = 1:size(Mat,2)
    Sol(i,:) = Mat(:,i)' * C * Mat(:,i); 
end 

% 
Acalc = [a b/2 ;b/2 c];
bcalc = [d/2 e/2]';  
dcalc = f; 

% 
vTrans =  -(Acalc \ bcalc); % B = Av --> v = inv(A)*B; 
c = (vTrans' * Acalc * vTrans) - dcalc ; % d = v' * A * v - c 

[rotAngle , Diag] = eig(Acalc)
rotAngle = rotAngle';
rotatedAngle = atan2(rotAngle(1,2), rotAngle(1,1))*180/pi;
if( rotatedAngle < 0 )
      rotatedAngle = rotatedAngle + 180;
elseif( rotatedAngle  > 360 )
        box.angle = rotatedAngle - 360;
end

maj_axis = sqrt(c/Diag(1,1));
min_axis = sqrt(c/Diag(2,2));

 N = 100;
dx = 2*pi/N;
   theta = rotatedAngle*pi/180;
   R = [ [ cos(theta) sin(theta)]', [-sin(theta) cos(theta)]'];
   for i = 1:N
        ang = i*dx;
        x = maj_axis*cos(ang);
        y = min_axis*sin(ang);
        d1 = R*[x y]';
        X(i) = d1(1) + vTrans(1);
        Y(i) = d1(2) +vTrans(2) ;
   end

figure(1)
hold off
plot(x_points,y_points,'ro')
hold on
plot(X,Y,'b')

