classdef Constant < Waveform
% Constant Waveform object. Creates a constant waveform.
% Properties and defaults:
%  dt = 0.0001,     Sampling period, in sec
%  T = 1            Duration, in sec
%  value = 1        Value of the waveform
    properties
        value = 1
    end
    
    methods
        
        function obj = Constant(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            obj.I = obj.value + zeros(1, int32(obj.T / obj.dt));
            obj.T = length(obj.I) .* obj.dt;
        end
    end

end
