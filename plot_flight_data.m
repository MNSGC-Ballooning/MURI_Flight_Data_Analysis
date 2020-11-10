function plot_flight_data(datafile,flightID)

% pull the relevant .bin file
output = SD_Card_Read2(datafile,0);

% fix outliers in the telemetry data
output.alt = fix_outliers(output.alt);
output.lat = fix_outliers(output.lat);
output.lon = fix_outliers(output.lon);
output.time = fix_outliers(output.time);

f1 = plot_alt_v_time(output,flightID);
f2 = plot_temperature_v_time(output,flightID);

end