function [f1, f2, f3] = plot_state_history(input, flightID)
% Function that outputs plots for the state history of erau, cdu1, and cdu2
% flight computers

% erau state plot
f1 = figure;
s1 = scatter(input.erau_time./60,input.state.erau,20);
grid on; hold on;
s1.MarkerFaceColor = 'b';
title(sprintf('%s ERAU State History v. Time',flightID));
xlabel('Time (min)'); ylabel('State Indicator');

% cdu1 state plot
f2 = figure;
s2 = scatter(1:1:length(input.state.cdu1)-1,input.state.cdu1(1:end-1),20);
grid on; hold on;
s2.MarkerFaceColor = 'b';
title(sprintf('%s CDU1 State History',flightID));
xlabel('Index'); ylabel('State Indicator');

% cdu2 state plot
f3 = figure;
s3 = scatter(1:1:length(input.state.cdu2)-1,input.state.cdu2(1:end-1),20);
grid on; hold on;
s3.MarkerFaceColor = 'b';
title(sprintf('%s CDU2 State History',flightID));
xlabel('Index'); ylabel('State Indicator');

end
