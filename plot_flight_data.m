function plot_flight_data(datafile,flightID)

% pull the relevant .bin file
output = SD_Card_Read2(datafile,0);

% fix outliers in the data
output.alt = fix_outliers(output.alt);
output.lat = fix_outliers(output.lat);
output.lon = fix_outliers(output.lon);
output.pressure_ms5611 = fix_outliers(abs(output.pressure_ms5611), 0.1);
output.pressure_analog = fix_outliers(output.pressure_analog);
output.erau_time = fix_outliers(output.erau_time);
output.erau_gps_time = fix_outliers(output.erau_gps_time);
output.umn_time = fix_outliers(output.umn_time);
output.state.erau = fix_state_outliers(output.state.erau);
output.state.cdu1 = fix_state_outliers(output.state.cdu1);
output.state.cdu2 = fix_state_outliers(output.state.cdu2);

% plot data
f_alt = plot_altitude_v_time(output,flightID);
f_temp = plot_temperature_v_time(output,flightID);
[f_pres,f_pres_alt] = plot_pressure_v_time(output,flightID);
[f_state1, f_state2, f_state3] = plot_state_history(output,flightID);

end