function P = createProjectionMatrix( K , R , T)


Rt = [R T];
P = K * Rt ; % 3x4 

end 