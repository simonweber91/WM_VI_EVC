function new_data = feature_space_smoothing(data, labels, fwhm)

% function new_data = feature_space_smoothing(data, labels, fwhm)
% 
% Moves over a continuous feature-space and computes the average of the
% signal of neighboring features, where neighboring features are weighted
% using a Gaussian kernel. 
%
% Input:
%   - data: Up to 4D array, where the first dimension are the features and
%       the second dimension is the signal. Dimensions 3-4 can be e.g. runs
%       or TRs.
%   - labels: 2-D matrix with feature labels, where rows are trials and
%       columns are runs.
%   - fwhm: full-width half maximum (in degrees) to calculate the Gaussian
%       used for smoothing. Determines the width of the smoothing kernel.
%
% Output:
%   - new_data: Up to 4D array (same dimensions as 'data') with processed
%       data.
%
% Simon Weber, BCCN Berlin, 15.01.2021
% edit 13.08.2021, SW: deal with NaNs in labels, labels do not have to be
% sorted

% Check if 'fwhm' is positive
if fwhm < 0
    error('''fwhm'' is negative, please use positive value.');
elseif fwhm == 0
    warning('''fwhm'' is zero, no feature-space smoothing applied, continue.');
    new_data = data;
    return;
end

fprintf('Running feature space smoothing with FWHM of %d ...\n', fwhm);

%%% Initialize smoothing kernel%%%
% 
% % Initialize periodic range, i.e. 1-360 degrees
% x = 1:360;
% x = x-numel(x)/2;
% % Calculate sigma from fwhm
% sigma = fwhm/(2*sqrt(2*log(2)));
% % Compute probability density function (pdf) at x
% y = normpdf(x,0,sigma);
% % Scale to 1
% y = y.*1/max(y);
% % Center at 1
% y = circshift(y,numel(y)/2+1);
% % figure;plot(x,y)

% Calculate kappa from fwhm
% k = (8*log(2))/fwhm^2;  % FWHM defined in terms of Gaussian distribution
k = - log(2) / (cos(deg2rad(fwhm)/2) - 1);  % FWHM defined in terms of von Mises distribution
mu = 0;

%%% Perform feature-space smoothing %%%

% % Get relevant data diemension
% sz = size(data,1);

% Initialize output variable with NaNs (in case of NaN labels)
new_data = nan(size(data));

for d4 = 1:size(data,4)         % in case data has up to 4 dimensions (run & TRs)
for d3 = 1:size(data,3)         % loop through runs
    
%     % Get current labels and accout for zeros
%     curr_labels = round(labels(:,d3));
%     curr_labels(curr_labels==0) = 1;
    curr_labels = labels(:,d3);
    
    % Take only valid labels (exclude NaNs)
    valid = find(~isnan(curr_labels));

    x = curr_labels(valid);
    W = 1/(2*pi*besseli(0,k)) * exp(k*cos((x-x')-mu));
    % Scale weights so that sum of weights is always 1
    W = W./sum(W);
    % [ls, si] = sort(l);
    % W_sort = W(si,si);
    % figure,imagesc(W_sort),colorbar
    
    % Compute weighted average of the data corresponding to the current
    % label and its neighbors in the feature-space
    new_data(valid,:,d3,d4) = W' * data(valid,:,d3,d4);


%     % For each label/feature
%     for i = 1:sz
%         
%         % Skip missing labels
%         if isnan(curr_labels(i))
%             continue;
%         end
%         
%         % Shift kernel to current index
%         curr_y = circshift(y, curr_labels(i)-1);
%         
%         % Get weights
%         w = curr_y(curr_labels(valid));
% 
%         % Scale weights so that sum of weights is always 1
%         w = w./sum(w);
% 
%         % Compute weighted average of the data corresponding to the current
%         % label and its surroundings
%         new_data(i,:,d3,d4) = nansum(data(valid,:,d3,d4).*w');
%     end

end
end
