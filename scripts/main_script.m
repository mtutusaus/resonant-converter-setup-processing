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

% Generate processing mask
process = generateProcessMask(time, Ic, wndw_left, wndw_right);

% Offset correction
[Vce_clamped,~] = applyOffsetCorrection(Vce_clamped,Ic,fit_offset);

% Compensate inductive drop of bonding wire
[Vce_clamped,~,~] = compensateInductiveDrop(time, Vce_clamped, Ic, process, Ls);

% Process waveforms to obtain Tj
[results, Tj_period, Tj_max] = estimateTj(Vce_clamped, Ic, Vge, process, Zth, LUT, sigma);

% Clear unused variables
clear path filename
clear current temp Vce_interpolation_current % There is a struct called LUT with this data
clear fit_offset Zth Ls

%% Outputs
valid_idx = ~isnan(Tj_period.mean) & ~isnan(Tj_period.std) & Tj_period.std > 0;
Tj_period.mean_valid = Tj_period.mean(valid_idx);
tj_std_valid = Tj_period.std(valid_idx);
weights = 1 ./ (tj_std_valid .^ 2);
weighted_mean = sum(weights .* Tj_period.mean_valid) / sum(weights);
effective_std = sqrt(1 / sum(weights));

fprintf('--- Period-wise analysis --- \n');
fprintf('Mean of Ic during processing period: %.2f A\n', mean(nonzeros(process.*Ic)));
fprintf('Mean of Vce during processing period: %.2f V\n', mean(nonzeros(process.*Vce_clamped)));
fprintf('Mean of Pdiss during processing period: %.2f W\n\n', mean(nonzeros(process.*(Ic.*Vce_clamped))));

fprintf('Weighted mean Tj: %.4f °C\n', weighted_mean);
fprintf('Effective standard deviation: ± %.4f °C\n', effective_std);
fprintf('Tj span: %.4f °C\n \n', range(Tj_period.mean_valid));

fprintf('--- Analysis at maximum Ic --- \n');
fprintf('Mean Tj: %.4f °C\n',Tj_max.mean);
fprintf('Standard deviation: ± %.4f °C\n \n',Tj_max.std);

clear;
