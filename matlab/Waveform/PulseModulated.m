classdef PulseModulated < Waveform
% PulseModulated Waveform object. Creates pulse train of constant duty
% cycle (mean stimulus) and sin-modulated frequency. 
% Properties and defaults:
%   dt = 0.0001     Sampling period, in sec
%   T = 1           Total time, in seconds
%   fcarrier = 50   Center pulse frequency, in Hz
%   fmod = 1        Modulation frequency, in Hz
%   amod = 20       Modulation amplitude, in Hz
%   duty = 0.5      Duty cycle (fraction of on vs off)
%   height = 1      Height of pulses above offset
%   offset = 0      Offset value from 0

    properties
        fcarrier = 50
        fmod = 1
        amod = 20
        duty = 0.5
        height = 1
        offset = 0
    end
    
    methods
        function obj = PulseModulated(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            x = 0:obj.dt:(obj.T - obj.dt);
            phase = (1/2 - obj.duty)*pi;
            threshold = sin(phase);
            obj.I = obj.offset + obj.height .* (sin(2*pi*x*obj.fcarrier + phase - ...
                obj.amod/obj.fmod * sin(2*pi*x*obj.fmod)) > threshold);
        end
    end

end
