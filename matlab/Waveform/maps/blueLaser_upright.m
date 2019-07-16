function wf = blueLaser_upright(wf, varargin)
%   wf = blueLaser_upright(wf)
%   wf = blueLaser_upright(wf, 'mW')
%
    % AOTF calibration 488 nm laser on Upright.
    % The y axis of the loaded file is in mW. Measured with the Thorlabs
    % PM400 meter using the 20X multiphoton objective. DMD was set to
    % white. 
    % If the flag 'mW' is not passed, the waveform is interpreted as 
    % fractional intensity and should therefore be in the range (0, 1).
    % If the flag 'mW' is passed, then the waveform should be in
    % units of mW. The function will return an error is the requested
    % values are outside the range.
    %
    % Shane Nichols 12/18/2018

    s = load('blueLaser_upright.mat', 'laser');
    if nargin == 1
        s.laser(:, 2) = s.laser(:, 2) ./ max(s.laser(:, 2));
    elseif strcmpi(varargin{1}, 'mw')
        % do nothing
    else
        error('Unrecognized flag')
    end
    wf = interp1(s.laser(:,2), s.laser(:,1), wf, 'linear');
    if any(isnan(wf))
        error('Waveform out of range of interpolation, see the help')
    end
end