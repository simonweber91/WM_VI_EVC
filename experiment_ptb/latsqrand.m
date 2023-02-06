function M = latsqrand(N)
% LATSQRAND - Truly Random Latin Square Matrix
%    M = LATSQRAND(N) creates a truly random latin square matrix of size
%    N-by-N containing the numbers 1 to N.  N should be a positive integer.
%    Uses the LATSQ function, copyright (c) 2017, Jos van der Geest
%
%    A latin square of size N is a N-by-N matrix filled with N different
%    numbers in such a way that each number occurs exactly once in each row
%    and exactly once in each column. In this case, the occurance of each
%    number in N is randomiyed with respect to its position in both rows
%    and columns.

if nargin ~= 1 || ~isnumeric(N) || numel(N)~=1 || N<1 || fix(N)~=N
    error('Single argument should be a positive integer') ;
end

M = latsq(N);
M = M(randperm(size(M,1)),:);
M = M(:,randperm(size(M,2)));


