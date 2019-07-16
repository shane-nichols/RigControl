classdef (CaseInsensitiveProperties=true) ...
        rasDaqData < matlab.mixin.Copyable & matlab.mixin.SetGet
    
    properties
        date
        datapath
        name
        daqClockSource
        sampleRate
        repetitionsType
        repetitionsNumber
        repetitionsInterval
        ao
        ai
        do
        di
        daqTimes
        spots
    end
    
    properties (Dependent)
        daqTimesWithRepeats
        columnIndexed
        columnIndexedTimes
    end
    
    methods
        function obj = rasDaqData(varargin)
            if nargin == 0
                dataDir = pwd;
            else
                dataDir = varargin{1};
            end
            obj.datapath = dataDir;
            [~, obj.name] = fileparts(dataDir);
            % read parameter file and cast data types
            t = readtable(fullfile(dataDir,'rasParameters.txt'), ...
                'HeaderLines',0,'ReadVariableNames',0,'Delimiter',',');
            t = table2cell(t);
            t(:,3) = casttype(t(:,3), t(:,2));
            t = cell2struct(t(:,3).',t(:,1).',2);
            % fix repetition variables if there were no repetitions
            if strcmp(t.repetitionsType, 'Single Shot')
                t.repetitionsNumber = 1;
                t.repetitionsInterval = 0;
            end
            % set object properties
            set(obj, rmfield(t, {'aoNames', 'aiNames', 'doNames', 'diNames', 'waveformSizes'}));
            % parse waveforms.bin
            if isfile(fullfile(dataDir, 'rasWaveforms.bin'))
                fileID = fopen(fullfile(dataDir, 'rasWaveforms.bin'));
                wfms = fread(fileID, 'single', 'ieee-be');
                fclose(fileID);
                idx = 1;
                % analog outputs
                if t.waveformSizes(1) > 0
                    n = t.waveformSizes(1);          % number waveforms
                    len = t.waveformSizes(2);        % length waveforms
                    el = n*len;                      % number elements
                    obj.ao = cell2struct(num2cell(reshape(wfms(idx:(idx+el-1)), len, n), 1 ).' ,...
                        t.aoNames.');
                    idx = idx + el;
                end
                % analog inputs
                if t.waveformSizes(3) > 0
                    n = t.waveformSizes(3);          % number waveforms
                    len = t.waveformSizes(4);        % length waveforms
                    el = n*len;                      % number elements
                    obj.ai = cell2struct(num2cell(reshape(wfms(idx:(idx+el-1)), len, n), 1 ).' ,...
                        t.aiNames.');
                    idx = idx + el;
                end
                % digital IO
                if any(t.waveformSizes([5,7]) > 0)
                    c = num2cell(t.waveformSizes(5:8));
                    [ndo, ldo, ndi, ldi] = c{:};
                    % Next few lines converts 1D decimal to 2D logical array.
                    % The calculation is done on int16. Increase bit depth for
                    % more than 16 digital channels.
                    % This approach is much faster than looping 'dec2binvec'
                    binAr = zeros(max([ldo, ldi]), ndo+ndi, 'logical');
                    wfms = int16(wfms(idx:end));
                    for i=1:(ndo+ndi)
                        binAr(:, i) = rem(wfms,2);
                        wfms = idivide(wfms, 2);
                    end
                    if ndo > 0
                        obj.do = cell2struct(num2cell(binAr(1:ldo, 1:ndo), 1 ).' ,...
                            t.doNames.');
                    end
                    if ndi > 0
                        obj.di = cell2struct(num2cell(binAr(1:ldi, (ndo+1):end), 1 ).' ,...
                            t.diNames.');
                    end
                end
                setDAQTimes(obj)
            end
            
%             f_colindx = fullfile(obj.datapath, 'columnIndexed.bin');
%             if isfile(f_colindx)
%                 fileID = fopen(f_colindx);
%                 try
%                     wfms = fread(fileID, 'single', 'ieee-be');
%                 catch er
%                     fclose(fileID);
%                     rethrow(er);
%                 end
%                 fclose(fileID);
%                 obj.columnIndexed = reshape(wfms(4:end), flip(wfms(1:3).'));
%             end
            
            f_json = fullfile(obj.datapath, 'ras.json');
            if isfile(f_json)
                obj.spots = getfield(jsondecode(fileread(f_json)), 'spots');
            end
        end
        
        function setDAQTimes(obj)
            % t = getDAQTimes(obj)
            % returns an array of time values, in seconds, with sample 1 at
            % t = 0. The times are for the output channels. This method is
            % called in the constructor automatically. If obj.daqTimes is
            % modified, use this method to restore it.
            names = fieldnames(obj.ao);
            Nsamples = length(obj.ao.(names{1}));
            obj.DAQTimes = linspace(0, (Nsamples - 1)./obj.sampleRate, Nsamples);
        end
        
        function t = get.daqTimesWithRepeats(obj)
            % This array should be identical to
            %   t = repelem(obj.daqTimes, obj.repetitionsNumber)
            % This should be the daq times for the input channels when
            % when repetitions mode is 'DAQ Repeats'
            % I made this a dependent property under the assumption that it
            % will not always be in memory (the array is trivial but can be
            % quite large). It is calculated on the fly when read.
            names = fieldnames(obj.ao);
            Nsamples = length(obj.ao.(names{1})) * obj.repetitionsNumber;
            t = linspace(0, (Nsamples - 1)./obj.sampleRate, Nsamples);
        end
        
        function t = get.columnIndexedTimes(obj)
            Nsamples = 2 * obj.repetitionsNumber;
            names = fieldnames(obj.ao);
            dt = length(obj.ao.(names{1})) / obj.sampleRate / 2;
            t = linspace(0, (Nsamples - 1) * dt, Nsamples);
        end
        
        function out = get.columnIndexed(obj)
            % Returns an array of size [Nsamples, Nspots, Nchannels]
            % This function avoids making a temporary copy of the analog
            % waveforms and is therefore more memory efficient. 
            pxInd = cell2mat({obj.spots.pixelIndex});
            out = obj.getColumnIndexed(pxInd);
        end
        
        function out = getColumnIndexed(obj, indices)
            fInd = indices * 8;
            bInd = (512 - indices + 1) * 8 + length(obj.daqTimes)/2;
            names = fieldnames(obj.ao);
            Nspots = length(indices);
            Nsamples = length(obj.ao.(names{1})); 
            sweepInd = transpose(1:Nsamples:(obj.repetitionsNumber * Nsamples));
            fInd = fInd + sweepInd;
            bInd = bInd + sweepInd;
            names = fieldnames(obj.ai);
            out = zeros(2*obj.repetitionsNumber, Nspots, length(names));
            delays = [0, -2];
            for i=1:length(names)
                for n=1:Nspots
                    out(1:2:end,n,i) = obj.ai.(names{i})(fInd(:,n) + delays(i));
                    out(2:2:end,n,i) = obj.ai.(names{i})(bInd(:,n) + delays(i));
                end
            end
        end
        
        function ind = getSpotIndices(obj)
            ind = cell2mat({obj.spots.pixelIndex});
        end
        
        function out = sweepAverage(obj, channel)
            if nargin == 1
                channel = 1;
            end
            if isnumeric(channel)
                names = fieldnames(obj.ai);
                channelName = names{channel};
            else
                channelName = channel;
            end
            out = mean(reshape(obj.ai.(channelName), [], obj.repetitionsNumber), 2).';
        end
        
        function fig = plotColumnIndexed(obj, channel)
            if nargin == 1
                channel = 1;
            end
            fig = figure;
            t = obj.columnIndexedTimes;
            s = obj.columnIndexed(:,:,channel);
            N = size(s, 2);
            for i=1:N
                subplot(N,1,i);
                plot(t, s(:,i));
            end
        end
        
    end
    
    methods (Static)
        function out = snr(traces)
            out = mean(traces) ./ std(traces);
        end
    end
end


function carray = casttype(carray, types)
% this local function is used to type cast the parameter file
for i=1:length(carray)
    switch types{i}
        case 'float'
            carray{i} = str2double(carray{i});
        case 'int'
            carray{i} = int32(str2double(carray{i}));
        case 'float[]'
            carray{i} = str2num(carray{i}); %#ok<ST2NM>
        case 'int[]'
            carray{i} = int32(str2num(carray{i})); %#ok<ST2NM>
        case 'str[]'
            carray{i} = strsplit(carray{i}, '\t');
        otherwise
            % 'str' is returned by default
    end
end
end