function p = getPressure(gamma, w)

%This function calculates the pressure, based on ideal gas theory. It can
%take both w as a full array, or the state vector of a single node/cell.

    if size(w,2) ==1
    
        p = (gamma-1).*( w(4) - 0.5./w(1).*(w(2).^2 + w(3).^2) );
    
    else
        p = (gamma-1).*( w(:,4) - 0.5./w(:,1).*(w(:,2).^2 + w(:,3).^2) );
    end
end