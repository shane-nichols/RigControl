classdef SinWave < Waveform
% SinWave Waveform object. Simple Sine wave. 
%   For a cosine, set 'phase = pi/2'.
% Properties and defaults:
%   dt = 0.0001     Sampling period, in sec
%   T = 1           Total time, in seconds
%   f = 50          Frequency, in Hz
%   phase = 0       Phase offset, in radians
%   height = 1      Height of pulses above offset
%   offset = 0      Offset value from 0

    properties
        f = 50
        phase = 0
        height = 1
        offset = 0
    end
    
    methods
        function obj = SinWave(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            x = 0:obj.dt:(obj.T - obj.dt);
            obj.I = obj.offset + obj.height .* sin(2*pi*x*obj.f + obj.phase);
        end
    end

end
