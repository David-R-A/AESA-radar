%% AESA RADAR EXPORT MATRIX TO CSV (BINARY)
% David Ramón Alamán

%% FUNCTION exportCube
% Args:
%   - var: Name of the variable to export (must exist as a save workspace
%          in the "variables" folder
%   - filename: Name of the output file (must include extension)

function exportMatrixBin(var, filename)

%% INTIALIZATION
% Strings creation
vhdlfilename = strcat('export/vhdl_', filename);
filename = strcat('export/', filename);
var_name = strcat('variables/', var, '.mat');

% Variable load
load(var_name, "*");

% Get data from variable name
data = eval(var);

% Get data size
var_size = size(data);

% Open file
fileID = fopen(filename, 'w');
if fileID < 0
    errmsg = strcat('Could not open file', filename);
    error(errmsg);
end
fileIDvhdl = fopen(vhdlfilename, 'w');
if fileIDvhdl < 0
    errmsg = strcat('Could not open file', vhdlfilename);
    error(errmsg);
end

%% CREATE MATRIX TO EXPORT

for j = 1:var_size(2)
    for i = 1:var_size(1)
        fprintf(fileID, [strrep(data{i,j}.bin,'   ',' ') ' ']);
        fprintf(fileIDvhdl, strrep(data{i,j}.bin,' ','')); % Without spaces (for sim)
    end
    fprintf(fileID, "\n");
    fprintf(fileIDvhdl, "\n");
end

fclose(fileID);
fclose(fileIDvhdl);

end