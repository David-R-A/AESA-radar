%% QUANTIZATION ERROR CALCULATION
% David Ramón Alamán
% Comparison between Fixed point and IEEE 754 - binary32 with respect to
% IEEE 754 - binary64

%% INITIALIZATION
t_start = tic;

% Progress bar
multiWaitbar('CloseAll');
blue = [0, 0.486, 0.761]; % Color
multiWaitbar('Error Calculation', 0);
multiWaitbar('Error Calculation', 'Color', blue);
steps = 4; % Number of waitbar update point
increment = 1/steps; % Increment per update point
c_step = increment; % Current progress
multiWaitbar('Error Calculation', c_step/steps); % Update timing bar

fprintf("(%f s): Initialization\n", toc(t_start));

%% CUBE
% Progress bar
multiWaitbar('Cube', 0);
multiWaitbar('Cube', 'Color', blue);

% Load variables
load variables\aesa_params.mat
load variables\cube.mat
load variables\cube_fp.mat
fprintf("(%f s): Cube variables set\n", toc(t_start));

% Memory allocation
e_cube = zeros(nb*nFFT, nA*2);
p_cube = zeros(nb*nFFT, nA*2);

% Error calculation
for k = 1:nFFT
    for j = 1:nb
        for i = 1:nA
            e_cube((k-1)*nb+j,i*2-1) = double(cube{i,j,k}(1)) - cube_fp((k-1)*nb+j,i*2-1); % Calculate error real part
            e_cube((k-1)*nb+j,i*2)   = double(cube{i,j,k}(2)) - cube_fp((k-1)*nb+j,i*2);   % Calculate error imag part
            p_cube((k-1)*nb+j,i*2-1) = abs(100 * e_cube((k-1)*nb+j,i*2-1) / (cube_fp((k-1)*nb+j,i*2-1)));  % Relative error real part
            p_cube((k-1)*nb+j,i*2)   = abs(100 * e_cube((k-1)*nb+j,i*2)   / (cube_fp((k-1)*nb+j,i*2)));    % Relative error imag part
        end
    end
    multiWaitbar('Cube', k/nFFT); % Update timing bar
end

fprintf("(%f s): Cube calculations done\n", toc(t_start));

% Store variables
save('variables/e_cube', 'e_cube')
save('variables/p_cube', 'p_cube')

% Visualization
figure % Absolute error
histogram(e_cube, 101, 'Normalization', 'percentage')
xlabel('Absolute error');
ylabel('Percentage [%]');
title('Quantization absolute error - Input Cube');
grid on;

figure % Relative error
histogram(p_cube, 101, 'Normalization', 'percentage')
xlabel('Relative error [%]');
ylabel('Percentage [%]');
title('Quantization relative error - Input Cube');
grid on;

% Clean up
clear cube cube_fp e_cube p_cube 

multiWaitbar('Cube', 'Close');

c_step = c_step + 1;
multiWaitbar('Error Calculation', c_step/steps); % Update timing bar

fprintf("(%f s): Cube done\n", toc(t_start));

%% DBF PARAMS

% Progress bar
multiWaitbar('DBF Parameters', 0);
multiWaitbar('DBF Parameters', 'Color', blue);

% Load variables
load variables\dbf_params.mat
load variables\dbf_params_fp.mat
fprintf("(%f s): DBF params variables set\n", toc(t_start));

% Memory allocation
e_dbf_params   = zeros(nA, nB*2);
p_dbf_params   = zeros(nA, nB*2);

% Error calculation
for j = 1:nB
    for i = 1:nA
        e_dbf_params(i,j*2-1) = double(dbf_params{i,j}(1)) - dbf_params_fp(i,j*2-1); % Calculate error real part
        e_dbf_params(i,j*2)   = double(dbf_params{i,j}(2)) - dbf_params_fp(i,j*2);   % Calculate error imag part
        p_dbf_params(i,j*2-1) = abs(100 * e_dbf_params(i,j*2-1) / (dbf_params_fp(i,j*2-1)));  % Relative error real part
        p_dbf_params(i,j*2)   = abs(100 * e_dbf_params(i,j*2)   / (dbf_params_fp(i,j*2)));    % Relative error imag part
    end
    multiWaitbar('DBF Parameters', j/nb); % Update timing bar
end

fprintf("(%f s): DBF params calculations done\n", toc(t_start));

% Store variables
save('variables/e_dbf_params', 'e_dbf_params')
save('variables/p_dbf_params', 'p_dbf_params')

% Visualization
figure % Absolute error
histogram(e_dbf_params, 101, 'Normalization', 'percentage')
xlabel('Absolute error');
ylabel('Percentage [%]');
title('Quantization absolute error - DBF Parameters');
grid on;

figure % Relative error
histogram(p_dbf_params, 101, 'Normalization', 'percentage')
xlabel('Relative error [%]');
ylabel('Percentage [%]');
title('Quantization relative error - DBF Parameters');
grid on;

% Clean up
clear dbf_params dbf_params_fp e_dbf_params p_dbf_params 

multiWaitbar('DBF Parameters', 'Close');

c_step = c_step + 1;
multiWaitbar('Error Calculation', c_step/steps); % Update timing bar

fprintf("(%f s): DBF params done\n", toc(t_start));

%% DBF

% Progress bar
multiWaitbar('DBF', 0);
multiWaitbar('DBF', 'Color', blue);

% Load variables
load variables\dbf_o.mat
load variables_double\dbf_o.mat
importDBF
fprintf("(%f s): DBF variables set\n", toc(t_start));

% Memory Allocation
e_dbf   = zeros(nb*nFFT, nB*2);
p_dbf   = zeros(nb*nFFT, nB*2);
e_dbf_f = zeros(nb*nFFT, nB*2);
p_dbf_f = zeros(nb*nFFT, nB*2);

% Error Calculation
for k = 1:nFFT
    for j = 1:nb
        for i = 1:nB
            % Fixed Point
            e_dbf((k-1)*nb+j,i*2-1) = double(dbf_o{i,j,k}(1)) - dbf_o_d{i,j,k}(1); % Calculate error real part
            e_dbf((k-1)*nb+j,i*2)   = double(dbf_o{i,j,k}(2)) - dbf_o_d{i,j,k}(2);   % Calculate error imag part
            p_dbf((k-1)*nb+j,i*2-1) = abs(100 * e_dbf((k-1)*nb+j,i*2-1) / (dbf_o_d{i,j,k}(1)));  % Relative error real part
            p_dbf((k-1)*nb+j,i*2)   = abs(100 * e_dbf((k-1)*nb+j,i*2)   / (dbf_o_d{i,j,k}(2)));    % Relative error imag part

            % IEEE 754 - binary32
            e_dbf_f((k-1)*nb+j,i*2-1) = dbf_fp((k-1)*nb+j,i*2-1) - dbf_o_d{i,j,k}(1); % Calculate error real part
            e_dbf_f((k-1)*nb+j,i*2)   = dbf_fp((k-1)*nb+j,i*2)   - dbf_o_d{i,j,k}(2);   % Calculate error imag part
            p_dbf_f((k-1)*nb+j,i*2-1) = abs(100 * e_dbf_f((k-1)*nb+j,i*2-1) / (dbf_o_d{i,j,k}(1)));  % Relative error real part
            p_dbf_f((k-1)*nb+j,i*2)   = abs(100 * e_dbf_f((k-1)*nb+j,i*2)   / (dbf_o_d{i,j,k}(2)));    % Relative error imag part
        end
    end
    multiWaitbar('DBF', k/nFFT); % Update timing bar
end

fprintf("(%f s): DBF calculations done\n", toc(t_start));

% Store variables
save('variables/e_dbf', 'e_dbf')
save('variables/p_dbf', 'p_dbf')
save('variables/e_dbf_f', 'e_dbf')
save('variables/p_dbf_f', 'p_dbf')

% Visualization - Fixed point
figure % Absolute error
histogram(e_dbf, 101, 'Normalization', 'percentage')
xlabel('Absolute error');
ylabel('Percentage [%]');
title('Quantization absolute error - DBF Output  - Fixed Point');
grid on;

figure % Relative error
histogram(p_dbf, 101, 'Normalization', 'percentage')
xlabel('Relative error [%]');
ylabel('Percentage [%]');
title('Quantization relative error - DBF Output - Fixed Point');
grid on;

% Visualization - Floating point
figure % Absolute error
histogram(e_dbf_f, 101, 'Normalization', 'percentage')
xlabel('Absolute error');
ylabel('Percentage [%]');
title('Quantization absolute error - DBF Output  - IEEE 754 - binary32');
grid on;

figure % Relative error
histogram(p_dbf_f, 101, 'Normalization', 'percentage')
xlabel('Relative error [%]');
ylabel('Percentage [%]');
title('Quantization relative error - DBF Output - IEEE 754 - binary32');
grid on;

% Visualization - Combined
figure % Absolute error
h = histogram(e_dbf, 101, 'Normalization', 'percentage');
binEdges = h.BinEdges;
xlabel('Absolute error');
ylabel('Percentage [%]');
title('Quantization absolute error - DBF Output');
grid on;
hold on;
histogram(e_dbf_f, 101, 'Normalization', 'percentage', 'BinEdges', binEdges)
legend('Fixed point', 'IEEE 754 - binary32')

figure % Relative error
h_fixed = histogram(p_dbf, 101, 'Normalization', 'percentage');
binEdges = h_fixed.BinEdges;
xlabel('Relative error [%]');
ylabel('Percentage [%]');
title('Quantization relative error - DBF Output');
grid on;
hold on;
h_float = histogram(p_dbf_f, 101, 'Normalization', 'percentage', 'BinEdges', binEdges);
legend('Fixed point', 'IEEE 754 - binary32')

dbf_mean = [mean(p_dbf(:)) mean(p_dbf_f(:))];
dbf_median = [median(p_dbf(:)) median(p_dbf_f(:))];

save('variables/dbf_hist', 'h_fixed', 'h_float', 'dbf_mean', 'dbf_median');

% Clean up 
clear dbf_o dbf_fp e_dbf p_dbf e_dbf_f p_dbf_f

multiWaitbar('DBF', 'Close');

c_step = c_step + 1;
multiWaitbar('Error Calculation', c_step/steps); % Update timing bar

fprintf("(%f s): DBF done\n", toc(t_start));

%% PC

% Progress bar
multiWaitbar('PC', 0);
multiWaitbar('PC', 'Color', blue);

% Load variables
load variables\pc_o.mat
load variables_double\pc_o.mat
importPC
fprintf("(%f s): PC variables set\n", toc(t_start));

% Memory allocation
e_pc   = zeros(nB*nFFT, nb*2);
p_pc   = zeros(nB*nFFT, nb*2);
e_pc_f = zeros(nB*nFFT, nb*2);
p_pc_f = zeros(nB*nFFT, nb*2);

% Error calculation
for k = 1:nFFT
    for j = 1:nB
        for i = 2:nb
            % Fixed point
            e_pc((k-1)*nB+j,i*2-1) = double(pc_o{i,j,k}(1)) - pc_o_d{i,j,k}(1); % Calculate error real part
            e_pc((k-1)*nB+j,i*2)   = double(pc_o{i,j,k}(2)) - pc_o_d{i,j,k}(2);   % Calculate error imag part
            p_pc((k-1)*nB+j,i*2-1) = abs(100 * e_pc((k-1)*nB+j,i*2-1) / (pc_o_d{i,j,k}(1)));  % Relative error real part
            p_pc((k-1)*nB+j,i*2)   = abs(100 * e_pc((k-1)*nB+j,i*2)   / (pc_o_d{i,j,k}(2)));    % Relative error imag part

            % IEEE 754 - binary32
            e_pc_f((k-1)*nB+j,i*2-1) = pc_fp((k-1)*nB+j,i*2-1) - pc_o_d{i,j,k}(1); % Calculate error real part
            e_pc_f((k-1)*nB+j,i*2)   = pc_fp((k-1)*nB+j,i*2)   - pc_o_d{i,j,k}(2);   % Calculate error imag part
            p_pc_f((k-1)*nB+j,i*2-1) = abs(100 * e_pc_f((k-1)*nB+j,i*2-1) / (pc_o_d{i,j,k}(1)));  % Relative error real part
            p_pc_f((k-1)*nB+j,i*2)   = abs(100 * e_pc_f((k-1)*nB+j,i*2)   / (pc_o_d{i,j,k}(2)));    % Relative error imag part
        end
    end
    multiWaitbar('PC', k/nFFT); % Update timing bar
end

fprintf("(%f s): PC calculations done\n", toc(t_start));

% Store variables
save('variables/e_dbf', 'e_pc')
save('variables/p_dbf', 'p_pc')
save('variables/e_dbf_f', 'e_pc_f')
save('variables/p_dbf_f', 'p_pc_f')

% Visualization - Fixed point
figure % Absolute error
histogram(e_pc, 101, 'Normalization', 'percentage')
xlabel('Absolute error');
ylabel('Percentage [%]');
title('Quantization absolute error - PC Output  - Fixed Point');
grid on;

figure % Relative error
histogram(p_pc, 101, 'Normalization', 'percentage')
xlabel('Relative error [%]');
ylabel('Percentage [%]');
title('Quantization relative error - PC Output - Fixed Point');
grid on;

% Visualization - Floating point
figure % Absolute error
histogram(e_pc_f, 101, 'Normalization', 'percentage')
xlabel('Absolute error');
ylabel('Percentage [%]');
title('Quantization absolute error - PC Output  - IEEE 754 - binary32');
grid on;

figure % Relative error
histogram(p_pc_f, 101, 'Normalization', 'percentage')
xlabel('Relative error [%]');
ylabel('Percentage [%]');
title('Quantization relative error - PC Output - IEEE 754 - binary32');
grid on;

% Visualization - Combined
figure % Absolute error
h = histogram(e_pc, 101, 'Normalization', 'percentage');
binEdges = h.BinEdges;
xlabel('Absolute error');
ylabel('Percentage [%]');
title('Quantization absolute error - PC Output');
grid on;
hold on;
histogram(e_pc_f, 101, 'Normalization', 'percentage', 'BinEdges', binEdges)
legend('Fixed point', 'IEEE 754 - binary32')

figure % Relative error
h_fixed = histogram(p_pc, 101, 'Normalization', 'percentage');
binEdges = h_fixed.BinEdges;
xlabel('Relative error [%]');
ylabel('Percentage [%]');
title('Quantization relative error - PC Output');
grid on;
hold on;
h_float = histogram(p_pc_f, 101, 'Normalization', 'percentage', 'BinEdges', binEdges);
legend('Fixed point', 'IEEE 754 - binary32')

pc_mean = [mean(p_pc(:)) mean(p_pc_f(:))];
pc_median = [median(p_pc(:)) median(p_pc_f(:))];

save('variables/pc_hist', 'h_fixed', 'h_float', 'pc_mean', 'pc_median');

fprintf("(%f s): PC done\n", toc(t_start));

% Clean up
multiWaitbar('CloseAll');
clear all

fprintf("errorCalc.m completed\n");