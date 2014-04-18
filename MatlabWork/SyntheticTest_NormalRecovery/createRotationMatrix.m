function Rt = createRotationMatrix( alpha, beta, gamma, t )

alpha = alpha*pi/180; beta = beta*pi/180; gamma = gamma*pi/180;

cb = cos(beta); sb = sin(beta); 
cg = cos(gamma); sg = sin(gamma); 
sa = sin(alpha); ca = cos(alpha);
Rt = [cb*cg, sa*sb*cg+ca*sg, -ca*sb*cg+sa*sg
      -cb*sg, -sa*sb*sg+ca*cg, ca*sb*sg+sa*cg
      t(1) t(2) t(3)]'; 

end