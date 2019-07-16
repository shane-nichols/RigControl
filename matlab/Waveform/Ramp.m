classdef Ramp < Waveform
% Ramp Waveform object. Creates a single ramp.
% Properties and defaults:
%  dt = 0.0001,     Sampling period, in sec
%  tBefore = 0.1    Duration at offset before ramp, in seconds
%  tRamp = 0.8      Duration of ramp, in seconds
%  tAfter = 0.1     Duration at offset after ramp, in seconds
%  offset = 0       offset from zero
%  height = 1       End value of the ramp, relative to offset
    properties
        tBefore = 0.1
        tRamp = 0.8
        tAfter = 0.1
        offset = 0
        height = 1
    end
    
    methods
        
        function obj = Ramp(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            iBefore = obj.offset + zeros(1, round(obj.tBefore / obj.dt));
            iAfter = obj.offset + zeros(1, round(obj.tAfter / obj.dt));
            iRamp = linspace(obj.offset, obj.offset + obj.height, obj.tRamp / obj.dt);
            obj.I = [iBefore, iRamp, iAfter];
            obj.T = length(obj.I) .* obj.dt;
        end
        
    end

end
