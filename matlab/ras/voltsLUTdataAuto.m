function voltsLUTdataAuto(datapath,savepath)
% Made a button in the labview program that automatically collects the data
% for this calibration. It performs a 10 sec acquisition at 250 kHz sample
% rate. Data is put into /vi.lib/RAS/voltsLUTdata/
obj = rasDaqData(datapath);
% smooth the data to get better peak centers
signal = gaussianSmooth(obj.ai.PMT_RAS, 250);
[pks, locs] = findpeaks(signal, ...
    'MinPeakWidth',500, ...
    'MinPeakProminence', 0.005);

% old code...
% outlier rejection based on peak location (less robust)
% len = length(locs);
% idx = round(0.1*len):round(0.9*len);
% p = polyfit(idx.', locs(idx), 1); % linear fit
% err = (polyval(p, 1:len).' - locs).^2;
% outliers = err > 1000 * median(err);

% outliner peaks can occur at the edges, but the signal tends to be scaled
% very differently here so we can easily filter the
% outliers using the built-in isoutliers function on peak values.

% outliers = isoutlier( diff(pks.^2).^2 );
% outliers(1:5)
% outliers((end-5):end)
% start = find(~outliers, 1);
% stop = find(~outliers, 1, 'last');
% locs = locs(start:(stop+1));
% pks = pks(start:(stop+1));

% outliers = isoutlier(pks);
% locs = locs(~outliers);  % these are the locations of the SLM columns
% pks = pks(~outliers);

% /// all outlier stuff ditched. The solution was just put a zero order
% block. Then I robustly only get the slm diffraction. However sometimes
% small peaks from the off columns bleed in. I set a threshold function to
% reject those. Should work if the light level gives peaks around 1.5. 


thresh = @(a) a*(0.5 + exp( -(locs - 1.25E6).^2/ 8E5^2 ) );
a = 0.05;
while true
    ind = thresh(a) < pks;
    if nnz(ind) <= 256
        break
    end
    a = a + 0.01;
end
locs = locs(ind);
pks = pks(ind);

figure;
plot(signal);
hold on
plot(locs, pks, 'V')
title('Identified SLM Column locations')
plot(locs,  a*(0.5 + exp( -(locs - 1.25E6).^2/ 8E5^2 ) ), 'LineWidth', 3)
legend('data', 'peaks', 'threshold')
savefig( fullfile(datapath, 'peaks.fig'))

if length(locs) ~= 256
    msgbox(['The function found ', num2str(length(locs)), ...
        ' SLM column locations, but there should be 256...', ...
        ' Check the alignment and test specimens.'], ...
        'Voltage LUT Calibration Failed!');
    error('Incorrect number of peaks found. No files written')
end

% the locs are the coordinates of every other column, starting with 2
% use interpolation to fill in the other columns
fullLocs = round(interp1(2:2:512, locs, 1:512, 'pchip'));
% map the sample numbers to voltages. The feedback voltages have noise.
% To make them better I fit a linear model of feedback to control voltages.
% Then we can use the values of the model instead of the measured ones for
% the feedback voltages. These two arrays are the calibration.
% This approach doesn't assume any functional form for the voltage LUT, but
% just that the control voltage is lienarlly related to the feedback, which
% it is for this galvo driver.
voltsControl = obj.ao.galvoRAS(fullLocs);
voltsFeedback = obj.ai.GalvoPos_RAS(fullLocs);
p = polyfit(voltsControl, voltsFeedback, 1);
voltsFeedback = polyval(p, voltsControl);
figure; plot([voltsControl, voltsFeedback]);
xlabel('SLM Column Index')
ylabel('Volts')
legend('Control Voltage', 'Feedback Voltage')
savefig( fullfile(datapath, 'voltages.fig'))
% dlmwrite(...
%     savepath, ...
%     [voltsControl, polyval(p, voltsControl)]);
% dlmwrite(...
%     fullfile(datapath, 'voltsLUT.dat'), ...
%     [voltsControl, polyval(p, voltsControl)]);
dlmwrite(...
    savepath, ...
    [voltsControl, voltsFeedback, flip(voltsControl), flip(voltsFeedback)]);
dlmwrite(...
    fullfile(datapath, 'voltsLUT.dat'), ...
    [voltsControl, voltsFeedback, flip(voltsControl), flip(voltsFeedback)]);
end