function [Vce_corrected, VL, didt] = compensateInductiveDrop(time, vce_clamped, ic, process, Ls)
% COMPENSATE_INDUCTIVE_DROP Computes inductive voltage drop in Vce due to bonding wires.
%
% VL = compensate_inductive_drop(vce_clamped, ic, process, time, Ls)
%
% Inputs:
%   vce_clamped - Measured clamped Vce [V]
%   ic          - Measured collector current [A]
%   process     - Logical vector (true where processing is needed)
%   time        - Time vector [s]
%   Ls          - Bonding wire inductance [H]
%
% Output:
%   Vce_corrected  - Corrected clamped Vce [V]
%
% Notes:
%   - Handles contiguous blocks in 'process'
%   - di/dt computed with:
%       * Forward difference for first point of block
%       * Backward difference for last point of block
%       * Centered difference for interior points

    if ~isequal(length(vce_clamped), length(ic), length(process), length(time))
        error('All inputs must have the same length.');
    end

    VL = zeros(size(ic));
    didt = nan(size(ic));

    % Find indices where process is true
    idx = find(process);
    if isempty(idx), return; end

    % Detect block boundaries
    block_edges = [0; find(diff(idx) > 1); numel(idx)];

    for b = 1:numel(block_edges)-1
        block_start = idx(block_edges(b)+1);
        block_end   = idx(block_edges(b+1));
        block_idx   = block_start:block_end;

        for k = 1:numel(block_idx)
            i = block_idx(k);
            if k == 1
                % First point of block: forward difference
                di_dt = (ic(i+1) - ic(i)) / (time(i+1) - time(i));
            elseif k == numel(block_idx)
                % Last point of block: backward difference
                di_dt = (ic(i) - ic(i-1)) / (time(i) - time(i-1));
            else
                % Interior point: centered difference
                di_dt = (ic(i+1) - ic(i-1)) / (time(i+1) - time(i-1));
            end
            VL(i) = Ls * di_dt;
            didt(i) = di_dt;
        end
    end
    Vce_corrected = vce_clamped - VL;
end
