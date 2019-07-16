classdef StepRamp < Waveform
% StepRamp Waveform object. Creates a set of evenly spaced steps
% of linearlly increasing height. An off-time can be placed between steps.
% Properties and defaults:
%  dt = 0.0001,            Sampling period, in sec
%  tOn = 0.1,              Duration of pulse, in seconds
%  tOff = 0.1,             Duration of time between pulses, in seconds
%  heightFirst = 0.2,      Amplitude of the first pulse relative to offset
%  heightLast = 1,         Amplitude of the last pulse relative to offset
%  offset = 0,             Offset value from 0
%  Nsteps = 5,             Number of steps, postive integer

    properties
        tOn = 0.1
        tOff = 0.1
        heightFirst = 0.2
        heightLast = 1
        offset = 0
        Nsteps = 5
    end
    
    methods
        function obj = StepRamp(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            N_on = round(obj.tOn / obj.dt);
            N_off = round(obj.tOff / obj.dt);
            amps = linspace(obj.heightFirst, obj.heightLast, obj.Nsteps) + obj.offset;
            offAr = ones(1, N_off) .* obj.offset;
            obj.I = offAr;
            for i=amps
                obj.I = [obj.I, ones(1, N_on) .* i, offAr];
            end
            obj.T = length(obj.I) .* obj.dt;
        end
    end

end
