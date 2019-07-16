classdef SquareWave < Waveform
% SquareWave Waveform object. When the phase is zero, the signal starts at
% a rising edge for any duty cycle. 
% Properties and defaults:
%   dt = 0.0001     Sampling period, in sec
%   T = 1           Total time, in seconds
%   f = 50          Frequency, in Hz
%   phase = 0       Phase offset, in radians
%   duty = 0.5      Duty cycle (fraction of on vs off)
%   height = 1      Height of pulses above offset
%   offset = 0      Offset value from 0

    properties
        f = 50
        phase = 0
        height = 1
        duty = 0.5
        offset = 0
    end
    
    methods
        function obj = SquareWave(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            x = 0:obj.dt:(obj.T - obj.dt);
            phasei = (1/2 - obj.duty)*pi;
            threshold = sin(phasei);
             % a tiny number is added to the phase so transitions are not
             % exactly zero, otherwise N rising and N falling will not be
             % equal for duty = 0.5
            obj.I = obj.offset + obj.height .* ...
                (sin(2*pi*x*obj.f + phasei + obj.phase + 0.000000001) > threshold);
        end
    end

end
