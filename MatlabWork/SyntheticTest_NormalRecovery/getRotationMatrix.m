function [Rx Ry Rz]= getRotationMatrix( alpha, beta, gamma )

alpha = alpha*pi/180; beta = beta*pi/180; gamma = gamma*pi/180;

sa = sin(alpha); ca = cos(alpha);
cb = cos(beta); sb = sin(beta); 
cg = cos(gamma); sg = sin(gamma); 


Rx = [  1 0 0; 0 ca -sa; 0 sa ca ]; 

Ry = [  cb 0 sb ; 0 1 0 ; -sb 0 cb];

Rz = [  cg -sg 0; sg cg 0 ; 0 0 1]; 

end