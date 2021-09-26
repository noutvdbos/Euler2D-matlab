function newField = nodesToCentres(mesh, field)

%assume the centre value is the average of all connected nodes
newField = zeros(mesh.nel,size(field,2));

for i = 1:mesh.nel    
    newField(i,:) = mean(field(mesh.elems(i,:),:));
end

end