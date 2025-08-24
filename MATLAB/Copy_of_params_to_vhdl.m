%% PARAMS TO VHDL PACKAGE PARSER
% David Ramón Alamán

%% INTIALIZATION

% Package name
pkg_name = "params_pkg";

% Variable load
load("variables\dbf_params.mat");

% Get data size
var_size = size(dbf_params);

% Open file
filename = strcat('export/', pkg_name, '.vhd');
fileID = fopen(filename, 'w');
if fileID < 0
    errmsg = strcat('Could not open file', filename);
    error(errmsg);
end

%% VHDL HEADER
fprintf(fileID, ...
"library ieee;\n" + ...
"use ieee.std_logic_1164.all;\n" + ...
"use ieee.numeric_std.all;\n" + ...
"\n" + ...
"library work;\n" + ...
"use work.devkit_lib.all;\n" + ...
"\n" + ...
"package " + pkg_name + " is\n");

%% EXPORT DBF PARAMS
if dbf_params{1,1}.WordLength == 16
    type = 'complex_in_matrix';
else
    type = 'complex_int_matrix';
end

fprintf(fileID, ...
"\t-- DBF Params\n" + ...
"\tconstant DBF_PARAMS : " + type + "(nA-1 downto 0, nB-1 downto 0) := (\n");

for j = 1:var_size(1)
    fprintf(fileID, ...
    "\t\t%d => (\n", j-1);
    for i = 1:var_size(2)
        bin_values = split(strrep(dbf_params{j,i}.bin,'   ',' '));
        fprintf(fileID, ...
        '\t\t\t%d => (r => "%s", i => "%s")', i-1, bin_values{1}, bin_values{2});  
        
        if i == var_size(2)
            fprintf(fileID, "\n");
        else
            fprintf(fileID, ",\n");
        end
    end
    
    if j == var_size(1)
            fprintf(fileID, "\t\t)\n");
    else
        fprintf(fileID, "\t\t),\n");
    end
end

fprintf(fileID, ...
"\t);\n");

%% VHDL FOOTER
fprintf(fileID, "end package " + pkg_name + ";");

fclose(fileID);