%% import mesh, is saved in structure msh.
meshType = "Quadrangle";        %Type of elements used, choose either 
                                %triangle or quadrangle
meshFile = "mesh.m";            %Name of the mesh file
meshSaveName = "mesh.mat";      %Name of what the mesh should be saved as
resultsFolder = "./results";    %Name of folder where the results should be
                                %stored.
resultsName = "results";        %The suffix that is used for the results.
reloadMesh = true;              %Determines if the mesh is reloaded or not

%Load the mesh

%Since calculating the elements-faces matrix takes some time, only get the
%mesh if there doesn't exist one, or if it is explicitly stated that it
%must be reloaded
if (~isfile(meshSaveName) || reloadMesh)
    mesh = getMesh( meshType, meshFile);
    save(meshSaveName,"mesh")
else
    load(meshSaveName);
end

if ~exist(resultsFolder, 'dir')
   mkdir(resultsFolder)
end 

%% Constants
cfl = 0.1;                  %CFL number that is used in case the time step
                            % can be adjusted
adjustTimeStep = false;     %Flag to determine if the time step can be 
                            %adjusted
                            
gamma = 1.4;                %Specific heat ratio


t = 0;                      % inital time
tend = 0.17;                % end time
dt = 0.001;                 %initial timestep

writeInterval = 1;          
printInterval = 1;

%% initial conditions

%Here create the initial conditions for u,v,rho,p and E.

u = initField(mesh,0.0);
v = initField(mesh,0.0);
rho = initField(mesh,0.0);
p = initField(mesh,0.0);


p(mesh.cents(:,1)<0.5) = 1;
p(mesh.cents(:,1)>0.5) = 0.1;

rho(mesh.cents(:,1)<0.5) = 1;
rho(mesh.cents(:,1)>0.5) = 0.125;

E = getE(gamma,rho,p,u,v);
