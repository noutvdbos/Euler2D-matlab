function newField = centresToNodes(mesh, field)

%This function interpolates the cell centre values to the nodes of the
%mesh, it is assumed that the node value is the average of all connected
%cell centres.

newField = zeros(mesh.nbNod,size(field,2));

for i = 1:mesh.nbNod
    newField(i,:) = mean( field(mesh.elsup1( mesh.elsup2(i)+1: ...
                                mesh.elsup2(i+1)),:));
end

end