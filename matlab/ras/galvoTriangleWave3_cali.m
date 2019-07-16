function [waveform, s1, s2] = galvoTriangleWave3_cali(voltages1, voltages2, maxAccel, dt, rep_rate)
% This function is similar to galvoTriangleWave2() but voltage sweeps in
% the backwards and forwards directions are not required to be symmetric. A
% cubic equation is solved to connect the slopes and positions of the two
% sweeps. The time of the turnaround is found by assuming a constant
% deceleration at maxAccel from slope 1 to zero velocity.
% The digital blaker waveform is high during the linear sweeps.
% Added the ability to oversample the waveforms. The voltage arrays
% are assumed to have one value for each column of the SLM and are
% independent of the sample period 'dt'. The oversample factor is the
% ratio of the sample rate and the laser 'rep_rate'. 
%
% Shane Nichols and Amanda Klaeger, 2019    

    range1 = voltages1(end) - voltages1(1);
    range2 = voltages2(end) - voltages2(1);
    sweepTime = length(voltages1) ./ rep_rate;
    slope1 = range1/sweepTime;
    slope2 = range2/sweepTime;
    taccel = abs(slope1) / maxAccel;
    % t is adjusted to make sure the overall waveform is a multiple of the
    % laser rep period.
    taccel = 2 * (taccel - mod(taccel, 1/rep_rate)) + dt;
    
    os = 1 / (dt * rep_rate);  % oversample factor
    % fractional indices at which to interpolate the voltage waveforms
    indices = (floor(os / 2 + 1)/os):(1/os):(length(voltages1) + 0.5);
    voltages1 = interp1(voltages1, indices, 'pchip', 'extrap');
    voltages2 = interp1(voltages2, indices, 'pchip', 'extrap');
    
    x1 = 0;
    x2 = taccel; 
    mat = [x1^3, x1^2, x1, 1; ...
           x2^3, x2^2, x2, 1; ...
           3*x1^2, 2*x1, 1, 0; ...
           3*x2^2, 2*x2, 1, 0];
    
    y1 = voltages1(end);
    y2 = voltages2(1);
    coef1 = mat \ [y1; y2; slope1; slope2];
    t1 = dt:dt:(taccel - dt);
    
    x1 = 0;
    x2 = taccel + dt; 
    mat = [x1^3, x1^2, x1, 1; ...
           x2^3, x2^2, x2, 1; ...
           3*x1^2, 2*x1, 1, 0; ...
           3*x2^2, 2*x2, 1, 0];
    
    y1 = voltages2(end);
    y2 = voltages1(1);
    coef2 = mat \ [y1; y2; slope2; slope1]; 
    t2 = dt:dt:taccel;
    
    waveform = [voltages1, ...
                polyval(coef1, t1), ...
                voltages2, ...
                polyval(coef2, t2)];
    s1 = [...
        ones(1, length(voltages1)),...
        zeros(1, length(t1) + length(t2) + length(voltages2))];
    
    s2 = [...
        zeros(1, length(t1) + length(voltages1)), ...
        ones(1, length(voltages2)), ...
        zeros(1, length(t2))];
end
    