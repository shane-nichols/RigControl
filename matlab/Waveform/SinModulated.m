classdef SinModulated < Waveform
% SinModulated Waveform object. Creates a sine wave in which the frequency
% is modulated by another sine wave.
% Properties and defaults:
%   dt = 0.0001     Sampling period, in sec
%   T = 1           Total time, in seconds
%   fcarrier = 50   Center pulse frequency, in Hz
%   fmod = 1        Modulation frequency, in Hz
%   amod = 20       Modulation amplitude, in Hz
%   height = 1      Height of pulses above offset
%   offset = 0      Offset value from 0

    properties
        fcarrier = 50
        fmod = 1
        amod = 20
        height = 1
        offset = 0
    end
    
    methods
        function obj = SinModulated(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            x = 0:obj.dt:(obj.T - obj.dt);
            obj.I = obj.offset + obj.height .* (sin(2*pi*x*obj.fcarrier - ...
                obj.amod/obj.fmod * sin(2*pi*x*obj.fmod)));
        end
    end

end
