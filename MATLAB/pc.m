function pc_o = pc(nb, nB, nFFT, dbf_o, pc_params, pc_params_size)

pc_o = cell(nb,nB,nFFT);

multiWaitbar('PC', 0);
multiWaitbar('PC', 'Color', [0, 0.486, 0.761]);

for k = 1:nFFT

    for i = 1:nB
        pc_o(:,i,k) = mav(nb, dbf_o(i,:,k), pc_params, pc_params_size);
    end
    multiWaitbar('PC', k/nFFT);
end
multiWaitbar('PC', 'Close');

end

