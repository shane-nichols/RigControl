classdef GeneralWaveform < Waveform
% GeneralWaveform object. Allows one to load any waveform into a Waveform
% object. Properties:
%  dt,          Sampling period, in sec
%  waveform,    A [1, N] array of a numeric class
    properties
        waveform  % Keep a copy of the waveform for robustness
    end
    
    methods
        function obj = GeneralWaveform(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            % resets obj.I to obj.waveform.
            % The reasoning behind having two copies is if the user
            % calls obj.makeOutputWaveform directly, or via a call to
            % 'set', then the maps applied in the superclass will be
            % multiply applied. Storing a copy prevents this.
            obj.I = obj.waveform;
        end
        
    end
    
end
