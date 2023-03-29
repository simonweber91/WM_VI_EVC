function parallel_pool(n_workers, restart, rng_shuffle)

% function parallel_pool(n_workers, restart, rng_shuffle)
%
% Initializes parallel worker pool, with the option to restart an already
% exististing pool and to shuffle the random number generator on each
% worker individually.
%
% Input:
%   - n_workers: Number of workers that will be created.
%   - restart: Set to 'restart' to re-initialize the pool if it is already running.
%   - rng_shuffle: Shuffles the random number generator for each worker
%       individually, helpful for e.g. simulations.
%
% Simon Weber, sweber@bccn-berlin.de, 2022

% Check if pool should be restarted
if exist('restart','var') && strcmp(restart,'restart')
    restart = true;
else
    restart = false;
end

% Check if workers's rng should be shuffled
if exist('rng_shuffle','var') && strcmp(rng_shuffle,'rng_shuffle')
    rng_shuffle = true;
else
    rng_shuffle = false;
end

% Check if parallel pool is active
par_pool = (gcp('nocreate'));

%%% Initialize parallel pool %%%
if isempty(par_pool)
    % Create new pool
    parpool(n_workers); maxNumCompThreads(n_workers);
elseif ~isempty(par_pool) && ~isequal(par_pool.NumWorkers, n_workers)
    % Close active pool and restart with requested number of workers
    fprintf('Already connected to %d Workers. \n Closing and restarting with %d \n',par_pool.NumWorkers, n_workers);
    delete(par_pool); parpool(n_workers); maxNumCompThreads(n_workers);
elseif ~isempty(par_pool) && restart
    % Restart active pool with requested number of workers
    fprintf('Already connected to %d Workers. \n Close and restart them \n',par_pool.NumWorkers);
    delete(par_pool); parpool(n_workers); maxNumCompThreads(n_workers);

end

%%% Shuffle random number generator on each worker %%%
if rng_shuffle
    fprintf('Initialize randomization seed for each worker. \n');
    fprintf('CAREFUL: sets local rng to ''shuffle''. \n');

    % Set local rng to shuffle
    old_rng = rng;
    rng('shuffle');

    % Get 3 lists of 1000 random integers btw. 1 and 1625 each.
    s1 = randi(1625,1,1000);  % as the 3rd root of 2^32 is 1625.5
    s2 = randi(1625,1,1000);
    s3 = randi(1625,1,1000);

    % On each worker, set the rng seed to the product of 3 randomly picked
    % integers from the lists above
    spmd
        rng_seed = s1(randi(1000,1)) * s2(randi(1000,1)) * s3(randi(1000,1));
        rng(rng_seed);
    end

    % revert rng settings
    rng(old_rng);
end