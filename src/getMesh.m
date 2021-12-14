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

%Create vertices-elements connections, average number
%of elements using 1 node will not go higher than 10.

% The vertices-elements connections stored as a linked list, so they  are 
% divided into 2 arrays, elsup1(elements surrounding points 1) stores the 
% elements, and elsup2 stores the start and end index of the elements that
% surround a point. example: for point ipoint, the elements surrounding
% this point are stored in elsup1( elsup2(ipoint)+1 : elsup2(ipoint+1) );

fprintf("calculating the vertex-elements matrix\n");
tic
nelmax = 10;

elsup1 = zeros(length(msh.coords)*nelmax,1); 
elsup2 = zeros(length(msh.coords)+1,1);

% Pass 1: First count the elements connected to each point
for i = 1:length(msh.elems)
    for j = 1:msh.nnel 
       ipoint = msh.elems(i,j) + 1;
       elsup2(ipoint) = elsup2(ipoint) +1;
       
    end
end

% Reshuffle the first pass
for i = 2:length(msh.coords)+1
    elsup2(i) = elsup2(i) + elsup2(i-1);
end

%Pass 2: store the elements in esup1

maxlen = 0;
for i = 1:length(msh.elems)
    for j = 1:msh.nnel 
       
       ipoint = msh.elems(i,j);
       istore = elsup2(ipoint) +1;
       elsup2(ipoint) = istore;
       elsup1(istore) = i;
       
       maxlen = max(maxlen,istore);
    end
end

% Reshuffle the second pass
for i = length(msh.coords)+1:-1:2    
    elsup2(i) = elsup2(i-1);
end
elsup2(1) = 0;

%Now the max length is known, only store the correct length of esup1.
msh.elsup2 = elsup2;
msh.elsup1 = elsup1(1:maxlen);

fprintf(" -- This took %5.4f seconds\n",toc);




% Calculate the elements surrounding elements matrix (elsuel). This matrix stores
% the neighbour of each face of the owner element. faces are in the
% convention as follows face1 = (node_1,node2), face2 = (node_2, node3),
% ..., face_n-1 = (node_n-1,node_n), face_n = (node_n, node_1). I.e. it
% forms a closed loop.

fprintf("calculating the face-elements matrix\n");
tic

elsuel = zeros(msh.nnel,msh.nel);

for ielem = 1:msh.nel
    for iface = 1:msh.nnel     % loop over faces
        
        node1 = msh.elems(ielem,iface);
        if (iface<msh.nnel)
            node2 = msh.elems(ielem,iface+1);
        else
            node2 =  msh.elems(ielem,1);
       end
        
        for istore = elsup2(node1)+1:elsup2(node1+1) %loop over neighbour elements
            jelem = elsup1(istore);

            if (jelem ~= ielem)
                npoins = intersect( [node1,node2],msh.elems(jelem,:));
                
                if (size(npoins,2) ==2)
                    elsuel(iface,ielem) = jelem;
                end
            end
        end
    end
end

msh.elsuel = elsuel;


fprintf(" -- This took %5.4f seconds\n",toc);

fprintf("Finalised importing the mesh from Gmesh \n\n");

end