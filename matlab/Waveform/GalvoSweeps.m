classdef GalvoSweeps < Waveform
% GalvoSweeps object. Wrapper for a function that makes back and forth
% linear galvo sweeps. Properties:
%  dt,          Sampling period, in sec
%  rangeV,      Voltage range of the sweep
%  sweepTime,   Duration of linear portion of a sweep, in sec
%  maxAccel,    Maximum acceleration of the galvo, V/sec^2
%  Nsweeps,     Number of sweeps
    properties
        rangeV = 0
        sweepTime = 0
        maxAccel = 0
        Nsweeps = 1
        rampShutter
    end
    
    methods
        function obj = GalvoSweeps(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            try
                [obj.I, obj.rampShutter] = ...
                    galvoTriangleWave(obj.rangeV, obj.sweepTime, obj.maxAccel, obj.dt);
            catch
                addpath('X:\Lab\Labmembers\Shane Nichols\projects\randomAccessScanner')
                [obj.I, obj.rampShutter] = ...
                    galvoTriangleWave(obj.rangeV, obj.sweepTime, obj.maxAccel, obj.dt);
            end
            obj.I = repmat(obj.I, [1, obj.Nsweeps]);
            obj.T = length(obj.I) * obj.dt;
        end
        
    end
    
end
