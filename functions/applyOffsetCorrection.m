function [Vce_corrected,Vce_offset] = applyOffsetCorrection(Vce_clamped, Ic, fit_offset)
%APPLYOFFSETCORRECTION Applies polynomial offset correction to Vce
    Vce_offset = polyval(fit_offset, Ic);
    Vce_corrected = Vce_clamped - Vce_offset;
end
