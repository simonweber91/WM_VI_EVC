function [randomizedConditions, randomizedIndeces] = randomize_conditions(conditions, numberOfTrials)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Based on 'conditions', create output of length 'numberOfTrials', which is
% composed of the randomized elements of 'conditions' with the constraint
% that no element should occur more than twice in a row. This randomization
% is based on a radomized latin square. 'numberOfTrials' has to be a
% multiple of length('conditions').
% Possible use: randomize a number of experimental conditions to create an
% order for their presentation across a number of trials.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if 'numberOfTrials' is a multiple of length('conditions'). If not,
% throw error with value suggestions for 'numberOfTrials'.
if rem(numberOfTrials, length(conditions)) ~= 0
    x=1;
    while 1
        if length(conditions)*x<numberOfTrials
            x=x+1;
        else
            break;
        end
    end
    error(['outputLength has to be a multiple of length(input).\n',...
        'Suggested values for outputLength: %s or %s.'],...
        num2str(length(conditions)*(x-1)), num2str(length(conditions)*x));
end

% Creates a randomized vector of the elements 'conditions' with the length
% of numberOfTrials. If the result is a mere repetition of 'conditions'
% (forward or reverse), then the process is repeated.
randomizedIndeces = [];
while isempty(randomizedIndeces) || isequal(randomizedIndeces,repmat(1:length(conditions),1,numberOfTrials/length(conditions))) || isequal(randomizedIndeces,repmat(length(conditions):-1:1,1,numberOfTrials/length(conditions)))
    % Creates and appends as many randomized latin sqares as needed to exceed the
    % number of requested elements.
    while numel(randomizedIndeces)<numberOfTrials
        randomizedIndeces = [randomizedIndeces; latsqrand(length(conditions))];
    end
    % Vectorizes latin squares to create a list of indices to randomize
    % 'conditions'.
    randomizedIndeces = reshape(randomizedIndeces,1,[]);
    % Trims vector to requested length
    randomizedIndeces = randomizedIndeces(1:numberOfTrials);
end

% Assigns elements of 'conditions' to the created list of indices to
% generate output.
randomizedConditions = conditions(randomizedIndeces);


