function params = mk_pc_param(pc_params_size, type)

% Memory allocation
params = cell(pc_params_size, 1);
e_params = zeros(pc_params_size, 1);
p_params = zeros(pc_params_size, 1);

% Parameter calculation
real_hann = hann(pc_params_size)/pc_params_size;

for i = 1:pc_params_size
    params{i} = fi(real_hann(i), type); % PC params conversion
    e_params(i) = abs(abs(double(params{i})) - abs(real_hann(i))); % Calculate error
    p_params(i) = 100 * e_params(i) / abs(real_hann(i)); % Percentage error
end

% Store values
save('variables/real_hann', 'real_hann')
save('variables/e_hann', 'e_params')
save('variables/p_hann', 'p_params')

end

