function params = mk_pc_param_double(pc_params_size)

% Memory allocation
params = cell(pc_params_size, 1);

% Parameter calculation
real_hann = hann(pc_params_size)/pc_params_size;

for i = 1:pc_params_size
    params{i} = real_hann(i); % PC params conversion
end

% Store values
save('variables_double/real_hann', 'real_hann')

end

