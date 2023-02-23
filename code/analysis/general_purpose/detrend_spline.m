function data_detrended = detrend_spline(data, n_nodes)

% function data = detrend_spline(data, n_nodes)
% 
% Remove slow temporal drifts from the data of each voxel using cubic
% spline interpolation.
%
% Input:
%   - data: [n_tr, n_voxel, n_run] array with data.
%   - n_nodes: Number of nodes for spline fitting (recommended:
%       n_trials/2).
%
% Output:
%   - data_detrended: [n_tr, n_voxel, n_run] array with detrended data.
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Initialize output variable
data_detrended = zeros(size(data));

% Get data dimensions
n_tr = size(data,1);
n_vox = size(data,2);
n_run = size(data,3);

% Create nodes indices and node-boundry distance (edge)
x_n = round(linspace(1,n_tr,n_nodes));
edge = floor(max(diff(x_n))/2);

% For each run...
for i_run = 1:n_run
    
    fprintf('Detrending voxels of run %d/%d ...\n', i_run, n_run);

    % For each voxel...
    % Detrend voxels in parallel for speed
    for i_vox = 1:n_vox
%     parfor i_vox = 1:n_vox

        % Get data for current run and voxel
        v = data(:,i_vox,i_run);

        % Initialize indices of current segment
        y_n = zeros(1,n_nodes);

        % Create segment surrounding each node index (size determined by
        % 'edge'), then average the voxel data within that segment to
        % create node for spline fitting.
        for i_n = 1:n_nodes
            i_neg = x_n(i_n)-edge;
            i_pos = x_n(i_n)+edge;

            if i_neg<1, i_neg=1; end
            if i_pos>n_tr, i_pos=n_tr; end

            y_n(i_n) = mean(v(i_neg:i_pos));
        end

        % Fit cubic spline through the created nodes
        y = spline(x_n,y_n,1:n_tr);
        
        % Detrend data by subtracting the spline fit from the original data
        v_new = v-y';
        
        % Assign detrended data to output variable
        data_detrended(:,i_vox,i_run) = v_new;
    end

end
