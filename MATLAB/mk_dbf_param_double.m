function dbf_params = mk_dbf_param_double(nA, nB, dbf_params_fp)

% Progress bar
multiWaitbar('Generate DBF params', 0);
multiWaitbar('Generate DBF params', 'Color', [0, 0.486, 0.761]);

% Memory Allocation
dbf_params = cell(nA, nB);

for i = 1:nA
    for j = 1:nB
        dbf_params{i,j} = [dbf_params_fp(i,j*2-1), dbf_params_fp(i,j*2)]; % Format DBF params
    end

    multiWaitbar('Generate DBF params', i/nA); % Update timing bar
end

% Clean up
multiWaitbar('Generate DBF params', 'Close');

end

