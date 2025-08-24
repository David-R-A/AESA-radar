%% AESA RADAR EXPORT CUBE TO CSV (BINARY)
% David Ramón Alamán

%% FUNCTION exportCube
% Args:
%   - var: Name of the variable to export (must exist as a save workspace
%          in the "variables" folder
%   - filename: Name of the output file (must include extension)

function exportResult(filename)

%% INTIALIZATION
% Strings creation
var = 'pc_o';
vhdlfilename = strcat('export/vhdl_', filename);
var_name = strcat('variables/', var, '.mat');

% Variable load
load(var_name, "*");

% Get data from variable name
data = eval(var);

% Get data size
var_size = size(data);

% Open file
fileIDvhdl = fopen(vhdlfilename, 'w');
if fileIDvhdl < 0
    errmsg = strcat('Could not open file', vhdlfilename);
    error(errmsg);
end

%% CREATE MATRIX TO EXPORT
for k = 1:var_size(3)
    for j = 1:var_size(2)
        for i = 1:var_size(1)
            re = data{i,j,k}(1);
            im = data{i,j,k}(2);
            fprintf(fileIDvhdl, strcat("000000000000", strrep(re.bin,' ',''),...
                "000000000000", strrep(im.bin,' ','')));
        end
        fprintf(fileIDvhdl, "\n");
    end
end

fclose(fileIDvhdl);

end