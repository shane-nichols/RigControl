classdef PulseRate < Waveform
% PulseRate Waveform object. Creates pulse train where the instantanteous 
% pulse rate is given by an arbitrary rate function. An absolute value will
% be applied to the rate function as 'negative rates' are not meaningful.
% Properties and defaults:
%   dt = 0.0001       Sampling period, in sec.
%   T = 1             Total time, in seconds. Is overridden if 'rate_fun'
%                       is a Waveform object (assumes rate function's time)
%   rate_fun          Either a universal function handle or a Waveform object
%   initial_val = 0.5 Number between 0 and 1; With 1 first pulse is at t = 0
%   ton = 0.001       Duration of each pulse
%   height = 1        Height of pulses above offset
%   offset = 0        Offset value from 0

    properties
        rate_fun = @(t) 50 * exp(-t * 3)
        initial_val = 0.5;
        ton = 0.001
        height = 1
        offset = 0
    end
    
    methods
        function obj = PulseRate(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            if isa(obj.rate_fun, 'function_handle')
                fx = obj.rate_fun( 0:obj.dt:(obj.T - obj.dt) );
            elseif isa(obj.rate_fun, 'Waveform')
                obj.rate_fun.set('dt', obj.dt);
                obj.T = get(obj.rate_fun, 'T');
                fx = get(obj.rate_fun, 'I');
            end
            % integral of f(X)
            s = obj.initial_val + cumsum(abs(fx)) .* obj.dt;
            pulse_inds = find(diff([0, s - mod(s, 1)]));  % indices where pulses start
            on_samples = int32(obj.ton ./ obj.dt);
            pulse_inds = pulse_inds(pulse_inds < (length(fx) - on_samples - 1));
            obj.I = zeros(1, int32(obj.T / obj.dt));
            for ind = pulse_inds
                obj.I(ind:(ind+on_samples)) = obj.height;
            end
            obj.I = obj.I + obj.offset;
        end
        
        function out = getPulseTimes(obj)
            wf = get(obj, 'I');
            indices = find(diff(wf) == 1);
            if wf(1) == 1
                indices = [1, indices];
            end
            t = obj.getWaveformTimes();
            out = t(indices);
        end
        
        function out = getPulseOffIntervals(obj)
            pulseTimes = obj.getPulseTimes();
            out = diff(pulseTimes) - obj.ton;
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
