%% AESA RADAR EXPORT CUBE TO CSV
% David Ramón Alamán

%% FUNCTION exportCube
% Args:
%   - var: Name of the variable to export (must exist as a save workspace
%          in the "variables" folder
%   - filename: Name of the output file (must include extension)

function exportCube(var, filename)

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

% Allocate memory
data_matrix = zeros(var_size(2) * var_size(3), 2 * var_size(1));

%% CREATE MATRIX TO EXPORT
for k = 1:var_size(3)
    for j = 1:var_size(2)
        for i = 1:var_size(1)
            data_matrix(j + (k-1)*var_size(2), 2*i-1) = double(data{i,j,k}(1));
            data_matrix(j + (k-1)*var_size(2), 2*i)   = double(data{i,j,k}(2));
        end
    end
end

%% EXPORT TO CSV
writematrix(data_matrix, filename,'Delimiter','space');

end