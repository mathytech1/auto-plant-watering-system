%% Auto Plant Watering with Arduino and MATLAB
%% Mathewos Beyene
%% December 5, 2023

clear all; close all; clc;

a = arduino("COM7","Nano3");     % Create an Arduino object

reallyDrySoil = 55;              % Above this point the soil is driest
moistureThreshold = 33;          % Below this point the soil is water saturated.

figure                           % To create a new figure window.
h = animatedline('Color','red'); % Creates the animated line object
ax = gca;                        % To return the current axis in in the current figure.
ax.YGrid = 'on';                 % To display the grid lines
ax.YLim = [0 100];               % Set the minimum and maximum Limits of Y-axis.
title('Moisture sensor value vs time (live); 100 = v.super dry soil and 0 = v.super saturated soil.');
xlabel('Time [HH:MM:SS]');
ylabel('ADC Count [quanta]');

startTime = datetime('now');     % Starts clocking

while(true)                      % Infinite loop
    Vs = readVoltage(a,'A1');    % Read the moisture level
    disp("Signal Recieved")
    moisture = voltToMoisture(Vs); %The dunction to convert the read voltage(0 - 5volts) to moisture(0 - 100). 
    disp("Moisture Level: "+moisture);
    if(moisture>reallyDrySoil)   
        disp("State: Dry Soil") % To display the current state.
        writeDigitalPin(a,"D2",1);  % Send the signal to turn the pump on.
        tic;                        % Start recording the time
        while(toc<=3)                        % It will help us to water for 3 seconds and also read the voltage and plot the graph(live)
            Vs = readVoltage(a,'A1');       % Read the moisture from moisture sensor
            moisture = voltToMoisture(Vs);   % Convert the moisture in voltage to percentage
            t = datetime('now') - startTime; % To get the difference between the startTime (when the loop begin) and exact time right now.
            addpoints(h,datenum(t),moisture) % Add components to be drawn to the animated graph h.
        
            ax.XLim = datenum([t-seconds(15) t]); % Set the minimum and maximum limits of X-axis.
            datetick('x','keeplimits')            %changes the tick labels to date-based labels while preserving the axis limits.
            drawnow                               % Starts drawing
        end
    elseif(moisture>moistureThreshold)
        disp("State: Wet but not wet enough.")
        writeDigitalPin(a,"D2",1);
        tic;
        while(toc<=1)
            Vs = readVoltage(a,'A1');
            moisture = voltToMoisture(Vs);
            t = datetime('now') - startTime;
            addpoints(h,datenum(t),moisture)
        
            ax.XLim = datenum([t-seconds(15) t]);
            datetick('x','keeplimits')
            drawnow
        end
    else
        disp("State: Water saturated soil.")
        tic;
        while(toc<=5)
            Vs = readVoltage(a,'A1');
            moisture = voltToMoisture(Vs);
            t = datetime('now') - startTime;
            addpoints(h,datenum(t),moisture)
        
            ax.XLim = datenum([t-seconds(15) t]);
            datetick('x','keeplimits')
            drawnow
        end
    end
    writeDigitalPin(a,"D2",0);           % Send the signal to turn the pump off.
    clear Vs;                            % To clear previous values of VS
end

function moistLevel = voltToMoisture(Vs) % A function to convert the moisture level in voltage into percentage
    moistLevel = 22*Vs - 10;     
end

