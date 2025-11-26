function process = generateProcessMask(time, Ic, left_margin_us, right_margin_us)
%GENERATEPROCESSMASK Generates a logic signal for processing windows
%   process = generateProcessMask(time, Ic, left_margin_us, right_margin_us)
%   Returns a logical vector 'process' that is true during a window
%   defined by left and right margins around the maximum current in each switching period.
%
%   Inputs:
%       time            - Time vector corresponding to Ic and Vce_clamped
%       Ic              - Current waveform vector
%       left_margin_us  - Time before the max current point (in microseconds)
%       right_margin_us - Time after the max current point (in microseconds)
%
%   Output:
%       process         - Logical vector with 1s during processing windows

% Convert margins to seconds
left_margin = left_margin_us * 1e-6;
right_margin = right_margin_us * 1e-6;

% Initialize process signal
process = zeros(size(time));

% Find zero-crossings from negative to positive (start of switching period)
zero_crossings = find(Ic(1:end-1) < 0 & Ic(2:end) >= 0);

for i = 1:length(zero_crossings)-1
    idx_start = zero_crossings(i);
    idx_end = zero_crossings(i+1);

    % Extract current segment for this switching period
    Ic_segment = Ic(idx_start:idx_end);
    time_segment = time(idx_start:idx_end);

    % Find index of maximum current in this segment
    [~, idx_max_local] = max(Ic_segment);
    t_mid = time_segment(idx_max_local); % Midpoint of processing window

    if left_margin == 0 && right_margin == 0
        % Explicitly select the peak Ic sample
        idx_window = idx_start + idx_max_local - 1;
    else
        % Define window boundaries using margins
        t_window_start = t_mid - left_margin;
        t_window_end = t_mid + right_margin;

        % Find indices within the window
        idx_window = find(time >= t_window_start & time <= t_window_end);
    end

    % Set process signal to 1 in the window
    process(idx_window) = 1;
end
end
