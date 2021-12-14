function div = getDiv(mesh,cellStates,gamma)

%This function calculates the divergence of the state vector. It loops over
%the cells, for each cell it calculates the flux vector, and applies it to
%the divergence.

%initialise divergence array
div = zeros(size(mesh.elems,1),size(cellStates,2));

for i = 1:length(div)
    
    sum = zeros(1,size(div,2));
    for j = 1:mesh.nnel 
              
       %calculate the flux for each face of the cell.
       faceFlux = constructFluxVector(mesh,gamma,i,j,cellStates);

       %add the flux to the sum
       sum = sum + faceFlux;
    end
    
    %the divergence is equal to the sum of all fluxes divided by the area.
    div(i,:) = sum/mesh.surfs(i);
    
end

end