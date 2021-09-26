function field = initField(mesh,val)

%This function initialises the field with a certain value

    field = zeros(size(mesh.elems,1),1) + val;
end