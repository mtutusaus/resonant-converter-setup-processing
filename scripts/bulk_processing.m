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
