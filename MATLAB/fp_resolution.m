%% AESA RADAR DATA TYPE RESOLUTION
% David Ramón Alamán

%% INITIALIZATION
t_start = tic;

% Progress bar
multiWaitbar('CloseAll');
multiWaitbar('AESA Radar Data Type Resolution', 0);
multiWaitbar('AESA Radar Data Type Resolution', 'Color', [0, 0.486, 0.761]);

multiWaitbar('Variable loading', 0);
multiWaitbar('Variable loading', 'Color', [0, 0.486, 0.761]);

% Global variables and parameters
load('variables/aesa_params.mat') 
multiWaitbar('Variable loading', 0.25);
load('variables/cube.mat')
multiWaitbar('Variable loading', 0.50);
load('variables/dbf_o.mat')
multiWaitbar('Variable loading', 0.75);
load('variables/pc_o.mat')
multiWaitbar('Variable loading', 1.00);
multiWaitbar('Variable loading', 'Close');

cube_vector = zeros(2*nA*nb*nFFT,1);
dbf_vector = zeros(2*nB*nb*nFFT,1);
pc_vector = zeros(2*nB*nb*nFFT,1);

% Waitbar parameters
steps = 5; % Number of waitbar update point
increment = 1/steps; % Increment per update point
c_step = increment; % Current progress
blue = [0, 0.486, 0.761]; % Waitbar color

% Update waitbar after init section
multiWaitbar('AESA Radar Data Type Resolution', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): Variables set\n", toc(t_start));

%% HISTOGRAM DATA PREPARATION

% Progress bar cube
multiWaitbar('Cube', 0);
multiWaitbar('Cube', 'Color', blue);

% Cube
for k = 1:nFFT
    for j = 1:nb
        for i = 1:nA
            cube_vector(2*i-1 + (j-1)*2*nA + (k-1)*nb*2*nA) = cube{i,j,k}(1);
            cube_vector(2*i   + (j-1)*2*nA + (k-1)*nb*2*nA) = cube{i,j,k}(2);
        end
    end
    multiWaitbar('Cube', k/nFFT);
end
multiWaitbar('Cube', 'Close');

% Update waitbar
multiWaitbar('AESA Radar Data Type Resolution', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): Cube done\n", toc(t_start));

% Progress bar cube
multiWaitbar('DBF', 0);
multiWaitbar('DBF', 'Color', blue);

for k = 1:nFFT
    for j = 1:nb
        for i = 1:nB
            dbf_vector(2*i-1 + (j-1)*2*nB + (k-1)*nb*2*nB) = dbf_o{i,j,k}(1);
            dbf_vector(2*i   + (j-1)*2*nB + (k-1)*nb*2*nB) = dbf_o{i,j,k}(2);
        end
    end
    multiWaitbar('DBF', k/nFFT);
end
multiWaitbar('DBF', 'Close');

% Update waitbar
multiWaitbar('AESA Radar Data Type Resolution', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): DBF done\n", toc(t_start));

% Progress bar cube
multiWaitbar('PC', 0);
multiWaitbar('PC', 'Color', blue);

for k = 1:nFFT
    for j = 1:nB
        for i = 1:nb
            pc_vector(2*i-1 + (j-1)*2*nb + (k-1)*nB*2*nb) = pc_o{i,j,k}(1);
            pc_vector(2*i   + (j-1)*2*nb + (k-1)*nB*2*nb) = pc_o{i,j,k}(2);
        end
    end
    multiWaitbar('PC', k/nFFT);
end
multiWaitbar('PC', 'Close');

% Update waitbar
multiWaitbar('AESA Radar Data Type Resolution', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): PC done\n", toc(t_start));

%% RESOLUTION CALCULATION

x = logspace(-5, 0, 1000); % Distribute points interval [10^-5, 1]
x_single = single([-1*(x(end:-1:1)),x]); % Extend interval to [-1,1] and cast to single
resolution = -1*log2(eps(x_single)); % Obtain resolution in equivalent fixed point number of bits

%% PLOTS

% Cube plot
figure; 
hold on;
histogram(cube_vector, 125, 'Normalization', 'percentage');
xlabel('Cube values (Real and Imaginary)');
ylabel('Percentage [%]');
title('Value distribution - Input Cube');
grid on;
limsx=get(gca,'XLim');
yyaxis right
plot(x_single,resolution,'linewidth',2);
plot([-1,1],[15,15],'linewidth',2)
limsy=get(gca,'YLim');
set(gca,'Ylim',[2 limsy(2)]);
set(gca,'Xlim',limsx);
ylabel('Resolution (bits)');
yyaxis left
legend('Value distribution', 'IEEE 754 - binary32', 'Fixed point')

% DBF plot
figure; hold on;
histogram(dbf_vector, 125, 'Normalization', 'percentage');
xlabel('DBF output values (Real and Imaginary)');
ylabel('Percentage [%]');
title('Value distribution - DBF Output Cube');
grid on;
yyaxis right
limsx=get(gca,'XLim');
plot(x_single,resolution,'linewidth',2)
plot([-1,1],[19,19],'linewidth',2)
limsy=get(gca,'YLim');
set(gca,'Ylim',[2 limsy(2)]);
set(gca,'Xlim',limsx);
ylabel('Resolution (bits)');
yyaxis left
legend('Value distribution', 'IEEE 754 - binary32', 'Fixed point')

% PC plot
figure; hold on;
histogram(pc_vector, 125, 'Normalization', 'percentage');
xlabel('PC output values (Real and Imaginary)');
ylabel('Percentage [%]');
title('Value distribution - PC Output Cube');
grid on;
yyaxis right
limsx=get(gca,'XLim');
plot(x_single,resolution,'linewidth',2)
plot([-1,1],[19,19],'linewidth',2)
limsy=get(gca,'YLim');
set(gca,'Ylim',[2 limsy(2)]);
set(gca,'Xlim',limsx);
ylabel('Resolution (bits)');
yyaxis left
legend('Value distribution', 'IEEE 754 - binary32', 'Fixed point')

% DBF + PC plot
figure; hold on;
histogram([dbf_vector, pc_vector], 125, 'Normalization', 'percentage');
xlabel('DBF + PC output values (Real and Imaginary)');
ylabel('Percentage [%]');
title('Value distribution - DBF + PC Output Cube');
grid on;
yyaxis right
limsx=get(gca,'XLim');
plot(x_single,resolution,'linewidth',2)
plot([-1,1],[19,19],'linewidth',2)
limsy=get(gca,'YLim');
set(gca,'Ylim',[2 limsy(2)]);
set(gca,'Xlim',limsx);
ylabel('Resolution (bits)');
yyaxis left
legend('Value distribution', 'IEEE 754 - binary32', 'Fixed point')

% Update waitbar
multiWaitbar('AESA Radar Data Type Resolution', c_step);
c_step = c_step + increment;

% Timing
fprintf("(%f s): DBF + PC done\n", toc(t_start));

% Clean up
clear all
multiWaitbar('CloseAll');