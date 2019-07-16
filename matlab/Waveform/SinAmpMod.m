classdef SinAmpMod < Waveform
% SinAmpMod Waveform object. Creates a amplitude modulated sin wave.
% Properties and defaults:
%   dt = 0.0001     Sampling period, in sec
%   T = 1           Total time, in seconds
%   fcarrier = 50   Carrier frequency, in Hz
%   fmod = 1        Amplitude modulation frequency, in Hz
%   amod = 1       Modulation amplitude
%   height = 1      Height of waveform above offset
%   offset = 0      Offset value from 0

    properties
        fcarrier = 50
        fmod = 1
        amod = 1
        height = 1
        offset = 0
    end
    
    methods
        function obj = SinAmpMod(varargin)
            % SinAmpMod('propertyName', 'Value')
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            x = 0:obj.dt:(obj.T - obj.dt);
            obj.I = obj.offset + ...
                obj.height .* (sin(2*pi*x*obj.fcarrier)+1)/2 .* ...
                (1 - obj.amod .* (sin(2*pi*x*obj.fmod)+1)/2);
        end
    end

end
