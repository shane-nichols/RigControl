classdef Step < Waveform
% Step Waveform object. Creates a single step.
% Properties and defaults:
%  dt = 0.0001,     Sampling period, in sec
%  tBefore = 0.1    Duration at offset before ramp, in seconds
%  tStep = 0.8      Duration of ramp, in seconds
%  tAfter = 0.1     Duration at offset after ramp, in seconds
%  offset = 0       Offset from zero
%  height = 1       End value of the ramp, relative to offset
    properties
        tBefore = 0.1
        tStep = 0.8
        tAfter = 0.1
        offset = 0
        height = 1
    end
    
    methods
        function obj = Step(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            iBefore = obj.offset + zeros(1, round(obj.tBefore / obj.dt));
            iAfter = obj.offset + zeros(1, round(obj.tAfter / obj.dt));
            iStep = (obj.offset + obj.height) + zeros(1, round(obj.tStep / obj.dt));
            obj.I = [iBefore, iStep, iAfter];
            obj.T = length(obj.I) .* obj.dt;
        end
    end

end
