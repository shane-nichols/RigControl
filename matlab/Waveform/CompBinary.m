classdef CompBinary < Waveform
% Abstract class for binary composition

    properties
        wf1
        wf2
    end
    
    properties (Hidden)
        wf2_is_scalar
        reverse
    end
    
    methods (Abstract)
        makeWaveform(obj)
    end
    
    methods
        function obj = CompBinary(wf1, wf2)
            message = ['Composed waveforms must have identical time', ...
                        'arrays or one operand must be scalar numeric'];
            reverse = false;
            if isa(wf1, 'Waveform')
                if isa(wf2, 'Waveform')
                    b = false;
                elseif isscalar(wf2) && isnumeric(wf2)
                    b = true;
                else
                    error(message)
                end
            elseif isa(wf2, 'Waveform')
                if isscalar(wf1) && isnumeric(wf1)
                    temp = wf1;
                    wf1 = wf2;
                    wf2 = temp;
                    b = true;
                    reverse = true;
                else
                    error(message);
                end
            end
            % call superclass contructor
            obj = obj@Waveform('wf1', wf1, 'wf2', wf2,...
                'wf2_is_scalar', b, 'reverse', reverse);
        end
        
        function validate(obj)
            if ~(isequal(get(obj.wf1, 'dt'), get(obj.wf1, 'dt')) && ...
                         get(obj.wf1, 'T') == get(obj.wf2, 'T'))
                error('Waveforms cannot be summed as they have different time values')
            end
        end
        
        function updateTimeStuff(obj)
            obj.T = get(obj.wf1, 'T');
            obj.dt = obj.wf1(1).dt;
        end
        
    end
end
