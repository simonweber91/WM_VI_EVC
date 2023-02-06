function [r_est, m_est, k_est, MLL, LF] = bhvr_ML(y, z, mu, kr, m)
% _
% Maximum Likelihood Estimation for a von Mises Mixture Model
% FORMAT [r_est, m_est, k_est, MLL] = ME_vMMM_ML(y, z, mu, kr, m)
% 
%     y  - an N x 1 vector of response errors (domain: -pi <= y_i <= +pi)
%     z  - an N x 1 vector of swap errors (domain: -pi <= y_i <= +pi)
%     mu - a  1 x K vector of means (default: mu_1 = 0, mu_2 = pi)
%     kr - a  1 x 2 vector of precision range (default: kr = [1 21])
%     m  - a string, the type of model ('m11': full model, 'm10': partial
%          model without swap errors)
% 
%     r_est - a 1 x K vector of estimated frequencies
%     m_est - a 1 x K vector of estimated locations
%     k_est - a 1 x K vector of estimated precisions
%     MLL   - a scalar, the maximum log-likelihood
%     LF    - a vector of likelihoods
%
% Adapted from ME_vMMM_ML(), Joram Soch, BCCN Berlin 08/11/2018
%
% Last edit: 07/07/2021, Simon Weber


% set mu and kappa
if nargin < 3 || isempty(mu), mu = [0 0]; end;
if nargin < 4 || isempty(kr), kr = [11 11]; end;

% clear data of NaN values, if necessary
if any(isnan(y)), y(isnan(y)) = []; end
if any(isnan(z)), z(isnan(z)) = []; end


if numel(y) ~= numel(z)
    error('y and z have different length.')
end

%% Full model - detection, swap errors, guesses

if strcmp(m,'m11')
% set initial values
r  = [0.5, 0.5, 0];
b  = [0];
k  = kr;
dr = r(1)/2;
db = pi/8;
dk = range([2 sum(kr)])/4;
cc = 1e-4;
% refined grid search
while dr > cc
    % parameter grid
    r1 = [(r(1)-2*dr):dr:(r(1)+2*dr)];
    r2 = [(r(2)-2*dr):dr:(r(2)+2*dr)];
    mb = [(b-2*db):db:(b+2*db)];
    k1 = [(k(1)-2*dk):dk:(k(1)+2*dk)];
    k2 = [(k(2)-2*dk):dk:(k(2)+2*dk)];
    % Bessel function
    Ik1 = besseli(0,k1);
    Ik2 = besseli(0,k2);
    % log-likelihood
    LL = zeros(numel(r1),numel(r2),numel(mb),numel(k1),numel(k2));
    for i1 = 1:numel(r1)
        for i2 = 1:numel(r2)
            if r2(i2) > (1-r1(i1))
                LL(i1,i2,:,:) = -Inf;
            else
                rs = [r1(i1), r2(i2), (1-r1(i1)-r2(i2))];
                for ij = 1:numel(mb)
                    ms = mu + mb(ij);
                    for j1 = 1:numel(k1)
                        for j2 = 1:numel(k2)
                            ks = [k1(j1), k2(j2)];
                            LL(i1,i2,ij,j1,j2) = bhvr_LL(y, z, rs, ms, ks, [Ik1(j1), Ik2(j2)]);
                        end;
                    end;
                end;
            end;
        end;
    end;
    % adjust parameters
    [MLL, ind]                = max(LL(:));
    [r1i, r2i, mbi, k1i, k2i] = ind2sub(size(LL), ind);
    r = [r1(r1i), r2(r2i), (1-r1(r1i)-r2(r2i))];
    b = mb(mbi);
    m = mu + mb(mbi);
    k = [k1(k1i), k2(k2i)];
    % adjust step sizes
    dr = dr/2;
    db = db/2;
    dk = dk/2;
end;
% collect final estimates
r_est = r;
m_est = m;
k_est = k;
[MLL, LF]   = bhvr_LL(y, z, r_est, m_est, k_est);
end

%% only detection & guesses
if strcmp(m,'m10')
% set initial values
r  = [0.5, 0, 0.5];
b  = [0];
k  = [mean(kr), 0];
dr = r(1)/2;
db = pi/8;
dk = range([2 sum(kr)])/4;
cc = 1e-4;
% refined grid search
while dr > cc
    % parameter grid
    r1 = [(r(1)-2*dr):dr:(r(1)+2*dr)];
    mb = [(b-2*db):db:(b+2*db)];
    k1 = [(k(1)-2*dk):dk:(k(1)+2*dk)];
    % Bessel function
    Ik1 = besseli(0,k1);
    Ik2 = besseli(0,k(2));
    % log-likelihood
    LL = zeros(numel(r1),numel(mb),numel(k1));
    for i1 = 1:numel(r1)
        rs = [r1(i1), r(2), (1-r1(i1))];
        for ij = 1:numel(mb)
            ms = [mu(1)+mb(ij), mu(2)];
            for j1 = 1:numel(k1)
                ks = [k1(j1), k(2)];
                LL(i1,ij,j1) = bhvr_LL(y, z, rs, ms, ks, [Ik1(j1), Ik2]);
            end;
        end;
    end;
    % adjust parameters
    [MLL, ind]      = max(LL(:));
    [r1i, mbi, k1i] = ind2sub(size(LL), ind);
    r = [r1(r1i), r(2), (1-r1(r1i))];
    b =  mb(mbi);
    m = [mu(1)+mb(mbi), mu(2)];
    k = [k1(k1i), k(2)];
    % adjust step sizes
    dr = dr/2;
    db = db/2;
    dk = dk/2;
end;
% collect final estimates
r_est = r;
m_est = m;
k_est = k;
[MLL, LF]   = bhvr_LL(y, z, r_est, m_est, k_est);
end

