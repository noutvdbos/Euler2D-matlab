function div = getDiv(mesh,cellStates,gamma)

%This function calculates the divergence of the state vector. It loops over
%the cells, for each cell it calculates the flux vector, and applies it to
%the divergence.

%initialise divergence array
div = zeros(size(mesh.elems,1),size(cellStates,2));

for i = 1:length(div)
    
    sum = zeros(1,size(div,2));
    for j = 1:mesh.nnel 
       
       %make sure that the correct nodes are prescribed to node1 and node2.
       %The nodes are prescribed in a circle.
       
       if (j<mesh.nnel)
            node1 = mesh.elems(i,j);
            node2 = mesh.elems(i,j+1);
        else
            node1 =  mesh.elems(i,j);
            node2 =  mesh.elems(i,1);
       end 
       
       
       iface = mesh.elemFaces(i,j);
       coords = mesh.coords([node1 node2],:);       
       normal = getNormal(coords);
       
       h = norm(coords(1,:) - coords(2,:));
       
       %calculate the flux per unit length for each face of the cell.
       faceFlux = constructFluxVector(mesh,gamma,iface,normal,cellStates);

       %add the flux to the sum
       sum = sum + faceFlux*h;
    end
    
    %the divergence is equal to the sum of all fluxes divided by the area.
    div(i,:) = sum/mesh.surfs(i);
    
end

end