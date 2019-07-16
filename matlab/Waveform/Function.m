classdef Function < Waveform
% Function Waveform object. Creates waveform from lambda function.
% Properties and defaults:
%   dt = 0.0001       Sampling period, in sec.
%   T = 1             Total time, in seconds.
%   fun               Universal function handle: @(t) fun(t)

    properties
        fun
    end
    
    methods
        function obj = Function(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            obj.I = obj.fun(obj.getWaveformTimes);
        end
    end

end


% % example using anonymous function
% figure;
% fun = @(t) 50 * exp(-t * 3);
% t = 0:0.001:1;
% subplot(2,1,1);
% plot(t, fun(t));
% title('Rate Function: @(t) 50 * exp(-t * 3)')
% ax=subplot(2,1,2);
% PulseRate('rate_fun', fun ).plot(ax)
% title('Resulting Waveform');
% 
% % example using a Waveform object
% figure;
% fun = Ramp('height', 50);
% ax = subplot(2,1,1);
% fun.plot(ax);
% title('Rate Function: Ramp(''height'', 50)')
% ax=subplot(2,1,2);
% PulseRate('rate_fun', fun ).plot(ax)
% title('Resulting Waveform');
