function faceFlux = constructFluxVector(mesh,gamma,ielem,jface,cellStates)

%In this function, the flux vector per unit length is constructed for a
%face. The boundary cells are treated by adding a ghost cell. For now the
%mehtod is implemented as follows: it is assumed that the leftmost and the
%right most boundaries are the inlet/outlet, and anything in between is a
%wall. This is done because the current testcases allow this, and this is
%only a proof of concept code. For the inlet and outlet the ghostcells are
%equal to the boundary cell, i.e. both sides allow for information
%propagation through the boundaries, and the problem is completely defined 
%by the initial conditions. The wall boundary cells are
%implemented with a slip boundary condition, i.e. the wall normal velocity
%is zero, but the wall tangential velocity not. The pressure and density
%are first order extrapolated to the boundary, i.e. the ghost cell is
%assumed to have the same pressure and density as the boundary cell.

cellidx = [ielem, mesh.elsuel(jface,ielem) ];

if (jface<mesh.nnel)
    node1 = mesh.elems(ielem,jface);
    node2 = mesh.elems(ielem,jface+1);
else
    node1 =  mesh.elems(ielem,jface);
    node2 =  mesh.elems(ielem,1);
end 

coords = mesh.coords([node1 node2],:); 
normal = getNormal(coords);

h = norm(coords(1,:) - coords(2,:));

% If all the cell indexes mesh.elsuel(jface,ielem) is equal to zero, there
% are no neighbour cells attached thus it is a boundary cell.

if  ( mesh.elsuel(jface,ielem) == 0 )

    cellidx = [ielem,ielem];
    
    %inlet/outlet
    if ( all(coords(:,1) == mesh.MIN(1)) )

        cells = cellStates(cellidx,:);     

    %outlet/inlet
    elseif ( all(coords(:,1) == mesh.MAX(1)))

        cells = cellStates(cellidx,:);  

    %walls
    else

      %construct the ghost cell (cell2), which has the same values for
      %the density and internal energy, except the velocity is in the
      %direction such that the normal velocity at the face is zero.

      cell1 = cellStates(cellidx(1),:);
      cell2 = zeros(size(cell1));

      cell2(1) = cell1(1);
      cell2(end) = cell1(end);

      %find reflection vector, such that the tangential velocity can be
      %constructed at the face. 
      vdir = cell1(2:3)/max(norm(cell1(2:3)),eps);
      rdir = vdir - 2*(normal*vdir')*normal;

      cell2(2) = cell1(2)*rdir(1);
      cell2(3) = cell1(3)*rdir(2);

      %find location of centre of the ghost cell, this is necessary to find
      %which direction is the upwind direction.
      
      gCentre = getGhostCellCentre(mesh,node1,node2,cellidx);

      if ( normal*mesh.cents(cellidx(1),1:2)' < normal*gCentre' )

         cells = [cell1 ;cell2];
      else
         cells = [cell2 ;cell1];
      end

    end

else


%The cells are ordered such that the first cell has the face of which
%the normal is calculated. If the normal is not in line with the
%velocity, than it must go the other way, so then cell value 2 is
%taken.

%the first index is the left value, the second index is the right value
    if ( normal*mesh.cents(cellidx(1),1:2)' < normal*mesh.cents(cellidx(2),1:2)' )

       cells = cellStates(cellidx,:);

    else
       cells = cellStates(flip(cellidx),:);
    end
end

%After the ghost cells are introduced, all faces are treated exactly the 
% same. The AUSM+ scheme is used. Here the flux vector is deconstructed
% into a velocity part, and a pressure part. The AUSM+ scheme is an upwind
%scheme. the vector psi is the velocity flux, the vector P' is the pressure
%flux.

%For more info about the AUSM+ scheme, see "A Sequel to AUSM: AUSM+", by M
%Liou.


rho = cells(:,1);
u   = cells(:,2)./rho;
v   = cells(:,3)./rho;

V = [u, v]*normal'; %normal velocities
p   = getPressure(gamma,cells);
H   = getH(getE(gamma,rho,p,u,v),p,rho);

a = getCellSOS(H,V,gamma); %speed of sound

M   = V./a;
Mface = getFaceMach(M);
pface = getFacePressure(M,p);

P = [ 0; pface*normal(1) ; pface*normal(2) ; 0 ];

psi = [ rho, rho.*u, rho.*v, rho.*H];

M1 = 0.5*(Mface+abs(Mface));
M2 = 0.5*(Mface-abs(Mface));

faceFlux = M1*a(1)*psi(1,:) + M2*a(2)*psi(2,:) + P';

faceFlux = faceFlux*h;

end


function centre = getGhostCellCentre(mesh,node1,node2,cellidx)

%This function calculates the centre  of the ghost cell, based on :
%https://math.stackexchange.com/questions/1013230/
%how-to-find-coordinates-of-reflected-point

    a = mesh.coords(node1,2) - mesh.coords(node2,2);
    b = mesh.coords(node2,1) - mesh.coords(node1,1);
    c = mesh.coords(node1,1)*mesh.coords(node2,2) - ...
    mesh.coords(node1,2)*mesh.coords(node2,1);

    x1 = mesh.cents(cellidx(1),1);
    y1 = mesh.cents(cellidx(1),2);
    
    xg = x1 - 2*(a*x1+b*y1+c)/(a^2+b^2)*a;
    yg = y1 - 2*(a*x1+b*y1+c)/(a^2+b^2)*b;
    
    centre = [xg,yg];
end
