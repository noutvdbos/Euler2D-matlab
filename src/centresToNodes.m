function newField = centresToNodes(mesh, field)

%This function interpolates the cell centre values to the nodes of the
%mesh, it is assumed that the node value is the average of all connected
%cell centres.

newField = zeros(mesh.nbNod,size(field,2));

for i = 1:mesh.nbNod
    if ( size(rmmissing(mesh.verts(i,:)),2) == 1)
        newField(i,:) = field(rmmissing(mesh.verts(i,:)),:);
    else
        newField(i,:) = mean(field(rmmissing(mesh.verts(i,:)),:));
    end
end

end