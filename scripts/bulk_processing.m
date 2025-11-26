%% Initialization and processing
close all;  clear; clc

% Import waveforms, multiselect is enable so select waveforms and Vge at the same time
[filenames, path] = uigetfile('*.csv', 'Select waveform and VGE files', 'MultiSelect', 'on');
[time, Vce_clamped, Ic] = importCSV(fullfile(path, filenames{1}));
data = importdata(fullfile(path, filenames{2}));
Vge = data.data(:, 2); clear data;

% Peltier initial temperature
Tpeltier = 50;

% Import LUT and convert to struct
load("LUT.mat");
LUT.current = current;
LUT.temp = temp;
LUT.Vce_interpolation_current = Vce_interpolation_current;

% Offset, Ls and thermal impedance correction parameters
fit_offset = [1e-3 0]; % Polynomial coefficients
Ls = 15e-9; % Stray inductance in H
Zth = 0.1; % Thermal resistance J-C in K/W at 250μs single pulse (from datasheet)

% Processing window mask
wndw_left = 0.25; % in microseconds
wndw_right = 0.25; % in microseconds

% Uncertainties
sigma.Ic = 1e-3; % Uncertainty on the measurement of Ic
sigma.Vce = 1e-3; % Uncertainty on the measurement of Vce
sigma.current_table = 10e-3; % Uncertainty on the measurement of Ic on the curve tracer
sigma.Vce_table = 1e-3; % Uncertainty on the measurement of Vce on the curve tracer
sigma.temp_fit = 10e-3; % Uncertainty on the measurement of Tj on the curve tracer


fprintf('--- Analysis at maximum Ic --- \n');
for i=1:2:length(filenames)
    % Import data
    [time, Vce_clamped, Ic] = importCSV(fullfile(path, filenames{i}));
    data = importdata(fullfile(path, filenames{i+1}));
    Vge = data.data(:, 2); clear data;

    % Generate processing mask
    process = generateProcessMask(time, Ic, wndw_left, wndw_right);

    % Offset correction
    [Vce_clamped,~] = applyOffsetCorrection(Vce_clamped,Ic,fit_offset);

    % Compensate inductive drop of bonding wire
    [Vce_clamped,VL,~] = compensateInductiveDrop(time, Vce_clamped, Ic, process, Ls);

    % Process waveforms to obtain Tj
    [results, Tj_period, Tj_max] = estimateTj(Vce_clamped, Ic, Vge, process, Zth, LUT, sigma);

    % Display results
    disp(strcat("Processed file: ",filenames{i}))
    fprintf('Mean Tj: %.4f °C\n',Tj_max.mean);
    fprintf('Standard deviation: ± %.4f °C\n \n',Tj_max.std);
    
    % Save mean and std into struct for further processing
    k = (i+1)/2;
    processedfiles.tj(k) = Tj_max.mean;
    processedfiles.std(k) = Tj_max.std;
end

clearvars -except processedfiles
