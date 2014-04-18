function [n1 n2 T1 T2 calculatedRadius] = calculateNormals(Ci, markerRadius, K )

%% Testing Data 
% markerRadius = 15 ; 
% Cw = [ 1/(15)^2 0 0 ; 0 1/(15)^2 0 ; 0 0 -1]; 
% Rt = [1 0 0 5; 0 1 0 10; 0 0 1 15]; 
% Ci = K * Rt * Cw ; 
% %%

Cnorm = K'*Ci*K ; 

%% Cnorm = Now in 3D form 
[ V , D ] = eig (Cnorm); 

[dummy, i] = sort(diag(D));
Ds = D(i,i);
Vs = V(:,i);

R1 = Vs ; 
lam1 = Ds(1,1);
lam2 = Ds(2,2);
lam3 = Ds(3,3); 

C1 = R1' * Cnorm * R1; 

Theta = atan( sqrt( (lam2-lam1)/(lam3-lam2) ) );
% HMN : Sqrt added 14.06
calculatedRadius = sqrt( (-lam3 * lam1)/ (lam2)^2) ; 
alpha = sqrt( - (lam2-lam1)*(lam3-lam2)/(lam1*lam3) )* markerRadius ;
distance = sqrt( - (lam2*lam2)/ (lam1*lam3)) *markerRadius ;

R2 = [ cos(Theta) 0 sin(Theta); 0 1 0 ; -sin(Theta) 0 cos(Theta) ]; 
R22 = [ cos(-Theta) 0 sin(-Theta); 0 1 0 ; -sin(-Theta) 0 cos(-Theta) ]; 

C2 = R2' * C1 * R2 ; 
C22 = R22' * C1 * R22 ; 

Rc1 = R1 * R2; 
Rc2 = R1 * R22;



% Not negating for keeping them in same coordinate system 
n1 = Rc1(:,3); % Multiply by negative 1 for right handed coordinate system 
n1 = n1 / norm(n1);

n2 = Rc2(:,3);% Multiply by negative 1 for right handed coordinate system 
n2 = n2 / norm(n2);


% For the RH coordinate system 
n1 = -1 * n1; 
n2 = -1 * n2; 

% Normal is expected to face -ve Z. I.e. We assume that we look in direction of +ve Z  
if (n1(3) > 0)
    n1 = -n1;
    Rc1 = -Rc1;
end

if (n2(3) > 0)
    n2 = -n2;
    Rc2 = -Rc2;
end

T1 = Rc1*[alpha 0 distance]';
T2 = Rc2*[-(alpha) 0 distance]';

%% Added : 28.06.13 : T(3) for some simulation was -ve 
if (T1(3) < 0)
  T1 = -T1;
  n1 = -n1;
end


if (T2(3) < 0)
  T2 = -T2;
  n2 = -n2;
end











end