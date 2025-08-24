%% AESA RADAR - FILE CONTENTS COMPARATOR 
% David Ramón Alamán

%% FUNCTION compareFiles
% Args:
%   - module: use "DBF" or "PC" to compare DBF simulation results or PC 
%     simulation results

function lines = compareFiles(module)

if upper(module) == "DBF"
   % Strings creation
    vhdlfile = "export/vhdl_dbf_discrete_bin.csv";
    resultfile = "../hdl/dbf/vhdl_dbf_output_results.txt";
elseif upper(module) == "PC"
    % Strings creation
    vhdlfile = "export/vhdl_pc_discrete_bin.csv";
    resultfile = "../hdl/pc/vhdl_pc_output_results.txt";
elseif upper(module) == "AESA"
    % Strings creation
    vhdlfile = "export/vhdl_aesa_discrete_bin.csv";
    resultfile = "../hdl/aesa/vhdl_aesa_output_results.txt";
else 
    vhdlfile = "export/pc_discrete_hex.csv";
    resultfile = "../../aesa_hps_result.txt";
end

% Open files
vhdlfile = fopen(vhdlfile, 'r');
if vhdlfile < 0
    errmsg = strcat('Could not open file', vhdlfile);
    error(errmsg);
end

resultfile = fopen(resultfile, 'r');
if resultfile < 0
    errmsg = strcat('Could not open file', resultfile);
    error(errmsg);
end

lines = []; % Lines that are not equal
line = 1;   % Line index

while ~feof(vhdlfile)
    ref = fgetl(vhdlfile);   % Read lines
    val = fgetl(resultfile); % Read lines

    if ~all(ref == val) % If error add line to error list
        lines = [lines, line];
    end

    if feof(resultfile) && ~feof(vhdlfile) % Check file length is equal
        fprintf("Result file shorter than model.\n");
        break;
    end

    line = line + 1;
end

if ~feof(resultfile) % Check file length is equal
    fprintf("Result file larger than model.\n");
end

if size(lines, 2) == 0 % Output
    fprintf("Not errors found in %d lines.\n", line -1);
else
    fprintf("%d errors found.\n", size(lines, 2));
end

fclose(vhdlfile);
fclose(resultfile);

end