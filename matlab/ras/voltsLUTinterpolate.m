function v = voltsLUTinterpolate(datapath, savepath, colInd)
% voltsLUTinterpolate(datapath, lutPath, first, last, colInd)
%
% The result of voltsLUTdataAuto is a good starting point, but not good
% enough. This program takes the data from the Start HS Galvo LUT button
% and adjust the LUT by interpolation.
%
% datapath: str, path to the pmt data file. 
% lutPath: str, path to the current LUT file (will be overwritten unless fails)
% colInd: int[], SLM column indices (indexed from 1)
% v: double[[]], new LUT
% Shane Nichols, 2019

pmtData = dlmread(fullfile(datapath, 'pmtData.dat'));
posData = dlmread(fullfile(datapath, 'posData.dat'));
Nshifts = size(pmtData, 1);
Ncols = size(pmtData, 2);
centers = zeros(1, Ncols);
amps = centers;
x = transpose(1:Nshifts);
% fit a Gaussian to each columns pmt signal, and extract the peak location
for i = 1:Ncols
    f = fit(x, pmtData(:,i), 'gauss1');
    centers(i) = f.b1;
    amps(i) = f.a1;
end

% reshape centers to seperate forward and backward sweeps
centers = reshape(centers, [], 2);
amps = reshape(amps, [], 2);
% fit a third order polynominal to the shift values
p1 = polyfit(colInd, centers(:,1).', 3);
p2 = polyfit(colInd, centers(:,2).', 3);

figure;
plot(amps)
savefig( fullfile(datapath, 'amps.fig'))

figure;
plot(centers)
hold on
plot(polyval(p1, colInd));
plot(polyval(p2, colInd));
legend('Forward Sweep Centers', ...
       'Backward Sweep Centers', ...
       'Forward Poly3 Fit', ...
       'Backward Poly3 Fit', ...
       'location', 'northeastoutside')
ylabel('Circshift Value')
savefig( fullfile(datapath, 'shifts.fig'))

% evaluate the polynomial for all SLM columns
fullCols = 1:512;
interpValsF = polyval(p1, fullCols);
interpValsB = polyval(p2, fullCols);
% split the galvo position feedback signal into forward and backward sweeps
posDataF = posData(:, fullCols);
posDataB = posData(:, fullCols + 512);
clear posData
% construct the position feedback lookup table values by interpolating the
% measured signal at the shift values for each column.
ff = zeros(512, 1); % forward feedback
bf = zeros(512, 1); % backward feedback
for i=fullCols
    ff(i) = interp1(posDataF(:, i), interpValsF(i));
    bf(i) = interp1(posDataB(:, i), interpValsB(i));
end
% load the current lookup table, and fit a linear model relating drive and
% feedback voltages. Use the model to convert the new feedback voltages to
% drive voltages. 
v = dlmread(savepath);
p = polyfit(v(:,2), v(:,1), 1);
fd = polyval(p, ff); % forward drive
bd = polyval(p, bf); % backward drive
v = [fd, ff, flip(bd), flip(bf)]; % new LUT

figure; plot(v);
xlabel('SLM Column Index')
ylabel('Volts')
legend('Forward Control Voltage', ...
       'Forward Feedback Voltage', ...
       'Backward Control Voltage', ...
       'Backward Feedback Voltage')
savefig( fullfile(datapath, 'voltages.fig'))

dlmwrite(savepath, v, ',');
dlmwrite(fullfile(datapath, 'voltsLUT.dat'), v, ',');

end

