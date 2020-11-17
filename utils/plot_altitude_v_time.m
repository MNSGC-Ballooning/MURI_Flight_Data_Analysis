function f = plot_altitude_v_time(input,flightID)
% Function that outputs a plot of altitude (in kilometers) versus time (in
% minutes) for MURI flights

% Find the index, fidx, that occurs roughly 1 minute before the payload in
% 100 meters above the initial launch site
sidx = find(input.alt > 0, 1);
fidx = find((input.alt - 100) > mean(input.alt(sidx:sidx+20)),1) - 60;

% Plot altitude v. time
f = figure;
s1 = scatter(input.erau_time(fidx:end)./60,input.alt(fidx:end)./1000,20);
grid on;
s1.MarkerFaceColor = 'b';
title(sprintf('%s Altitude v. Time',flightID));
xlabel('Time (min)'); ylabel('Altitude (km)');

end