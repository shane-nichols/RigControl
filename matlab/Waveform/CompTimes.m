classdef CompTimes < CompBinary
% Waveform composition object. Addition.

    methods
        
        function obj = CompTimes(wf1, wf2)
            obj = obj@CompBinary(wf1, wf2); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            if obj.wf2_is_scalar
                obj.I = get(obj.wf1, 'I') .* obj.wf2;
            else
                validate(obj)
                obj.I = get(obj.wf1, 'I') .* get(obj.wf2, 'I');
            end
            updateTimeStuff(obj)
        end
    end

end
