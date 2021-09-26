function mach = getMachNumber(gamma,V,rho,p)
    mach = V./sqrt(gamma.*p./rho);
end