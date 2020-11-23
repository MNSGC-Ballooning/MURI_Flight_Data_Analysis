function output = fix_state_outliers(input,nstates)
% Function to fix outliers in the state identifier vectors

if nargin < 2
    nstates = 8;
end

% If state is invalid, set to previous state
for i = 2:length(input)-1
    if input(i) > nstates || input(i) < 0
        input(i) = input(i-1);
    end
end

output = input;

end


