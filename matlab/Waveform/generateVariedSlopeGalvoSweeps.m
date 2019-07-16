function objAr = generateVariedSlopeGalvoSweeps(tmin, tmax, N, varargin)
if isempty(varargin)
    maxAccel = varargin{:};
else
    maxAccel = 1E7;
end
% generates an array of GalvoSweep objects having linearlly spaced max
% acceleration.
t = linspace(tmin, tmax, N);
objAr = repelem( ...
    GalvoSweeps('rangeV', 5, ...
                'sweepTime', 512/250000, ...
                'dt', 0.000001, ...
                'maxAccel', maxAccel , ...
                'Nsweeps', 1), ...
    length(t));
for i=1:length(t)
    objAr(i) = objAr(i).copy().set('sweepTime', t(i));
end