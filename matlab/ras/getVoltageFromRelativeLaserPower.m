function arr = getVoltageFromRelativeLaserPower(arr)
% This function performs the opposite lookup as
%     getRelativeLaserPowerFromVoltage()
%
% arr: input array of relative laser power (between 0 and 1)
%      output of laser modulation voltage between 0 and 5 volts
%
% To have a strictly monotonic function in relative power, it was necessary
% to use additional smoothing and to restrict the range of voltages from
% about 0.5 to 4.8. Outside this range the laser power is essentially
% constant. I also used NN interpolation to avoid the function blowing up
% upon extrapolation given the very large derivatives there.

% This function loads a fit object that was obtained from the code below:
%
% x = d(1,:).';
% y = d(2,:).';
% y = imgaussfilt(y, 5);
% y = y - y(1);
% y = y ./ y(end);
% x = x(21:196);
% y = y(21:196);
% invLaserPowerModel = fit(y, x, 'pchipinterp');
% save('invLaserPowerModel_fitObj.mat', 'invLaserPowerModel')
%
% Shane Nichols, 2019

load('invLaserPowerModel_fitObj.mat', 'invLaserPowerModel');
arr = invLaserPowerModel(arr);
end