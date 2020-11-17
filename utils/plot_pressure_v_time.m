function [f1,f2] = plot_pressure_v_time(input,flightID)
% Function that outputs a plot of pressure (in ATM) versus time (in
% minutes) for MURI flights

% Find pressure altitude (meters)
ms5611_alt = psi_to_altitude(fix_outliers(abs(input.pressure_ms5611),0.1));
n = length(ms5611_alt);

% Find the index, fidx, that occurs roughly 1 minute before the payload in
% 100 meters above the initial launch site
sidx = find(ms5611_alt > 0, 1);
fidx = find((ms5611_alt - 100) > mean(input.alt(sidx:sidx+20)),1) - 60;

% relevatn gps indices
gsidx = find(input.alt > 0, 1);
gfidx = find((input.alt - 100) > mean(input.alt(gsidx:gsidx+20)),1) - 60;

% find the time limit of the graphs
tmax = ceil((mean(input.umn_time(end-9:end))/60)/50)*50;

% Plot sensor pressure v. time
f1 = figure;
s1 = scatter(input.umn_time(fidx:n)./60,input.pressure_ms5611(fidx:n),20);
grid on; hold on;
s1.MarkerFaceColor = 'b';
title(sprintf('%s Pressure v. Time',flightID));
xlabel('Time (min)'); ylabel('Pressure (psi)');
legend('MS5611','location','southeast');
xlim([0 tmax]);

% Plot sensor pressure altitude v. time
f2 = figure;
s1 = scatter(input.umn_time(fidx:n)./60,ms5611_alt(fidx:n)./1000,20);
grid on; hold on;
s2 = scatter(input.erau_time(gfidx:end)./60,input.alt(gfidx:end)./1000,20);
s1.MarkerFaceColor = 'b';
s2.MarkerFaceColor = 'r';
title(sprintf('%s Pressure Altitude v. Time',flightID));
xlabel('Time (min)'); ylabel('Altitude (km)');
legend('MS5611','GPS','location','northeast');
xlim([0 tmax]);

end