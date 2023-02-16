function eye_ds = eye_downsample_data(eye, p)

% Get downsampling factor
ds_factor = p.eye.ds_factor;

% Downsample
eye_ds = zeros(size(eye,1), size(eye,2), size(eye,3), size(eye,4)/ds_factor);
for i = 1:size(eye,1)
    for j = 1:size(eye,2)
        for k = 1:size(eye,3)
            d = eye(i,j,k,:);
            d = downsample(d(:), ds_factor);
            eye_ds(i,j,k,:) = d;
        end
    end
end