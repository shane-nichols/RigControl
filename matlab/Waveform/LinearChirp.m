classdef LinearChirp < Waveform
% LinearChirp Waveform object. Linearlly chirped Sine Wave, i.e., a sine
%   wave in which the instantaneous frequency changes linearlly in time.
%   For a cosine, set 'phase = pi/2'.
% Properties and defaults:
%   dt = 0.0001     Sampling period, in sec
%   T = 1           Total time, in seconds
%   f1 = 1          Initial Instantaneous Frequency, in Hz
%   f2 = 1          Final Instantaneous Frequency, in Hz
%   phase = 0       Phase offset, in radians
%   height = 1      Height of pulses above offset
%   offset = 0      Offset value from 0

    properties
        f1 = 1
        f2 = 50
        phase = 0
        height = 1
        offset = 0
    end
    
    methods
        function obj = LinearChirp(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            x = 0:obj.dt:(obj.T - obj.dt);
            k = (obj.f2 - obj.f1) ./ (2*obj.T);
            obj.I = obj.offset + obj.height .* ...
                sin((2*pi) .* (x .* obj.f1 + k .* x.^2) + obj.phase);
        end
    end

end
