function f = plot_tempertature_v_time(input,flightID)
% Function that outputs a plot of temperature (in celsisus) versus time (in
% minutes) for MURI flights

% Find the index, fidx, that occurs roughly 1 minute before the payload in
% 100 meters above the initial launch site
sidx = find(input.alt > 0, 1);
fidx = find((input.alt - 100) > mean(input.alt(sidx:sidx+20)),1) - 60;

% Conversion Factors
k2c = -273.15;              % conversion from kelvin to calsius (additive)

% Thermistor calculations
A = 0.001125308852122;
B = 0.000234711863267;
C = 0.000000085663516;
R = 10000;
T = @(r) inv(A + B.*log(r) + C.*(log(r).^3));

% Run the calculations for each thermistor
for i = 1:length(input.temp1)
    temp1(i) = T(R*(1024./cast(input.temp1(i),'double') - 1));
    temp2(i) = T(R*(1024./cast(input.temp2(i),'double') - 1));
    temp3(i) = T(R*(1024./cast(input.temp3(i),'double') - 1));
end

% Plot temperature v. time
f = figure;
s1 = scatter(input.erau_time(fidx:end)./60,temp1(fidx:end) + k2c,20);
hold on; grid on;
s2 = scatter(input.erau_time(fidx:end)./60,temp2(fidx:end) + k2c,20);
s3 = scatter(input.erau_time(fidx:end)./60,temp3(fidx:end) + k2c,20);
s1.MarkerFaceColor = 'b'; s2.MarkerFaceColor = 'r'; s3.MarkerFaceColor = 'y';
title(sprintf('%s Temperature v. Time',flightID));
xlabel('Time (min)'); ylabel('Temperature (C)');
ylim([-50 100]);    % comment out if data is seemingly missing
legend('Thermistor1','Thermistor2','Thermistor3','location','southeast');

end