%% AESA RADAR FIXED POINT MODEL
% David Ramón Alamán

%% INITIALIZATION
t_start = tic;

% Progress bar
multiWaitbar('CloseAll');
multiWaitbar('AESA Radar Double Precision Floating Point Model', 0);
multiWaitbar('AESA Radar Double Precision Floating Point Model', 'Color', [0, 0.486, 0.761]);

% Global variables and parameters
nA = 16;    % Number of antennas
nb = 32;    % Number of bins
nB = 8;     % Number of beams
nFFT = 256; % Number of pulses

pc_params_size = 5; % Hanning window size = 5
save('variables_double/aesa_params', 'nA', 'nb', 'nB', 'nFFT', 'pc_params_size'); % Save variables to file

% Waitbar parameters
steps = 9; % Number of waitbar update point
increment = 1/steps; % Increment per update point
c_step = increment; % Current progress
blue = [0, 0.486, 0.761]; % Waitbar color

% Update waitbar after init section
multiWaitbar('AESA Radar Double Precision Floating Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): Variables set\n", toc(t_start));

%% IMPORT DATA
importCube % Import AESA_INPUT.csv -> output var = cube_fp (floating point)
save('variables_double/cube_fp', 'cube_fp'); % Save variable to file
importDBFParams % Import beamConsts.csv -> output var = dbf_params_fp (floating point)
save('variables_double/dbf_params_fp', 'dbf_params_fp'); % Save variable to file

% Update waitbar after import data
multiWaitbar('AESA Radar Double Precision Floating Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): Data imported\n", toc(t_start));

%% CUBE FORMATING
cube_d = generate_cube_double (nA, nb, nFFT, cube_fp); % floating cube to fixed cube
save('variables_double/cube', 'cube_d'); % Save variable to file
clear cube_fp

% Update waitbar after cube floating to fixed conversion
multiWaitbar('AESA Radar Double Precision Floating Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): Cube conversion done\n", toc(t_start));

%% DBF PARAMS FORMATING
dbf_params_d = mk_dbf_param_double (nA, nB, dbf_params_fp); % floating to fixed
save('variables_double/dbf_params', 'dbf_params_d'); % Save variable to file
clear dbf_params_fp

% Update waitbar after dbf_params floating to fixed conversion
multiWaitbar('AESA Radar Double Precision Floating Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): DBF parameter conversion done\n", toc(t_start));

%% PC PARAMS
pc_params_d = mk_pc_param_double(pc_params_size); % Create pc parameters
save('variables_double/pc_params', 'pc_params_d'); % Save variable to file

% Update waitbar after pc_params 
multiWaitbar('AESA Radar Double Precision Floating Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): PC params done\n", toc(t_start));

%% DBF STAGE
dbf_o_d = dbf_double(nA, nb, nB, nFFT, cube_d, dbf_params_d); % dbf stage
save('variables_double/dbf_o', 'dbf_o_d');
clear cube_d
clear dbf_params_d

% Update waitbar after DBF
multiWaitbar('AESA Radar Double Precision Floating Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): DBF stage done\n", toc(t_start));

%%  TODO - PC STAGE
pc_o_d = pc(nb, nB, nFFT, dbf_o_d, pc_params_d, pc_params_size);
save('variables_double/pc_o', 'pc_o_d')
clear pc_params_d

% Update waitbar after PC stage
multiWaitbar('AESA Radar Double Precision Floating Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): PC stage done\n", toc(t_start));
fprintf("cube_MATLAB.m completed\n");

% Clean up
multiWaitbar('AESA Radar Double Precision Floating Point Model', 'Close');
clear all