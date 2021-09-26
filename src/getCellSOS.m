function a = getCellSOS(H,V,gamma)
    
%This function calculates the speed of sound adjusted for the AUSM+ scheme,
%see M. Liou.
    acrit = sqrt(2*(gamma-1)/(gamma+1)*H);
    
    a = acrit.^2./(max(acrit,abs(V)));
    
end