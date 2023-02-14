function [x, Y, E] = fss_sim_generate_data(v, t)

% 1. Generate labels
x = MD_unirnd(0, 2*pi, t);

% 2. Generate data
L  = gamrnd(2,2,[1 v]);         % tuning smoothness
prec = 1;                       % prediction precision
x0 = [(prec/180)*pi:(prec/180)*pi:2*pi]';
Yt = zeros(numel(x0),v);
for i = 1:v
    K0 = ME_GPR_kern(x0, x0, 'per', L(i));
    Yt(:,i) = mvnrnd(zeros(size(x0)), K0);
end

% Sample from generated data
Y = nan(t,v);
for i = 1:v
    for j = 1:t
        if ~isnan(x(j))
            Y(j,i) = Yt(ceil((x(j)/(2*pi))*(360/prec)),i);
        end
    end
end

% Normalize data to allow precise changes in SNR
Y = reshape(normalize(Y(:)),size(Y));

% 3. Generate noise
E = randn(size(Y));