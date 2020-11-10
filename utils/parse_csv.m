function output = parse_csv(current_filepath,flight_id)

filename = sprintf('%s.csv',flight_id); % name of csv file to be parsed

new_filepath = fullfile(current_filepath,'data');   % filepath to data folder

cd(new_filepath);

opts = detectImportOptions(filename);   % set parsing options
opts.VariableNamesLine = 1;         % line on which the variable names are stores
opts.PreserveVariableNames = 1;     % preserve the variable names as they originally were

output = readtable(filename,opts);  % pull data from the csv into a table

cd(current_filepath);

end