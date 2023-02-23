function y = bhvr_preproc(y)

% function y = bhvr_preproc(y)
%
% Pre-processing of behavioral orientation labels for a von Mises mixture
% model. Takes as input values in degrees between 0° and 180° and
% returns as output the corresponding values in radians in the range -pi to
% pi.
%
% Input: 
%   - y: an N x 1 vector of angles (degree, 0 <= y <= 180)
% 
% Output:
%   - y: an N x 1 vector of pre-processed angles (radians, -pi <= y <= pi)
%
% Simon Weber, sweber@bccn-berlin.de, 2021

% Transform row to column vector
if size(y,1) == 1, y = y'; end

% Remove NaN values
y(isnan(y)) = [];

% Project data onto entire circle (i.e. 0 <= y <= 180 to 0 <= y <= 360)
y = y .* 2;

% Transform degree to radians
y = deg2rad(y);

% Wrap to -pi <= y <= pi
y = mod(y + pi, 2*pi) - pi;

