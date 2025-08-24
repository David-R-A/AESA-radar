function filter_o = mav(nb, pc_in, pc_params, pc_params_size)
    filter_o = cell(nb,1);

    for i = 1:nb
        helper = 0;
        for j = pc_params_size:-1:(max(1, pc_params_size-i+1))
            helper = helper + (pc_params{j} * pc_in{min(i-pc_params_size+j,nb-(pc_params_size-j))});
        end
        filter_o{i} = helper;
    end
end