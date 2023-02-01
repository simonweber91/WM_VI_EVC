function [LL, LF] = bhvr_LL(y, z, r, mu, ka, Ik)
% _
% Log-Likelihood Function for a von Mises Mixture Model
% FORMAT LL = ME_vMMM_LL(y, z, r, mu, ka, Ik)
% 
%     y  - an N x 1 vector of response errors (domain: -pi <= y_i <= +pi)
%     z  - an N x 1 vector of swap errors (domain: -pi <= y_i <= +pi)
%     r  - a  1 x K vector of mixture frequencies
%     mu - a  1 x K vector of means
%     ka - a  1 x K vector of precisions
%     Ik - a  1 x K vector of Bessel values
% 
%     LL - a scalar, the log-likelihood function value
%     LF - a vector of likelihoods
%
% Adapted from ME_vMMM_LL(), Joram Soch, BCCN Berlin 08/11/2018
%
% Last edit: 07/07/2021, Simon Weber


% if frequencies don't add up to 1
if abs(sum(r)-1) > 1e-10
    LL = -Inf;
else
    % if frequencies are not in [0,1]
    if any(r<0) || any(r>1)
        LL = -Inf;
    else
        % if precisions are smaller than 0
        if any(ka<0)
            LL = -Inf;
        else
            % otherwise, calculate likelihoods
            if nargin < 6 || isempty(Ik)
                LF = r(1) * MD_vmpdf(y, mu(1), ka(1)) + r(2) * MD_vmpdf(z, mu(2), ka(2)) + r(3) * MD_unipdf(y, -pi, +pi);
            else
                LF = r(1) * MD_vmpdf(y, mu(1), ka(1), Ik(1)) + r(2) * MD_vmpdf(z, mu(2), ka(2), Ik(2)) + r(3) * MD_unipdf(y, -pi, +pi);
            end;
            % then, calculate log-likelihood
            LL = sum(log(LF));
        end;
    end;
end;