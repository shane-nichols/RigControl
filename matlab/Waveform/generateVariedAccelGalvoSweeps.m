function objAr = generateVariedAccelGalvoSweeps(min, max, N, varargin)
if isempty(varargin)
    range = varargin{:};
else
    range = 4.4;
end
% generates an array of GalvoSweep objects having linearlly spaced max
% acceleration.
accel = linspace(min, max, N);
objAr = repelem( ...
    GalvoSweeps('rangeV', range, ...
                'sweepTime', 512/250000, ...
                'dt', 0.000001, ...
                'maxAccel', 1E6 , ...
                'Nsweeps', 10), ...
    length(accel));
for i=1:length(accel)
    objAr(i) = objAr(i).copy().set('maxAccel', accel(i));
end