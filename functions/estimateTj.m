function [results, Tj_period, Tj_max] = estimateTj(Vce_clamped, Ic, Vge, process, Zth, LUT, sigma)
%ESTIMATETJ Estimates junction temperature and uncertainty with Vge filtering
%
%   Inputs:
%       Vce_clamped, Ic, Vge, process - waveform data and processing mask
%       Zth - thermal impedance
%       LUT - struct with fields:
%           LUT.current, LUT.temp, LUT.Vce_interpolation_current
%       sigma - struct with fields:
%           sigma.Ic, sigma.Vce, sigma.current_table, sigma.Vce_table, sigma.temp_fit
%
%   Outputs:
%       results - struct:
%           .Tj                - pointwise estimated junction temperature
%           .Tj_std_estimated  - propagated uncertainty per point
%           .Tj_periods        - matrix of Tj values per switching period
%       Tj_period - struct:
%           .mean              - mean Tj across periods
%           .std               - combined std dev (inter + intra)
%       Tj_max - struct:
%           .mean              - mean of Tj at peak Ic for all periods
%           .std               - combined std of Tj at peak Ic for all periods

% Hardcoded Vge limits
Vge_min = 14.9;
Vge_max = 15.1;

% Initialize
Tj = NaN(size(Ic));
Tj_std_estimated = NaN(size(Ic));

% Estimate Tj
for i = 1:length(Tj)
    if process(i)
        % Vge filtering
        if Vge(i) < Vge_min || Vge(i) > Vge_max
            Tj(i) = NaN;
            Tj_std_estimated(i) = NaN;
            warning('Skipped point %d: Vge = %.3f V outside [%.2f, %.2f] V.', i, Vge(i), Vge_min, Vge_max);
            continue;
        end

        Ic_val = Ic(i);
        Vce_val = Vce_clamped(i);

        [~, idx_Ic] = min(abs(LUT.current - Ic_val));
        Vce_row = LUT.Vce_interpolation_current(idx_Ic, :);

        if range(Vce_row) < 25e-3
            warning('Lookup table is flat (< 25 mV) near Ic = %.2f A. Skipping temperature estimation.', Ic(i));
            continue;
        end

        idx_equal = find(Vce_row == Vce_val, 1);
        if ~isempty(idx_equal)
            Tj(i) = LUT.temp(idx_equal);
        else
            idx_below = find(Vce_row < Vce_val, 1, 'last');
            idx_above = find(Vce_row > Vce_val, 1, 'first');

            if ~isempty(idx_below) && ~isempty(idx_above)
                Vce_interp = [Vce_row(idx_below), Vce_row(idx_above)];
                temp_interp = [LUT.temp(idx_below), LUT.temp(idx_above)];
                Tj(i) = interp1(Vce_interp, temp_interp, Vce_val);
            elseif ~isempty(idx_above) && idx_above + 2 <= length(LUT.temp)
                fit = polyfit(Vce_row(idx_above:idx_above+2), LUT.temp(idx_above:idx_above+2), 1);
                Tj(i) = polyval(fit, Vce_val);
                warning('Upper extrapolation');
            elseif ~isempty(idx_below) && idx_below - 2 >= 1
                fit = polyfit(Vce_row(idx_below-2:idx_below), LUT.temp(idx_below-2:idx_below), 1);
                Tj(i) = polyval(fit, Vce_val);
                warning('Lower extrapolation');
            end
        end
    end
end

% Apply thermal impedance correction
Pdiss = Ic .* Vce_clamped;
Tj = Tj + Zth .* Pdiss;

% Estimate uncertainty
for i = 1:length(Tj)
    if isnan(Tj(i)), continue; end

    Ic_val = Ic(i);
    Vce_val = Vce_clamped(i);
    [~, idx_Ic] = min(abs(LUT.current - Ic_val));
    Vce_row = LUT.Vce_interpolation_current(idx_Ic, :);

    [~, idx_sorted] = sort(abs(Vce_row - Vce_val));
    idx1 = idx_sorted(1);
    idx2 = idx_sorted(2);

    idx1 = max(min(idx1, length(LUT.temp)), 1);
    idx2 = max(min(idx2, length(LUT.temp)), 1);

    dTj_dVce = (LUT.temp(idx2) - LUT.temp(idx1)) / (Vce_row(idx2) - Vce_row(idx1));
    sigma_Tj_Vce = abs(dTj_dVce) * sigma.Vce;
    sigma_Tj_Vce_table = abs(dTj_dVce) * sigma.Vce_table;

    idx_Ic_up = min(idx_Ic + 1, length(LUT.current));
    idx_Ic_down = max(idx_Ic - 1, 1);

    Vce_up = LUT.Vce_interpolation_current(idx_Ic_up, :);
    Vce_down = LUT.Vce_interpolation_current(idx_Ic_down, :);

    [Vce_up_unique, idx_unique_up] = unique(Vce_up, 'stable');
    [Vce_down_unique, idx_unique_down] = unique(Vce_down, 'stable');

    if length(Vce_up_unique) >= 2 && length(Vce_down_unique) >= 2
        Tj_up = interp1(Vce_up_unique, LUT.temp(idx_unique_up), Vce_val, 'linear', 'extrap');
        Tj_down = interp1(Vce_down_unique, LUT.temp(idx_unique_down), Vce_val, 'linear', 'extrap');
        dTj_dIc = (Tj_up - Tj_down) / (LUT.current(idx_Ic_up) - LUT.current(idx_Ic_down));
    else
        dTj_dIc = 0;
    end

    sigma_Tj_Ic = abs(dTj_dIc) * sigma.Ic;
    sigma_Tj_I_table = abs(dTj_dIc) * sigma.current_table;

    Tj_std_estimated(i) = sqrt( ...
        sigma_Tj_Vce^2 + ...
        sigma_Tj_Ic^2 + ...
        sigma_Tj_Vce_table^2 + ...
        sigma_Tj_I_table^2 + ...
        sigma.temp_fit^2 );
end

% Period-wise analysis
process_diff = diff([0; process(:); 0]);
start_indices = find(process_diff == 1);
end_indices = find(process_diff == -1) - 1;

num_periods = length(start_indices);
max_samples = max(end_indices - start_indices + 1);

Tj_periods = NaN(num_periods, max_samples);
Tj_std_periods = NaN(num_periods, max_samples);

% Store peak Tj and its uncertainty
Tj_peaks = NaN(num_periods, 1);
Tj_peaks_std = NaN(num_periods, 1);

for k = 1:num_periods
    idx_range = start_indices(k):end_indices(k);
    len = length(idx_range);
    Tj_periods(k, 1:len) = Tj(idx_range);
    Tj_std_periods(k, 1:len) = Tj_std_estimated(idx_range);

    % Peak Ic index within this period
    [~, idx_peak_local] = max(Ic(idx_range));
    idx_peak_global = idx_range(idx_peak_local);

    % If Tj at peak Ic is NaN, leave as NaN
    Tj_peaks(k) = Tj(idx_peak_global);
    Tj_peaks_std(k) = Tj_std_estimated(idx_peak_global);
end

% Compute period-wise stats
tj_mean = mean(Tj_periods, 1, 'omitnan');
tj_std_inter = std(Tj_periods, 0, 1, 'omitnan');
tj_std_intra = sqrt(mean(Tj_std_periods.^2, 1, 'omitnan'));
tj_std_combined = sqrt(tj_std_inter.^2 + tj_std_intra.^2);

% Compute peak-based stats
Tj_max_mean = mean(Tj_peaks, 'omitnan');
Tj_max_std_combined = sqrt(mean(Tj_peaks_std.^2, 'omitnan'));

% Pack outputs
results.Tj = Tj;
results.Tj_std_estimated = Tj_std_estimated;
results.Tj_periods = Tj_periods;

Tj_period.mean = tj_mean;
Tj_period.std = tj_std_combined;

Tj_max.mean = Tj_max_mean;
Tj_max.std = Tj_max_std_combined;

end
