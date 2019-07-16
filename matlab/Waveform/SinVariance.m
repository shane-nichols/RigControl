classdef SinVariance < Waveform
% SinVariance Waveform object. Creates a waveform with constant mean and
% sin modulated variance. The variance is uniformly distributed and
% fluctuates over a characteristic timescale
% Properties and defaults:
%   dt = 0.0001     Sampling period, sec
%   T = 1           Total time of the stimulus, sec
%   tau = 0.003     Characteristic timescale of fluctuations, sec
%   I0 = 1          Mean value
%   sigma0 = 1      Central variance
%   dSigma = 0.5    Variance modulation amplitude
%   sigmaF = 0.2    Variance modulation frequency, Hz
    properties
        tau = 0.003
        I0 = 1
        sigma0 = 1
        dSigma = 0.5
        sigmaF = 0.2
    end
    
    methods
        function obj = SinVariance(varargin)
            obj = obj@Waveform(varargin{:}); % call superclass contructor
        end
        
        function obj = makeWaveform(obj) % waveform model
            N = obj.T ./ obj.dt;
            wf = obj.sigma0 * (1 + obj.dSigma * ...
                sin(2*pi*obj.sigmaF * (1:N) .* obj.dt)) ; %#ok<*BDSCI>
            wf = sqrt(2 * wf.^2 * obj.dt ./ obj.tau) .* randn(1, N);
            wf(1) = obj.I0; % initialize at mean
            for n = 2:N
                wf(n) = wf(n-1) + (obj.I0 - wf(n-1))./obj.tau .* obj.dt + wf(n);
            end
            obj.I = wf;
        end
        
    end
    
end
        
        