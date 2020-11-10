function output = fix_outliers(input)

% NEED TO STILL TEST THIS FUNCTION

n = length(input);
outlier_vector = isoutlier(input);


for i = 1:n
    if outlier_vector(i) == 1
        if i < find(outlier_vector == 0, 1, 'first')
            input(i) = input(find(outlier_vector == 0, 1, 'first'));
        elseif i > find(outlier_vector == 0, 1, 'last')
            input(i) = input(find(outlier_vector == 0, 1, 'last'));
        elseif i ~= 1 && i ~= n
            input(i) = (input(find_good_index(outlier_vector, i, 'low')) + input(find_good_index(outlier_vector, i, 'high')))/2;
        end
    end
end
    
output = input;

end

function n = find_good_index(outlier_vector, i, flag)

switch flag
    case 'low'
        while outlier_vector(i) == 1
            i = i - 1;
        end
        
        n = i;
        
    case 'high'
        while outlier_vector(i) == 1
            i = i + 1;
        end
        
        n = i;
        
end

end