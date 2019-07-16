classdef (CaseInsensitiveProperties=true) ...
        InstrumentControl < matlab.mixin.Copyable & matlab.mixin.SetGet
    
    % future: Derive from FunctionGenerator - factor out common code
    properties
        version
        acquisitionType
        date
        datapath
        name
        daqMasterClockSource
        daqMasterClockRate
        autoShutterNames
        filterWheels
        repetitionsType
        repetitionsNumber
        repetitionsInterval
        ao
        ai
        do
        di
        stagePosition
        % camera specific properties
        roi
        frameRate
        binningFactor
        requestedFrames
        exposure
        readoutSpeed
        triggerMode
        frames
        frameTimes
        % galvo scanning specific properties
        numSamples
        offsetTime
        flybackPixels
        xpixels
        ypixels
        % galvo path scanning specific properties
        galvoroi
        pathToScan
        pathOpenBehavior
        pathScanFrequency
        PathMoveStage
    end
    
    properties (Dependent)
        daqTimesWithRepeats
    end
    
    methods (Access=private)
        function timeShiftGalvoDriveWaveforms(obj)
            % Called in the constructor for path scanning. The galvos
            % lag behind the drive signals. But as the drive signal is
            % periodic, this just amounts a phase shift.
            k = -round(obj.offsetTime / obj.ao.galvoX.dt);
            obj.ao.galvoX.waveform = circshift(obj.ao.galvoX.waveform, k);
            obj.ao.galvoY.waveform = circshift(obj.ao.galvoY.waveform, k);
        end
    end
    
    methods
        function obj = InstrumentControl(varargin)
            if nargin == 0
                dataDir = pwd;
            else
                dataDir = varargin{1};
            end
            obj.datapath = dataDir;
            [~, obj.name] = fileparts(dataDir);
            % read parameter file and cast data types
            t = readtable(fullfile(dataDir,'Parameters.txt'), ...
                'HeaderLines',0,'ReadVariableNames',0,'Delimiter',',');
            t = table2cell(t);
            t(:,3) = casttype(t(:,3), t(:,2));
            t = cell2struct(t(:,3).',t(:,1).',2);
            if ~isfield(t, 'version')
                t.version = '0';
            end
            
            % fix repetition variables if there were no repetitions
            if strcmp(t.repetitionsType, 'Single Shot')
                t.repetitionsNumber = 1;
                t.repetitionsInterval = 0;
            end
            % set object properties
            set(obj, rmfield(t, {'names', 'types', 'sampleRates', 'waveformSizes'}));

            % parse waveforms.bin
            obj.ao = InstrumentIO();
            obj.ai = InstrumentIO();
            obj.do = InstrumentIO();
            obj.di = InstrumentIO();
            fileID = fopen(fullfile(dataDir, 'waveforms.bin'));
            wfms = fread(fileID, 'single', 'ieee-be');
            fclose(fileID);
            idx = 1;
            i = 1;
            l = length(t.types);
            while  i <= l && t.types(i) < 2
                sz = t.waveformSizes(i);
                if t.types(i) == 0
                    channel = 'ao';
                else
                    channel = 'ai';
                end
                obj.(channel).addprop(t.names{i}).NonCopyable = false;
                obj.(channel).(t.names{i}) = ...
                    InstrumentWaveform( ...
                    wfms(idx:(idx+sz-1)).', ...
                    1/t.sampleRates(i),...
                    t.names{i});
                idx = idx + sz;
                i = i + 1;
            end
            % digital IO
            if i <= l
                % This block converts 1D decimal to 2D logical array.
                % The calculation is done on int16. Increase bit depth for
                % more than 16 digital channels.
                % This approach is much faster than looping 'dec2binvec'
                nwf = length(t.types(i:end));
                binAr = zeros(max(t.waveformSizes(i:end)), nwf, 'logical');
                wfms = int16(wfms(idx:end));
                for j=1:nwf
                    binAr(:, j) = rem(wfms,2);
                    wfms = idivide(wfms, 2);
                end
                for j=1:nwf
                    sz = t.waveformSizes(i);
                    if t.types(i) == 2
                        channel = 'do';
                    else
                        channel = 'di';
                    end
                    obj.(channel).addprop(t.names{i}).NonCopyable = false;
                    obj.(channel).(t.names{i}) = ...
                        InstrumentWaveform( ...
                        binAr(1:sz, j).', ...
                        1/t.sampleRates(i), ...
                        t.names{i});
                    i = i + 1;
                end
            end
            
            if strcmp(t.acquisitionType, 'galvo Path')
                timeShiftGalvoDriveWaveforms(obj)
            end
            
            switch t.version
                case '0'               
                    if isfile(fullfile(dataDir, 'frames.bin'))
                        fid = fopen( fullfile(dataDir, 'frames.bin'));
                        obj.frames = reshape(...
                            fread(fid, '*uint16', 'l'), t.roi(3), t.roi(4), [] ...
                            );
                        fclose(fid);
                        setFrameTimes(obj);
                    end
                    
                case '1'
                    fname = fullfile(dataDir,'camera-parameters-Flash.txt');
                    if isfile(fname)
                        t2 = readtable(fname, ...
                            'HeaderLines',0,'ReadVariableNames',0,'Delimiter',',');
                        t2 = table2cell(t2);
                        t2(:,3) = casttype(t2(:,3), t2(:,2));
                        t2 = cell2struct(t2(:,3).',t2(:,1).',2);
                        set(obj, t2);
                    end
                    if isfile(fullfile(dataDir, 'frames.bin'))
                        fid = fopen( fullfile(dataDir, 'frames.bin'));
                        obj.frames = reshape(...
                            fread(fid, '*uint16', 'l'), obj.roi(3), obj.roi(4), [] ...
                            );
                        fclose(fid);
                        setFrameTimes(obj);
                    end
            end
        end
        
        
        function setFrameTimes(obj)
            % Sets the frame times assuming obj.framerate is correct and
            % the camera is in free running mode. The first time is at t=0.
            Nframes = size(obj.frames, 3);
            obj.frameTimes = linspace(0, (Nframes - 1)./obj.frameRate, Nframes);
        end
        
        function setFrameTimesFromExposureOut(obj)
            % Sets the frame times to the rising edges in the digital input
            % obj.di.cameraExposureOut minus the camera exposure time. This
            % assumes that the exposure out signal is set to VSYNC, which
            % apparently goes high at the end of the exposure time.
            % Sometimes there seems to be an additional delay depending on
            % the triggering type so use this with caution. 
            if isprop(obj.di, 'cameraExposureOut')
                d = find(diff(obj.di.cameraExposureOut.waveform.') == 1);
                obj.frameTimes = obj.di.cameraExposureOut.dt * (d-1) - obj.exposure;
                d = diff(obj.frameTimes);
                md = mean(d);
                % detect if the camera was driven by a square wave, and if
                % so, set obj.frameRate
                if (md * 1E-5) > std(d)
                    obj.frameRate = 1/md;
                end
            else
                error('Digital input cameraExposureOut does not exist');
            end
        end
        
        function [avg, reshaped] = averageGalvoPathScanWaveforms(obj, aiName)
            % [avg, reshaped] = averageGalvoPathScanWaveforms(obj, waveform)
            % Processes the path scanning waveforms to get waveform of the
            % mean value of each cycle. Optionally, the reshaped array can
            % be outputted as well. 
            %
            % aiName,   string giving the name of an input
            %           channel, i.e., obj.ai.(aiName)
            % avg,      an [1, N] array where samples along a path are
            %           averaged
            % reshaped, a [M, N] array where each column is a path scan
            sz = 1 / (obj.ai.(aiName).dt * obj.pathScanFrequency);
            reshaped = reshape(obj.ai.(aiName).waveform, sz, []);
            avg = mean(reshaped, 1);
        end
    end
    
    methods (Static)
        function make_experiment_anlaysis_template(basepath)
            s = ['basepath = ', basepath, newline, newline];
            d = dir();
            names = {d.name};
            is_folder = cellfun(@(n) isfolder(n) && ~startsWith(n, '.'), names);
            names = cell2mat(names);
            names = names(~is_folder);
            for d=names
                if isfolder(d)
                    s = [s, '%% 181219162621_mouse_iGluSnFr_GFP']; %#ok<AGROW>
                    s = [s, newline]; %#ok<AGROW>
                    s = [s, 'cd(fullfile(basepath, ', d, '));']; %#ok<AGROW>
                    s = [s, 'obj = InstrumentControl();']; %#ok<AGROW>
                    s = [s, newline]; %#ok<AGROW>
                end
            end
            display(s)
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
                carray{i} = strsplit(carray{i});
            case 'bool'
                carray{i} = carray{i} == '1';
            otherwise
                 % 'str' is returned by default
        end
    end
end