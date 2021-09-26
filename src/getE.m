function E = getE(gamma,rho,p,u,v)

%This function calculates the total energy

    E = p./((gamma-1).*rho) + 0.5.*(u.^2+v.^2);

end