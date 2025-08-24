function dbf_o = dbf_double (nA, nb, nB, nFFT, cube, dbf_params)
    
    % Allocate memory
    nAnB_mat = cell(nA,nB,nb,nFFT);
    dbf_o = cell(nB,nb,nFFT);
    
    % Progress bar
    multiWaitbar('DBF', 0);
    multiWaitbar('DBF', 'Color', [0, 0.486, 0.761]);

    for k = 1:nFFT
        for j = 1:nb

            for i = 1:nA % >>> mapMat
                for ii = 1:nB % >>> mapV(copyV nB) and zipWithMat (*)
                    nAnB_mat{i,ii,j,k} = mult_complex_fi(cube{i,j,k}, dbf_params{i,ii});
                end
            end
            
            % >>> reduceV (zipWithV f) == mapV (reduceV f) . transposeMat
            for ii = 1:nB % >>> mapV
                dbf_o{ii,j,k} = nAnB_mat{1,ii,j,k};
                for i = 2:nA
                    dbf_o{ii,j,k} = dbf_o{ii,j,k} + nAnB_mat{i,ii,j,k}; % >>> reduceV (+)
                end
            end
        end
        multiWaitbar('DBF', k/nFFT); % update progress bar
    end
    multiWaitbar('DBF', 'Close');
end