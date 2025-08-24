function cube = generate_cube (x, y, z, type, cube_fp)

% Memory allocation
cube = cell(x,y,z); 

% Progress bar
multiWaitbar('Generate Cube', 0);
multiWaitbar('Generate Cube', 'Color', [0, 0.486, 0.761]);

for k = 1:z
    for j = 1:y
        for i = 1:x
            cube{i,j,k} = fi([cube_fp((k-1)*y+j,i*2-1),cube_fp((k-1)*y+j,i*2)], type); % Convert cube
        end
    end
    multiWaitbar('Generate Cube', k/z); % Update timing bar
end

% clean up
multiWaitbar('Generate Cube', 'Close');