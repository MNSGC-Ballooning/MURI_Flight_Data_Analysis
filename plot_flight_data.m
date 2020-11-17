function plot_flight_data(datafile,flightID)

% pull the relevant .bin file
output = SD_Card_Read2(datafile,0);

% fix outliers in the telemetry data
output.alt = fix_outliers(output.alt);
output.lat = fix_outliers(output.lat);
output.lon = fix_outliers(output.lon);
output.pressure_ms5611 = fix_outliers(abs(output.pressure_ms5611), 0.1);
output.pressure_analog = fix_outliers(output.pressure_analog);
output.erau_time = fix_outliers(output.erau_time);
output.erau_gps_time = fix_outliers(output.erau_gps_time);
output.umn_time = fix_outliers(output.umn_time);

f1 = plot_altitude_v_time(output,flightID);
f2 = plot_temperature_v_time(output,flightID);
[f3,f4] = plot_pressure_v_time(output,flightID);

end