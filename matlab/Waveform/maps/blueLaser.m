function wf = blueLaser(wf)
    % AOTF calibration 488 nm laser on AdaptiveUpright.
    % This model was determined in smn_1_017_04.
    % The input waveform should range from 0 to 1, where 0
    % is no light and 1 is full power. The output voltage
    % range is 0 to 4.6 V.
    s = load('blueLaser_adaptiveUpright.mat', 'a');
    wf = interp1(s.a(:,2), s.a(:,1), wf, 'linear', 0);
end