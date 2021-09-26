function msh = getMesh(meshType,fileName)

%This function takes the matlab mesh generated with gmsh and adds the
%additional information that is necessary for the computations. The mesh
%must either be fully triangular, or fully quadrangular.

%% import mesh, is saved in structure msh.
run(fileName);

fprintf("Importing the mesh from Gmsh \n\n");

if ( lower(meshType) == "triangle")
    
    msh.elems = msh.TRIANGLES(:,1:3);
    msh = rmfield(msh,"TRIANGLES");
    
    %add additional parameters
    msh.type = "triangle";
    
elseif ( lower(meshType) == "quadrangle")
     
    msh.elems = msh.QUADS(:,1:4);
    msh = rmfield(msh,"QUADS");
    
    %add additional parameters
    msh.type = "quadrangle";
        
    
else
   throw(MException('myComponent:inputError',...
       " Mesh type '%s' is not allowed", meshType)); 
end


%change original names to more obvious names
msh.coords = msh.POS;
msh = rmfield(msh,"POS");

msh.MAX = max(msh.coords);
msh.MIN = min(msh.coords);


%add additional parameters
msh.nel  = length(msh.elems);    %total amount of elements
msh.nnel = size(msh.elems,2); % number of nodes per element

%determine the surfaces of each element

fprintf("calculating surface of each element\n");
tic
surfs = zeros(msh.nel,1);

for i = 1:length(surfs)
    surfs(i) = polyarea(msh.coords(msh.elems(i,:),1),...
                        msh.coords(msh.elems(i,:),2));
end
msh.surfs = surfs;

fprintf(" -- This took %5.4f seconds\n",toc);

%determine the centroid of each element

fprintf("determining the centroid of each element\n");
tic
cents = zeros(msh.nel,3);
for i = 1:msh.nel

    cents(i,1) = mean(msh.coords(msh.elems(i,:),1));
    cents(i,2) = mean(msh.coords(msh.elems(i,:),2));

end   
msh.cents = cents;

fprintf(" -- This took %5.4f seconds\n",toc);

%Create vertices-elements connections,maximum number
%of elements using 1 node will probably not go higher than 7.
%TODO: check actual maximum

fprintf("calculating the vertex-elements matrix\n");
tic
nelmax = 10;
verts = zeros(msh.nbNod,nelmax);

for i = 1:msh.nbNod
    temp = find(any(msh.elems==i,2))';
    verts(i,:) = [temp NaN*zeros(1,nelmax-length(temp))] ;
end

msh.verts = verts;

fprintf(" -- This took %5.4f seconds\n",toc);


fprintf("calculating the elements-faces matrix\n");
tic

%create list of all the faces, create list that lists the faces of each 
%element, and create list that lists the elements of each face


nfaces = msh.nbNod+msh.nel -1; %euler characteristic for 2d
faces = zeros(nfaces,2);
faceElems = zeros(nfaces,2);
elemFaces = zeros(msh.nel,msh.nnel);

idx = 1;
for i = 1:msh.nel
    for j = 1:msh.nnel
       if (j<msh.nnel)
            node1 = msh.elems(i,j);
            node2 = msh.elems(i,j+1);
        else
            node1 =  msh.elems(i,j);
            node2 =  msh.elems(i,1);
       end
       
       temp = find( any(msh.elems(:,:)==node1,2) & ...
             any(msh.elems(:,:)==node2,2) ); 
         
       if (i == temp(1))
         faces(idx,:) = [node1 node2];
         faceElems(idx,:) = temp;
         elemFaces(i,j) = idx;
         idx = idx+1;
       else
           %find previously found face
           faceNodes = intersect(msh.elems(temp(1),:),msh.elems(temp(2),:));
           temp = find( all( faces(:,:) == faceNodes,2 ) );
           
           if isempty(temp)
               temp = find( all( faces(:,:) == flip(faceNodes),2 ) );
           end
           elemFaces(i,j) = temp;
       end
       
    end
end

msh.faces = faces;
msh.elemFaces = elemFaces;
msh.faceElems = faceElems;

fprintf(" -- This took %5.4f seconds\n",toc);

fprintf("Finalised importing the mesh from Gmesh \n\n");

end