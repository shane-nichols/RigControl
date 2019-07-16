function arr = getRelativeLaserPowerFromVoltage(arr)
% This calibration applies to the Satsuma HP2. It is the actual laser power
% rather than the 2P emission brightness or something. It was measured with
% a photodiode placed near the laser head. The curve agrees well with the
% one in the laser manual. The values scale from 0 to 1 for the voltage
% range 0 to 5 volts. With this curve, one can obtain a calibration curve
% from a one point measurement of the absolute power.
%
% arr: input array of laser modulator voltages.
%      output array of relative laser power (between 0 and 1)

% This function loads a fit object that was obtained from the code below:
%
% d = dlmread('laserPowerVsVoltage.dat');
% x = d(1,:).';
% y = d(2,:).';
% y_smooth = imgaussfilt(y, 3);
% y = y - y(1);
% y = y ./ y(end);
% laserPowerModel = fit(x, y_smooth, 'pchipinterp');
% save('laserPowerModel_fitObj.m', 'laserPowerModel')
%
% Shane Nichols, 2019

load('laserPowerModel_fitObj.mat', 'laserPowerModel');
arr = laserPowerModel(arr);
end