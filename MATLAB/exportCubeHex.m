%% AESA RADAR EXPORT CUBE TO CSV (BINARY)
% David Ramón Alamán

%% FUNCTION exportCube
% Args:
%   - var: Name of the variable to export (must exist as a save workspace
%          in the "variables" folder
%   - filename: Name of the output file (must include extension)

function exportCubeHex(var, filename)

%% INTIALIZATION
% Strings creation
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

%% CREATE MATRIX TO EXPORT
for k = 1:var_size(3)
    for j = 1:var_size(2)
        for i = 1:var_size(1)
            fprintf(fileID, [strrep(data{i,j,k}.hex,'   ',' ') ' ']);
        end
        fprintf(fileID, "\n");
    end
end

fclose(fileID);

end