function pface = getFacePressure(M,p)

%This function calculates the pressure at i+1/2 (i.e. at the face),
%see M. Liou.

    if abs(M(1)) <= 1 
        plus = 0.25*(M(1)+1)^2*(2-M(1)) + 3/16*M(1)*(M(1)^2-1)^2;
        %plus = 0.5*(1 + M(1));
    else
        plus = 0.5*(M(1) + abs(M(1)))/M(1);
    end
    if abs(M(2)) <= 1
        min  = 0.25*(M(2)-1)^2*(2+M(2)) - 3/16*M(2)*(M(2)^2-1)^2;
        %min = 0.5*(1 - M(2));
    else
        min  = 0.5*(M(2) - abs(M(2)))/M(2);
    end
    
    pface = p(1)*plus + p(2)*min;
end