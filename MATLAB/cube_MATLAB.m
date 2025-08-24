%% AESA RADAR FIXED POINT MODEL
% David Ramón Alamán

%% INITIALIZATION
t_start = tic;

% Progress bar
multiWaitbar('CloseAll');
multiWaitbar('AESA Radar Fixed Point Model', 0);
multiWaitbar('AESA Radar Fixed Point Model', 'Color', [0, 0.486, 0.761]);

% Global variables and parameters
nA = 16;    % Number of antennas
nb = 32;    % Number of bins
nB = 8;     % Number of beams
nFFT = 256; % Number of pulses

pc_params_size = 5; % Hanning window size = 5
save('variables/aesa_params', 'nA', 'nb', 'nB', 'nFFT', 'pc_params_size'); % Save variables to file

% Waitbar parameters
steps = 9; % Number of waitbar update point
increment = 1/steps; % Increment per update point
c_step = increment; % Current progress
blue = [0, 0.486, 0.761]; % Waitbar color

% Fixed Point configuration
GFI = globalfimath('RoundMode','Floor','OverflowMode','Wrap'); % fimath definition, simulate HW behaviour on cropping and overflow 

i_type = numerictype(1,16,15); % Input data resolution
type = numerictype(1,20,19);   % Internal crop (after each stage)
h_type = i_type;               % Hanning window resolution

% Update waitbar after init section
multiWaitbar('AESA Radar Fixed Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): Variables set\n", toc(t_start));

%% IMPORT DATA
importCube % Import AESA_INPUT.csv -> output var = cube_fp (floating point)
save('variables/cube_fp', 'cube_fp'); % Save variable to file
importDBFParams % Import beamConsts.csv -> output var = dbf_params_fp (floating point)
save('variables/dbf_params_fp', 'dbf_params_fp'); % Save variable to file

% Update waitbar after import data
multiWaitbar('AESA Radar Fixed Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): Data imported\n", toc(t_start));

%% CUBE FLOATING POINT TO FIXED POINT CONVERSION
cube = generate_cube (nA, nb, nFFT, i_type, cube_fp); % floating cube to fixed cube
save('variables/cube', 'cube'); % Save variable to file
clear cube_fp

% Update waitbar after cube floating to fixed conversion
multiWaitbar('AESA Radar Fixed Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): Cube conversion done\n", toc(t_start));

%% DBF PARAMS FLOATING POINT TO FIXED POINT CONVERSION
%dbf_params = mk_dbf_param(nA, nB, i_type, dbf_params_fp); % floating to fixed
dbf_params = mk_dbf_param(nA, nB, type, dbf_params_fp); % floating to fixed
save('variables/dbf_params', 'dbf_params'); % Save variable to file
clear dbf_params_fp

% Update waitbar after dbf_params floating to fixed conversion
multiWaitbar('AESA Radar Fixed Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): DBF parameter conversion done\n", toc(t_start));

%% PC PARAMS
pc_params = mk_pc_param(pc_params_size, h_type); % Create pc parameters
save('variables/pc_params', 'pc_params'); % Save variable to file

% Update waitbar after pc_params 
multiWaitbar('AESA Radar Fixed Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): PC params done\n", toc(t_start));

%% DBF STAGE
dbf_fo = dbf(nA, nb, nB, nFFT, cube, dbf_params); % dbf stage
save('variables/dbf_fo', 'dbf_fo');
clear cube
clear dbf_params

% Update waitbar after DBF
multiWaitbar('AESA Radar Fixed Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): DBF stage done\n", toc(t_start));

%% DBF CROPPING
% DBF Croppoing progress bar
multiWaitbar('DBF Cropping', 0);
multiWaitbar('DBF Cropping', 'Color', blue);

dbf_o = cell(nB, nb, nFFT); % Allocate space for dbf_o
for i = 1:nB
    for j = 1:nb
        for k = 1:nFFT
            dbf_o{i,j,k} = fi(dbf_fo{i,j,k}, type); % Crop dbf exit to type
        end
    end
    multiWaitbar('DBF Cropping', i/nB); % update progress bar
end
multiWaitbar('DBF Cropping', 'Close');

save('variables/dbf_o', 'dbf_o') % Save variable to file
clear dbf_fo

% Update waitbar after DBF cropping
multiWaitbar('AESA Radar Fixed Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): DBF Cropping done\n", toc(t_start));

%% PC STAGE
pc_fo = pc(nb, nB, nFFT, dbf_o, pc_params, pc_params_size);
save('variables/pc_fo', 'pc_fo')
clear pc_params

% Update waitbar after PC stage
multiWaitbar('AESA Radar Fixed Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): PC stage done\n", toc(t_start));

%% PC CROPPING
% Progress bar
multiWaitbar('PC Cropping', 0);
multiWaitbar('PC Cropping', 'Color', blue);

pc_o = cell(nb, nB, nFFT); % Allocate space for pc_o
for i = 1:nb
    for j = 1:nB
        for k = 1:nFFT
            pc_o{i,j,k} = fi(pc_fo{i,j,k}, type); % Crop pc output to type
        end
    end
    multiWaitbar('PC Cropping', i/nb); % Update progres bar
end
multiWaitbar('PC Cropping', 'Close');

save('variables/pc_o', 'pc_o') % Save variable to file

% Update progress bar
multiWaitbar('AESA Radar Fixed Point Model', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): PC cropping done\ncube_MATLAB.m completed\n", toc(t_start));

% Clean up
multiWaitbar('AESA Radar Fixed Point Model', 'Close');
clear all