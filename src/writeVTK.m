function writeVTK( filename,mesh,varargin )

%This function is a modified function, the original is from Chaoyuan Yeh


fid = fopen(filename, 'w'); 

% VTK files contain five major parts
% 1. VTK DataFile Version
fprintf(fid, '# vtk DataFile Version 2.0\n');

% 2. Title
fprintf(fid, 'VTK from Matlab\n');
binaryflag = any(strcmpi(varargin, 'BINARY'));
if any(strcmpi(varargin, 'PRECISION'))
    precision = num2str(varargin{find(strcmpi(vin, 'PRECISION'))+1});
else
    precision = '4';
end      

% 3. The format data proper is saved in (ASCII or Binary). Use
% fprintf to write data in the case of ASCII and fwrite for binary.
setdataformat(fid, binaryflag);

n_coords = size(mesh.coords,1);

% 4. Type of Dataset ( can be STRUCTURED_POINTS, STRUCTURED_GRID,
% UNSTRUCTURED_GRID, POLYDATA, RECTILINEAR_GRID or FIELD )
% This part, dataset structure, begins with a line containing the
% keyword 'DATASET' followed by a keyword describing the type of dataset.
% Then the geomettry part describes geometry and topology of the dataset.

fprintf(fid, 'DATASET UNSTRUCTURED_GRID\n');

%WRITE POINT DATA
fprintf(fid, ['POINTS ' num2str(n_coords) ' float\n']);
output = mesh.coords';

if ~binaryflag
    %spec = ['%0.', precision, 'f '];
    spec = '%2.4f %2.4f %2.4f \n';
    fprintf(fid, spec, output);
else
    fwrite(fid, output, 'float', 'b');
end

%WRITE CONNECTIVITY MATRIX
n_elems = size(mesh.elems,1);
output = [ones(n_elems,1)*size(mesh.elems,2) ,mesh.elems-1]';
fprintf(fid, ['CELLS ' num2str(n_elems) ' ' num2str(numel(output)) '\n']);

spec = '%i %i %i %i %i \n';
fprintf(fid, spec, output);

%WRITE CELL TYPES 
fprintf(fid, ['CELL_TYPES ' num2str(n_elems) '\n']);

if mesh.type == "quadrangle"
    celltype = 9;
elseif mesh.type == "triangle"
    celltype = 5;
end

output = ones(n_elems,1)*celltype;
spec = '%i \n';
fprintf(fid, spec, output);


% 5.This final part describe the dataset attributes and begins with the
% keywords 'POINT_DATA' or 'CELL_DATA', followed by an integer number
% specifying the number of points of cells. Other keyword/data combination
% then define the actual dataset attribute values.
fprintf(fid, ['\nPOINT_DATA ' num2str(n_coords)]);

% Parse remaining argument.
vidx = find(strcmpi(varargin,'VECTORS'));
sidx = find(strcmpi(varargin,'SCALARS'));

if vidx~=0
    for ii = 1:length(vidx)
        title = varargin{vidx(ii)+1};
        % Data enteries begin with a keyword specifying data type
        % and numeric format.
        fprintf(fid, ['\nVECTORS ', title,' float\n']);
        output = [varargin{ vidx(ii) + 2 }(:)';...
                  varargin{ vidx(ii) + 3 }(:)';...
                  varargin{ vidx(ii) + 4 }(:)'];
        if ~binaryflag
            spec = ['%0.', precision, 'f '];
            fprintf(fid, spec, output);
        else
            fwrite(fid, output, 'float', 'b');
        end
    end
end

if sidx~=0
    for ii = 1:length(sidx)
        title = varargin{sidx(ii)+1};
        fprintf(fid, '\nSCALARS '+ title+' float\n');
        fprintf(fid, 'LOOKUP_TABLE default\n');
        if ~binaryflag
            spec = ['%0.', precision, 'f \n'];
            fprintf(fid, spec, varargin{ sidx(ii) + 2});
        else
            fwrite(fid, varargin{ sidx(ii) + 2}, 'float', 'b');
        end
    end
        
           
end
fclose(fid);

end

function setdataformat(fid, binaryflag)
if ~binaryflag
    fprintf(fid, 'ASCII\n');
else
    fprintf(fid, 'BINARY\n');
end
end
    