classdef InstrumentWaveform
    properties
        waveform
        dt
        name
    end
    
    properties (Dependent)
        times
    end
    
    methods
        function obj = InstrumentWaveform(waveform, dt, name)
            obj.waveform = waveform;
            obj.dt = dt;
            obj.name = name;
        end
    end
    
    methods
        function t = get.times(obj)
            Nsamples = length(obj.waveform);
            t = linspace(0, (Nsamples - 1) * obj.dt, Nsamples);
        end
        
        function ax = plot(obj, varargin) 
            % ax = WaveformObj.plot();
            % ax = WaveformObj.plot(axisHandle);
            % ax = WaveformObj.plot(LINE PROPERTIES);
            % ax = WaveformObj.plot(axisHandle, LINE PROPERTIES);
            %
            % Builds a plot of the total waveform (if waveform is an object
            % array) with each piece of the waveform in a different color.
            % If you just want a plot of the total waveform having a single
            % line, use plot(obj.getWaveformTimes, get(obj, 'I'))
            if ~isempty(varargin) && isa(varargin{1}, 'matlab.graphics.axis.Axes')
                ax = varargin{1};
                p = 2;
            else
                figure();
                ax = axes('NextPlot', 'add');
                p = 1;
            end
            plot(ax, obj.times, obj.waveform, varargin{p:end});
            if p == 1
                xlabel(ax, 'Time (s)')
                title(obj.name)
            end
                xlabel('Time (s)')
        end
        
    end
end