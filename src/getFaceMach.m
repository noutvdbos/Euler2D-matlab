function Mface = getFaceMach(M)
    
%This function calculates the Mach number at i+1/2 (i.e. at the face),
%see M. Liou.

    if abs(M(1)) <= 1 
        Mplus = 0.25*(M(1)+1)^2  + 0.125*(M(1)^2-1)^2;
    else
        Mplus = 0.5*(M(1) + abs(M(1)));
    end
    if abs(M(2)) <= 1
        Mmin  = -0.25*(M(2)-1)^2 - 0.125*(M(2)^2-1)^2;
    else
        Mmin  = 0.5*(M(2) - abs(M(2)));
    end
    
    Mface = Mplus + Mmin;
end