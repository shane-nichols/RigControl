classdef Steps < Waveform
% Steps Waveform object. Creates a set of evenly spaced steps
% of constant height. 
% Properties and defaults:
%  dt = 0.0001,            Sampling period, in sec
%  tOn = 0.1,              Duration of pulse, in seconds
%  tOff = 0.1,             Duration of time between pulses, in seconds
%  height = 0.2,           Amplitude of the first pulse relative to offset
%  offset = 0,             Offset value from 0
%  Nsteps = 5,             Number of pulses, postive integer
%
% Modified on Sept, 27, 2018 to include an off-time at the end. 
% Total time is Nsteps*(ton + toff) + toff
    properties
        tOn = 0.1
        tOff = 0.1
        height = 1
        offset = 0
        Nsteps = 5
    end
    
    methods
        
        function obj = Steps(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            N_on = round(obj.tOn / obj.dt);
            N_off = round(obj.tOff / obj.dt);
            onAr = zeros(1, N_on) + (obj.offset + obj.height);
            offAr = zeros(1, N_off) + obj.offset;
            obj.I = [repmat([offAr, onAr], 1, obj.Nsteps), offAr];
            obj.T = length(obj.I) .* obj.dt;
        end
    end

end
