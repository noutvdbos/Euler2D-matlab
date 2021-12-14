warning off

%start timer to time total execution time
tic

%add paths of subdirectories to the matlab path
restoredefaultpath
addpath(genpath(pwd))

%Load the inputs, this loads the mesh, the initial conditions, and the time
%criteria. Examples of all necesarry variables in the input files can be
%found in the tutorials.
runFolder = "./tutorials/cpp_test/"; %the relative path to the folder 
                                      %where the input file is stored
                                      
runFile   = "input.m";                %the name of the input file  

run(runFolder+runFile);

%% Solving (solve for the volume averages)
idx = 0;

%state vector at cell centres

w = [ rho, rho.*u , rho.*v , rho.*E ];

%write initial input at the nodes
pnodes = centresToNodes(mesh,p);
unodes = centresToNodes(mesh,u);

fname = runFolder+ resultsFolder + "/" + resultsName + string(idx)+ ".vtk";
writeVTK(fname,mesh,'scalars',"p",pnodes, ...
        'scalars', "u", unodes);

%%    
%Start computations
fprintf("-- Starting computation -- \n-- Time = %f s --\n\n",t); 

while t < tend
    
  %calculate velocity vector for CFL
  U = [ w(:,2)./w(:,1), w(:,3)./w(:,1)];
  Vmag = sqrt( (w(:,2).^2+w(:,3).^2)./(w(:,1).^2) );
  
  %determine the timestep based on cfl, if specified
  if idx == 0
      %do nothing, use the initial timestep
  elseif adjustTimeStep &&  max( abs(Vmag)) > eps
    dt = cfl*min(sqrt(mesh.surfs)./ Vmag);
  end
  
  %update the solution
  w =  w - dt*( getDiv(mesh,w,gamma) );
  
  t = t + dt;
  idx = idx+1;
   
   %print CFL number and time
   if ( mod(idx,printInterval) == 0)

        cflMax = dt* max( Vmag./sqrt(mesh.surfs) );
        fprintf("Max CFL number is : %f\n\n",cflMax); 
        fprintf("At %f of %f seconds\n\n",t,tend); 
   
   end
   
   %write results (of the nodes)
   if ( mod(idx,writeInterval) == 0)
       
       u = w(:,2)./(w(:,1));
       v = w(:,3)./(w(:,1));
       Vmag = sqrt(u.^2+v.^2);
       rho = w(:,1);
       p = getPressure(gamma,w);
       mach = getMachNumber(gamma,Vmag,rho,p);
       
       pNodes = centresToNodes(mesh,p);
       uNodes = centresToNodes(mesh,u);
       
       rhoNodes = centresToNodes(mesh,rho);
       machNodes = centresToNodes(mesh,mach);
       
       fname = runFolder + resultsFolder + "/" + resultsName + string(idx)+ ".vtk";
       
       writeVTK(fname,mesh,...
                'scalars',"p",pNodes, ...
                'scalars', "u", uNodes,...
                'scalars', "rho", rhoNodes,...
                'scalars', "mach", machNodes );
   end
end
%%

%write all final results in the nodes
u = w(:,2)./(w(:,1));
v = w(:,3)./(w(:,1));
Vmag = sqrt(u.^2+v.^2);
rho = w(:,1);
p = getPressure(gamma,w);
mach = getMachNumber(gamma,Vmag,rho,p);

pnodes = centresToNodes(mesh,p);
unodes = centresToNodes(mesh,u);
vnodes = centresToNodes(mesh,v);
Vmagnodes = centresToNodes(mesh,Vmag);
rhonodes = centresToNodes(mesh,rho);
machnodes = centresToNodes(mesh,mach);

fname = runFolder + resultsFolder + "/" + resultsName + "_final" + ".vtk";
writeVTK(fname,mesh,'scalars', "p", pnodes, ...
                    'scalars', "u", unodes, ...
                    'scalars', "v", vnodes, ...
                    'scalars', "Vmag", Vmagnodes, ...
                    'scalars', "rho", rhonodes, ...
                    'scalars', "mach", machnodes);

%Display the total run time.
fprintf(" -- Total execution time was: %5.4f seconds --\n",toc);