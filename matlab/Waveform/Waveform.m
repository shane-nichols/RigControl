classdef (CaseInsensitiveProperties=true) ...
        Waveform < matlab.mixin.SetGet & ...
        matlab.mixin.Heterogeneous & ...
        matlab.mixin.Copyable
    
    properties
        dt = 0.0001
        T = 1
        I = []
        % The properties below are for mapping raw waveforms to instrument
        % waveforms
        shutter = []
        map function_handle
    end
    
    methods (Abstract)
        % each concrete subclass must implement this method, which must
        % set obj.I
        makeWaveform(obj)
    end
    
    
    methods 
        function obj = Waveform(varargin)
            if ~isempty(varargin)
                set(obj, varargin{:});
            else
                obj.makeOutputWaveform;
            end
        end
        
        function set.shutter(obj, value)
            if any(length(value) == [0, 3])
                obj.shutter = value;
            else
                error('Property ''shutter'' must be a [1, 3] or empty array')
            end
        end
        
    end

    methods (Sealed)
        
        % returns concatenated waveform array. Alias for get(obj, 'I')
        function wf = waveform(obj)
            wf = get(obj, 'I');
        end
        
        % returns total duration in seconds. Alias for get(obj, 'T')
        function t = duration(obj)
            t = get(obj, 'T');
        end
        
        % OVERLOADED BINARY OPERATORS
        function out = plus(obj1, obj2)
            out = CompPlus(obj1, obj2);
        end
        
        function out = minus(obj1, obj2)
            out = CompMinus(obj1, obj2);
        end
        
        function out = times(obj1, obj2)
            out = CompTimes(obj1, obj2);
        end
        
        function out = rdivide(obj1, obj2)
            out = ComprDivide(obj1, obj2);
        end
        
        % OVERLOADED SET/GET INTERFACE
        function obj = set(obj, varargin) 
            for i=1:numel(obj)
                set@matlab.mixin.SetGet(obj(i), varargin{:});
%                 p = properties(obj(i));
%                 for j=1:length(p)
%                     if isa(obj(i).(p{j}), 'Waveform')
%                         obj(i).(p{j}).set(varargin{:});
%                     end
%                 end
                obj(i).makeOutputWaveform;
            end
        end

        function value = get(obj, varargin) 
            % value = get(obj, varargin)
            % value = get(objAr, varargin)
            %
            % For single objects, value returns a cell array if the length
            % of varargin is greater than one. For object arrays, get
            % returns a cell array if length(varargin) == 1 and a 2D cell
            % array otherwise. 
            %
            % SPECIAL USAGE
            %
            % value = get(objAr, 'T')
            %
            % For objects arrays, get is overloaded to return the total
            % time of the array for the property 'T', that is, the sum of
            % 'T' for all objects. 
            %
            % value = get(objAr, 'I')
            %
            % For object arrays, get is overloaded to return a concatenated
            % waveform for all objects. That is a 1xN array of the net
            % waveform of the objects. 
            %
            % To obtain instead a cell array of 'T' or 'I' for each object,
            % one can use dot notation, i.e., value = {objAr.T}

            if length(varargin) == 1
                if numel(obj) > 1
                    switch varargin{1}
                        case 'T'
                            value = sum(cell2mat({obj.T}));
                        case 'I'
                            value = cell2mat({obj.I});
                        otherwise
                            value = get@matlab.mixin.SetGet(obj, varargin{:});
                    end
                else
                    value = get@matlab.mixin.SetGet(obj, varargin{:});
                end
            else
                value = get@matlab.mixin.SetGet(obj, varargin);
            end
        end
        
        % main waveform making function
        function makeOutputWaveform(obj)
            % maps a base waveform created by a concrete subclass to the
            % final outputted waveform. This functionality is intended to
            % apply transformations to a waveform that are not subclass
            % dependent. 
            obj.makeWaveform();
            if ~isempty(obj.map)
                % Applies a mapping to the waveform.
                % This method can be used to apply any general
                % transformation on the waveform data, such as correcting
                % for the nonlinearity of analog optical modulation
                % devices. The map to apply is determined by the obj.map
                % property; which is a function handle. The function
                % signiture must be `wf = fun(wf)` where wf is a one
                % dimensional array.
                obj.I = obj.map(obj.I);
            end
            if ~isempty(obj.shutter)
                obj.applyShutter
            end      
        end
        
        % utilities
        function applyShutter(obj)
            %  applyShutter(obj)
            %   
            %   Applies a shutter to 'I'. The new waveform (wf2) is
            %   logical and is computed from the original waveform (wf).
            %   Whenever wf > level, wf2 is true. Additionally, to account
            %   for shutter delays, wf2 will be true 'timeBefore' each
            %   rising edge and 'timeAfter' each falling edge, with these
            %   times given in milliseconds. The three parameters are set
            %   in obj.shutter = [level, timeB4, timeAft].
            c = num2cell(obj.shutter);
            [level, timeB4, timeAft] = c{:};
            pts = ceil( [timeB4, timeAft] ./ 1000 ./ obj.dt);
            obj.I = single(obj.expandLogical(obj.I > level, pts(1), pts(2)));
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
                ax.XLabel.String = 'Time (s)';
                p = 1;
            end
            if numel(obj) == 1
                plot(ax, 0:obj.dt:(obj.T-obj.dt), obj.I, varargin{p:end});
                ax.XLabel.String = 'Time (s)';
            else
                np = ax.NextPlot;
                ax.NextPlot = 'add';
                t = -obj(1).dt;
                for i = 1:length(obj)
                    t = (0:obj(i).dt:(obj(i).T-obj(i).dt)) + t(end) + obj(i).dt;
                    plot(ax, t, obj(i).I, varargin{p:end})
                end
                ax.NextPlot = np;
            end      
        end
        
        function [t, dt] = getWaveformTimes(obj)
            % [t, dt] = getWaveformTimes(obj)
            % [t, dt] = getWaveformTimes(objAr)
            %
            % Returns the time values of the waveform, with t(1) = 0, as
            % well as the difference vector dt = diff(t). 
            % This function accepts either objects or object arrays.
            dt = [];
            t = [];
            last = -obj(1).dt;
            for i = 1:length(obj)
                t = [t, (obj(i).dt:obj(i).dt:obj(i).T) + last]; %#ok<AGROW>
                last = t(end);
                dt = [dt, obj(i).dt .* ones(1, int32(obj(i).T ./ obj(i).dt))]; %#ok<AGROW>
            end
            dt = dt(2:end);
        end
        
        function dt = get_homogeneous_dt(obj)
            dts = get(obj, 'dt');
            if iscell(dts)
                if all(cellfun(@(x) isequal(dts{1}, x), dts))
                    dt = dts{1};
                else
                    error('Waveform array contains heterogeneous sample rate')
                end
            else
                dt = dts;
            end
        end
    end
    
    
    methods (Static)  
        function array = expandLogical(array, ptsB4, ptsAft)
            % array = expandLogical(array, ptsB4, ptsAft)
            %
            % 'array' is a 1D logical array. This function moves all rising
            % edges (0 to 1 transitions) to an index 'ptsB4' towards the
            % beginning of the array and moves all falling edges 'ptsAft'
            % towards the end of the array. A continuous block of 1's
            % results if the edges of adjacent blocks coincide or cross.
            % Accepts row or column vectors and preserves orientation.
            %
            % Example: expandLogical([0 0 1 0 0 1 0 0 0], 1, 2)
            %   returns: [0 1 1 1 1 1 1 1 0]
            
            % check types
            array = logical(array);
            ptsB4 = round(ptsB4);
            ptsAft = round(ptsAft);
            % find rising and falling edges
            ris = find(diff(array) == 1) + 1;
            fal = find(diff(array) == -1) + 1;
            % move edges
            ris = ris - ptsB4;
            fal = fal + ptsAft;
            % deal with overruns
            b4 = sum(ris < 0);
            ris = ris( ris > 0 & ris <= length(array) );
            fal = fal( fal > 0 & fal <= length(array) );
            % reconstruct new array
            risAr = zeros(size(array));
            risAr(ris) = 1;
            risAr(1) = risAr(1) + b4 + array(1);
            falAr = zeros(size(array));
            falAr(fal) = -1;
            array = logical(cumsum(falAr + risAr));
        end
    end
    
end
