function output = SD_Card_Read2(filepath, plot_flag)

% SD Card Read
%
% MURI Balloon Project
% Space and Atmospheric Instrumentation Lab
%
% Written by Josh Milford
% Last updated: 7/04/2020
% REC: 7/9/2020

close all
% clear all

%constants / calib
            %External High Thermistor Coefficients:
            p1_ex = 0.4975;
            p2_ex = 2.342;
            p3_ex = 1.396;
            p4_ex = 16.54;
            p5_ex = -7.183;
            mean_ex = 547.6;
            std_ex = 236.2;
           
            %Extra External Low Thermistor Coefficients:
            p1_ex2 = -1.129;
            p2_ex2 = 4.101;
            p3_ex2 = -1.778;
            p4_ex2 = 15.41;
            p5_ex2 = -33.61;
            mean_ex2 = 386.2;
            std_ex2 = 255.8;
    
            %Internal Thermistor Coefficients:
            p1_in = -0.344;
            p2_in = -1.26;
            p3_in = -2.305;
            p4_in = -13.18;
            p5_in = 7.039;
            
            mean_in = 844.7;
            std_in = 97.26;
            
            
            %Voltage ADC Calibration
           p1_v =   -0.003335;
           p2_v =       1.082;
           p3_v =       1.653;
           mean_v = 510; 
           std_v = 334.6;
           
           

%% Open and read entire file

DATA_ERAU = [];
DATA_UMN = [];
DATA_CU = [];
DATA_CU_RAW = [];
DATA_CDU1 = [];
DATA_CDU2 = [];
APRS_ALT = [];

fileID = fopen(filepath,'r');
% fileID = fopen('testbin.bin','r');
A = fread(fileID);
fclose(fileID);

% fileID2 = fopen('kd0awk-11 Raw.txt');
% B = fread(fileID2,'uint8=>char');
% fclose(fileID2);
% size_B = size(B);

%pad with zeros to fix incomplete packets
%fix later
A = [A' zeros(100,1)']';

size_array = size(A);
%% Parse data
packet_num_erau = 1;
packet_num_umn = 1;
packet_num_cu = 1;
packet_num_cu_raw = 1;
packet_num_cdu1 = 1;
packet_num_cdu2 = 1;
packet_num_alt = 1;
packet_time = 1;


for counter = 1:size_array(1)
    %% Grab ERAU Packet
    if (A(counter) == 160) && (A(counter+1) == 177)
        for packet_index = 1:47
            DATA_ERAU(packet_index,packet_num_erau) = A(counter + packet_index - 1);
        end
        packet_num_erau = packet_num_erau + 1;
    end   
    %% Grab SPS30 Packet
    if (A(counter) == 66) && (A(counter+1) == 1)
        for packet_index = 1:77
            DATA_UMN(packet_index,packet_num_umn) = A(counter + packet_index - 1);
        end
        packet_num_umn = packet_num_umn + 1;
    end    
    %% Grab CU Instrument Packet
    if (A(counter) == 193) && (A(counter+1) == 9)
        for packet_index = 1:67
            DATA_CU(packet_index,packet_num_cu) = A(counter + packet_index - 1);
        end
        packet_num_cu = packet_num_cu + 1;
    end
    %% Grab CU Gondola Packet
    if (A(counter) == 210) && (A(counter+1) == 168)
        for packet_index = 1:50
            DATA_CU(packet_index,packet_num_cu) = A(counter + packet_index - 1);
        end
        packet_num_cu = packet_num_cu + 1;
    end 
    %% Grab CU Raw Packet
    if (A(counter) == 161) && (A(counter+1) == 35)
        for packet_index = 1:73
            DATA_CU_RAW(packet_index,packet_num_cu_raw) = A(counter + packet_index - 1);
        end
        packet_num_cu_raw = packet_num_cu_raw + 1;
    end 
    %% Grab CDU 1 Packet
    if (A(counter) == 66) && (A(counter+1) == 65) %&& (A(counter+22) == 83
        for packet_index = 1:35
            DATA_CDU1(packet_index,packet_num_cdu1) = A(counter + packet_index - 1);
        end
        packet_num_cdu1 = packet_num_cdu1 + 1;
    end
    %% Grab CDU 2 Packet
    if (A(counter) == 66) && (A(counter+1) == 66) %&& (A(counter+22) == 83
        for packet_index = 1:35
            DATA_CDU2(packet_index,packet_num_cdu2) = A(counter + packet_index - 1);
        end
        packet_num_cdu2 = packet_num_cdu2 + 1;
    end
    
end

% for counter = 1:size_B-9
%     if (B(counter:counter+8)' == '2020-07-1')
%         hours(packet_time) = str2double(B(counter+11:counter+12));
%         minutes(packet_time) = str2double(B(counter+14:counter+15));
%         seconds(packet_time) = str2double(B(counter+17:counter+18));
%         packet_time = packet_time + 1;
%     end
%     if (B(counter) == 'A') && (B(counter+1) == '=')
%         APRS_ALT(packet_num_alt) = str2double(B(counter+2:counter+7));
%         packet_num_alt = packet_num_alt + 1;
%     end
% end

%% Pick out packet numbers

UMN_SIZE = size(DATA_UMN);
CU_SIZE = size(DATA_CU);
ERAU_SIZE = size(DATA_ERAU);


cu_packet_numbers = zeros(CU_SIZE(2),1);
erau_packet_numbers = zeros(ERAU_SIZE(2),1);




%% parse erau
if length(DATA_ERAU) >0
    for counter = 1:ERAU_SIZE(2)
    erau_packet_numbers(counter,1) = DATA_ERAU(3,counter) + bitshift(DATA_ERAU(4,counter),8);
    end

erau_time = (DATA_ERAU(5,:) + bitshift(DATA_ERAU(6,:),8) + bitshift(DATA_ERAU(7,:),16) + bitshift(DATA_ERAU(8,:),24))./1000;

for i = 1:length(DATA_ERAU(1,:))
erau_lat(:,i) = double(typecast(uint8(squeeze(DATA_ERAU(9:12,i))),'int32'))./10000000;
erau_lon(:,i) = double(typecast(uint8(squeeze(DATA_ERAU(13:16,i))),'int32'))./10000000;
erau_alt(:,i) = double(typecast(uint8(squeeze(DATA_ERAU(17:20,i))),'int32'))./100;
end
erau_gpstime = DATA_ERAU(23,:).*(60*60) + DATA_ERAU(24,:).*60 + DATA_ERAU(25,:);

% requires calibration before these are usable values
for i = 1:length(DATA_ERAU(1,:))
erau_temp1(:,i) = typecast(squeeze(uint8(DATA_ERAU(26:27,i))),'uint16');
erau_temp2(:,i) = typecast(squeeze(uint8(DATA_ERAU(28:29,i))),'uint16');
erau_temp3(:,i) = typecast(squeeze(uint8(DATA_ERAU(30:31,i))),'uint16');
end
%calibrate based on your resistor choices
for i = 1:length(DATA_ERAU(1,:))
erau_batv(:,i) = typecast(squeeze(uint8(DATA_ERAU(32:33,i))),'uint16');
end

%lsm9ds1 outputs
for i = 1:length(DATA_ERAU(1,:))
erau_accx(:,i) = double(typecast(squeeze(uint8(DATA_ERAU(34:35,i))),'int16'))/1000;
erau_accy(:,i) = double(typecast(squeeze(uint8(DATA_ERAU(36:37,i))),'int16'))/1000;
erau_accz(:,i) = double(typecast(squeeze(uint8(DATA_ERAU(38:39,i))),'int16'))/1000;
end

for i = 1:length(DATA_ERAU(1,:))
erau_gyrx(:,i) = double(typecast(squeeze(uint8(DATA_ERAU(40:41,i))),'int16'))/1000;
erau_gyry(:,i) = double(typecast(squeeze(uint8(DATA_ERAU(42:43,i))),'int16'))/1000;
erau_gyrz(:,i) = double(typecast(squeeze(uint8(DATA_ERAU(44:45,i))),'int16'))/1000;
erau_STATE(:,i) = typecast(uint8(squeeze(DATA_ERAU(46,i))),'uint8');
end


                                  
%External Temperature Conversion
%temp = typecast(uint8(messages(5:6)),'uint16');
temp = double(erau_temp1);
temp = (temp-mean_ex)/std_ex;
temp_ex = p1_ex*temp.^4 + p2_ex*temp.^3 + p3_ex*temp.^2 + p4_ex*temp + p5_ex;


%Internal Temperature Conversion
%temp = typecast(uint8(messages(7:8)),'uint16');
temp = double(erau_temp2);
temp = (temp-mean_in)/std_in;
temp_in = p1_in*temp.^4 + p2_in*temp.^3 + p3_in*temp.^2 + p4_in*temp + p5_in;


%Extra External Temperature Conversion
%temp = typecast(uint8(messages(9:10)),'uint16');
temp = double(erau_temp3);
temp = (temp-mean_ex2)/std_ex2;
temp_ex2 = p1_ex2*temp.^4 + p2_ex2*temp.^3 + p3_ex2*temp.^2 + p4_ex2*temp + p5_ex2;


%Voltage Monitor
%voltage = typecast(uint8(messages(13:14)),'uint16');
voltage = double(erau_batv);
voltage = (voltage-mean_v)/std_v;
volt_supply = 3*(p1_v*voltage.^2 + p2_v*voltage + p3_v);
                                       
end        


%% parse UMN

umn_packet_numbers = zeros(UMN_SIZE(2),1);
umn_I2C_pressure = zeros(UMN_SIZE(2),1);
umn_ana_pressure = zeros(UMN_SIZE(2),1);
umn_begin = zeros(UMN_SIZE(2),1);
umn_t1 = zeros(UMN_SIZE(2),1);
umn_t2 = zeros(UMN_SIZE(2),1);
umn_spsA_hits = zeros(UMN_SIZE(2),1);
umn_spsA_num1 = zeros(UMN_SIZE(2),1);
umn_spsA_num2 = zeros(UMN_SIZE(2),1);
umn_spsA_num3 = zeros(UMN_SIZE(2),1);
umn_spsA_num4 = zeros(UMN_SIZE(2),1);
umn_spsA_num5 = zeros(UMN_SIZE(2),1);
umn_spsB_hits = zeros(UMN_SIZE(2),1);
umn_spsB_num1 = zeros(UMN_SIZE(2),1);
umn_spsB_num2 = zeros(UMN_SIZE(2),1);
umn_spsB_num3 = zeros(UMN_SIZE(2),1);
umn_spsB_num4 = zeros(UMN_SIZE(2),1);
umn_spsB_num5 = zeros(UMN_SIZE(2),1);

if ~isempty(DATA_UMN)
    for counter = 1:UMN_SIZE(2)
        umn_begin(counter,1) = DATA_UMN(1,counter);
        umn_packet_numbers(counter,1) = DATA_UMN(3,counter) + bitshift(DATA_UMN(4,counter),8);
        umn_t1(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(9:12,counter))),'single'));
        umn_t2(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(13:16,counter))),'single'));
        umn_I2C_pressure(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(17:20,counter))),'single'));
        umn_ana_pressure(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(21:24,counter))),'single'));
        umn_spsA_hits(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(25:26,counter))),'uint16'));
        umn_spsA_num1(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(29:32,counter))),'single'));
        umn_spsA_num2(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(33:36,counter))),'single'));
        umn_spsA_num3(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(37:40,counter))),'single'));
        umn_spsA_num4(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(41:44,counter))),'single'));
        umn_spsA_num5(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(45:48,counter))),'single'));
        
        umn_spsB_hits(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(49:50,counter))),'uint16'));
        umn_spsB_num1(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(53:56,counter))),'single'));
        umn_spsB_num2(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(57:60,counter))),'single'));
        umn_spsB_num3(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(61:64,counter))),'single'));
        umn_spsB_num4(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(65:68,counter))),'single'));
        umn_spsB_num5(counter,1) = double(typecast(squeeze(uint8(DATA_UMN(69:72,counter))),'single'));
    end
    
umn_time = double(DATA_UMN(5,:) + bitshift(DATA_UMN(6,:),8) + bitshift(DATA_UMN(7,:),16) + bitshift(DATA_UMN(8,:),24))./1000;
% start_time = hours(1)*3600+minutes(1)*60+seconds(1);
% time_after_flight = hours*3600+minutes*60+seconds-start_time;
% for counter = 1:length(time_after_flight)
%     if (time_after_flight(counter)<0)
%         time_after_flight(counter) = time_after_flight(counter)+86400;
%     end
% end

% p_coeff = polyfit(erau_time2,erau_alt2(1:length(erau_time2)),9);
% p_eval = polyval(p_coeff,erau_time2);

% alt_fun = @(t) p_coeff(1)*t.^9+p_coeff(2)*t.^8+p_coeff(3)*t.^7+p_coeff(4)*t.^6+p_coeff(5)*t.^5+p_coeff(6)*t.^4+p_coeff(7)*t.^3+p_coeff(8)*t.^2+p_coeff(9)*t+p_coeff(10);
% umn_alt = alt_fun(umn_time);



%% SPS data

bin5A = umn_spsA_num5-umn_spsA_num4;
bin4A = umn_spsA_num4-umn_spsA_num3;
bin3A = umn_spsA_num3-umn_spsA_num2;
bin2A = umn_spsA_num2-umn_spsA_num1;
bin1A = umn_spsA_num1;

bin5B = umn_spsB_num5-umn_spsB_num4;
bin4B = umn_spsB_num4-umn_spsB_num3;
bin3B = umn_spsB_num3-umn_spsB_num2;
bin2B = umn_spsB_num2-umn_spsB_num1;
bin1B = umn_spsB_num1;

end

%% parse CDU1

if length(DATA_CDU1) >0
for i = 1:length(DATA_CDU1(1,:))
cdu1_lat(:,i) = typecast(uint8(squeeze(DATA_CDU1(6:9,i))),'single');
cdu1_lon(:,i) = typecast(uint8(squeeze(DATA_CDU1(10:13,i))),'single');
cdu1_alt(:,i) = typecast(uint8(squeeze(DATA_CDU1(14:17,i))),'single');
cdu1_Volt(:,i) = typecast(uint8(squeeze(DATA_CDU1(18:21,i))),'single');
cdu1_t1(:,i) = typecast(uint8(squeeze(DATA_CDU1(22:25,i))),'single');
cdu1_t2(:,i) = typecast(uint8(squeeze(DATA_CDU1(26:29,i))),'single');
cdu1_STATUS(:,i) = typecast(uint8(squeeze(DATA_CDU1(30,i))),'uint8');
cdu1_HEAT(:,i) = typecast(uint8(squeeze(DATA_CDU1(31,i))),'uint8');
cdu1_STATE(:,i) = typecast(uint8(squeeze(DATA_CDU1(32,i))),'uint8');
end

if plot_flag == 1
    figure()
    plot(cdu1_alt,'*r')
    title('cdu1 altitude vs index')
    ylim([0 100000])
    grid on;
    title('Altitude vs packet number (about one packet per second');
    xlabel('Packet number');
    ylabel('Altitude (ft)');

    figure()
    plot(cdu1_Volt,'*r')
    title('cdu2 Voltage vs index')
    ylim([0 20])
    grid on;
    title('Voltage vs packet number (about one packet per second');
    xlabel('Packet number');
    ylabel('Voltage (V)');

    figure()
    plot(cdu1_lon,cdu1_lat,'.b');
    ylim([43 45])
    xlim([-94 -92])
    grid on;
    title('latitude vs longitude');
    xlabel('longitude');
    ylabel('latitude');

    figure()
    plot(cdu1_t1,'.b');
    ylim([-90 30])
    grid on;
    hold on;
    title('Temperature vs packet number');
    xlabel('Packet number');
    ylabel('Temperature (C)');
    plot(cdu1_t2,'.g');
    legend('Thermistor on resistor cutter','Thermistor in ambient space','location','best');

    figure()
    plot(cdu1_STATUS,'.b');
    ylim([-10 100])
    grid on;
    title('Status of gondola vs packet number');
    xlabel('Packet number');
    ylabel('STATUS');

    figure()
    plot(cdu1_STATE,'.b');
    ylim([-10 10])
    grid on;
    title('State of gondola vs packet number');
    xlabel('Packet number');
    ylabel('STATE');
end
    
end

%% parse CDU2

%% parse CDU2

if length(DATA_CDU2) >0
for i = 1:length(DATA_CDU2(1,:))
cdu2_lat(:,i) = typecast(uint8(squeeze(DATA_CDU2(6:9,i))),'single');
cdu2_lon(:,i) = typecast(uint8(squeeze(DATA_CDU2(10:13,i))),'single');
cdu2_alt(:,i) = typecast(uint8(squeeze(DATA_CDU2(14:17,i))),'single');
cdu2_Volt(:,i) = typecast(uint8(squeeze(DATA_CDU2(18:21,i))),'single');
cdu2_t1(:,i) = typecast(uint8(squeeze(DATA_CDU2(22:25,i))),'single');
cdu2_t2(:,i) = typecast(uint8(squeeze(DATA_CDU2(26:29,i))),'single');
cdu2_STATUS(:,i) = typecast(uint8(squeeze(DATA_CDU2(30,i))),'uint8');
cdu2_HEAT(:,i) = typecast(uint8(squeeze(DATA_CDU2(31,i))),'uint8');
cdu2_STATE(:,i) = typecast(uint8(squeeze(DATA_CDU2(32,i))),'uint8');
end

if plot_flag == 1
    figure()
    plot(cdu2_alt,'*r')
    title('cdu2 altitude vs index')
    ylim([0 100000])
    grid on;
    title('Altitude vs packet number (about one packet per second');
    xlabel('Packet number');
    ylabel('Altitude (ft)');

    figure()
    plot(cdu2_Volt,'*r')
    title('cdu2 Voltage vs index')
    ylim([0 20])
    grid on;
    title('Voltage vs packet number (about one packet per second');
    xlabel('Packet number');
    ylabel('Voltage (V)');

    figure()
    plot(cdu2_lon,cdu2_lat,'.b');
    ylim([43 45])
    xlim([-94 -92])
    grid on;
    title('latitude vs longitude');
    xlabel('longitude');
    ylabel('latitude');

    figure()
    plot(cdu2_t1,'.b');
    ylim([-90 30])
    grid on;
    hold on;
    title('Temperature vs packet number');
    xlabel('Packet number');
    ylabel('Temperature (C)');
    plot(cdu2_t2,'.g');
    legend('Thermistor on resistor cutter','Thermistor in ambient space','location','best');

    figure()
    plot(cdu2_STATUS,'.b');
    ylim([-10 100])
    grid on;
    title('Status of gondola vs packet number');
    xlabel('Packet number');
    ylabel('STATUS');

    figure()
    plot(cdu2_STATE,'.b');
    ylim([-5 10])
    grid on;
    title('State of gondola vs packet number');
    xlabel('Packet number');
    ylabel('STATE');
end

end
%% plot gps locations

% %daytona
% latlim = [28 30];
% lonlim = [-83 -79];
%UMN
latlim = [40 50];
lonlim = [-100 -87];

if plot_flag == 1
    ZA = loadMaps(latlim,lonlim);

    figure()
    imagesc(lonlim,latlim,flipud(ZA));
    xlabel('Lon')
    ylabel('Lat')
    set(gca,'YDir','normal')
    xlim(lonlim)
    ylim(latlim)
    hold all

    if length(DATA_ERAU) >0
    scatter(erau_lon,erau_lat,'*b')
    end
end

%% plot others

if plot_flag == 1
    
    figure();
    plot(umn_time,umn_packet_numbers,'.r');
    title('UMN packet numbers vs UMN time');
    xlabel('Time (sec)');
    ylabel('Packet numbers');
    ylim([umn_packet_numbers(1) umn_packet_numbers(1)+length(umn_packet_numbers)]);
    xlim([umn_time(1) umn_time(1)+length(umn_packet_numbers)]);
    grid on;

    figure();
    plot(umn_time,umn_I2C_pressure,'.b');
    title('UMN I2C pressure vs UMN time');
    xlabel('Time (sec)');
    ylabel('Pressure (PSI)');
    ylim([0 15]);
    xlim([umn_time(1) umn_time(end)]);
    hold on;
    plot(umn_time,umn_ana_pressure,'.r');
    grid on;
    legend('MS5611 I2C Pressure sensor','Analog Pressure sensor');

    figure();
    plot(umn_time,umn_t1,'.b');
    title('UMN temp vs UMN time');
    xlabel('Time (sec)');
    ylabel('Temperature (C)');
    ylim([0 60]);
    xlim([umn_time(1) umn_time(end)]);
    hold on;
    plot(umn_time,umn_t2,'.r');
    grid on;
    legend('Thermistor 1','Thermistor 2');

    figure();
    plot(umn_time,umn_spsA_hits,'.b');
    title('UMN SPS A hits vs UMN time');
    xlabel('Time (sec)');
    ylabel('hits');
    grid on;
    ylim([0 30000]);
    xlim([umn_time(1) umn_time(end)]);

    figure();
    plot(umn_time,umn_B_hits,'.b');
    title('UMN SPS B hits vs UMN time');
    xlabel('Time (sec)');
    ylabel('hits');
    grid on;
    ylim([0 30000]);
    xlim([umn_time(1) umn_time(end)]);

    figure()
    plot(erau_time,erau_packet_numbers,'.r')
    title('ERAU packet numbers vs ERAU time')
    ylim([erau_packet_numbers(1) erau_packet_numbers(1)+length(erau_packet_numbers)])
    xlim([erau_time(1) erau_time(1)+length(erau_packet_numbers)])

    figure()
    scatter(erau_time,erau_alt,'*b')
    title('erau altitude vs time')
    xlim([erau_time(1) erau_time(1)+length(erau_packet_numbers)])
    ylim([0 35000])
    grid on;
    xlabel('Time (s)');
    ylabel('Altitute (m)');
    legend('Altitude in Meters','location','best');

    figure()
    plot(erau_time,temp_in,'.r')
    xlim([erau_time(1) erau_time(1)+length(erau_packet_numbers)])
    hold all
    plot(erau_time,temp_ex,'.g')
    plot(erau_time,temp_ex2,'.b')
    ylim([-100 90]);
    grid on;
    title('temperature (requires calib)')
    xlim([erau_time(1) erau_time(1)+length(erau_packet_numbers)])
    xlabel('Time (s)');
    ylabel('Temperature (C)');
    legend('Interior temperature','Ambient temp inside payload','Exterior temperature','location','best');

    figure()
    plot(erau_time,volt_supply,'.r')
    title('battery voltage (requires calib)')
    xlim([erau_time(1) erau_time(1)+length(erau_packet_numbers)])
    ylim([-5 15])
    xlabel('Time (s)');
    ylabel('Volatage of the battery (V)');
    legend('Voltage','location','best');

    figure()
    plot(erau_time,erau_accx,'.r')
    hold all
    plot(erau_time,erau_accy,'.g')
    plot(erau_time,erau_accz,'.b')
    title('acceleration')
    xlim([erau_time(1) erau_time(1)+length(erau_packet_numbers)])
    ylim([-20 20])
    xlabel('Time (s)');
    ylabel('Accelerometer measurements (m/s^2)');
    legend('x-acceleration','y-acceleration','z-acceleration','location','best');

    figure()
    plot(erau_time,erau_gyrx,'.r')
    hold all
    plot(erau_time,erau_gyry,'.g')
    plot(erau_time,erau_gyrz,'.b')
    title('gyroscope (needs calibration)')
    xlim([erau_time(1) erau_time(1)+length(erau_packet_numbers)])
    ylim([-10 10])
    xlabel('Time (s)');
    ylabel('Gyroscopic measurements (rad)');
    legend('x-gyrp','y-gyro','z-gyro','location','best');

    figure()
    plot(erau_STATE,'.b');
    ylim([-10 100])
    grid on;
    title('State of main gondola vs packet number');
    xlabel('Packet number');
    ylabel('STATE');
end

output.acc_x = erau_accx;
output.acc_y = erau_accy;
output.acc_z = erau_accz;
output.gyro_x = erau_gyrx;
output.gyro_y = erau_gyry;
output.gyro_z = erau_gyrz;
output.lat = erau_lat;
output.lon = erau_lon;
output.alt = erau_alt;
output.gps_time = erau_gpstime;
output.time = erau_time;
output.temp1 = erau_temp1;
output.temp2 = erau_temp2;
output.temp3 = erau_temp3;
output.spsA.hits = umn_spsA_hits;
output.spsA.bin1 = bin1A;
output.spsA.bin2 = bin2A;
output.spsA.bin3 = bin3A;
output.spsA.bin4 = bin4A;
output.spsA.bin5 = bin5A;
output.spsB.hits = umn_spsB_hits;
output.spsB.bin1 = bin1B;
output.spsB.bin2 = bin2B;
output.spsB.bin3 = bin3B;
output.spsB.bin4 = bin4B;
output.spsB.bin5 = bin5B;



end
%% functions

function ZA = loadMaps(latlim,lonlim)
        newmap = 1;
            ZA=[];
                if newmap == 1
                    numberOfAttempts = 5;
                    attempt = 0;
                    info = [];
                    mundalisServer = 'http://ows.mundialis.de/services/service?';
                    OSM_WMS_Uni_Heidelberg = 'http://129.206.228.72/cached/osm?';
                    
                    serv2 = 0;
                    while(isempty(info))
                        try
                            if serv2 == 0
                                info = wmsinfo(mundalisServer);
                                orthoLayer = info.Layer(2);
                            elseif serv2 == 1
                                info = wmsinfo(OSM_WMS_Uni_Heidelberg);
                                orthoLayer = info.Layer(2);
                            end
                        catch 
                            
                            attempt = attempt + 1;
                            if attempt > numberOfAttempts && serv2 == 0
                                warning('Server 1 is not available. Trying Server 2');
                                serv2 = 1;
                                attempt = 0;
                            end
                        end
                        if serv2 == 1 && attempt > numberOfAttempts
                            warndlg ({'WMS servers are not available.';'Please load an existing Map'});
                            return
                        end
                    end
                    [ZA, ~] = wmsread(orthoLayer, 'Latlim', latlim, 'Lonlim', lonlim, ...
                        'ImageFormat', 'image/png');
               newMapFlag = 1;
                
                
                else
                    [newfile,path] = uigetfile('*.map','Load Map File','map1.map');
                    figure();
                    if newfile == 0
                        return;
                    end
                    filename=fullfile(path,newfile);
                    load(filename,'ZA','-mat');
                  newMapFlag = 0;
              
                    
                    return
            end
            
        end
        
      
