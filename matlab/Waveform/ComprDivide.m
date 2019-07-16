classdef ComprDivide < CompBinary
% Waveform composition object. Addition.
    
    methods
        
        function obj = ComprDivide(wf1, wf2)
            obj = obj@CompBinary(wf1, wf2); % call superclass contructor
        end
        
        function obj = makeWaveform(obj)
            if obj.wf2_is_scalar
                if obj.reverse
                    obj.I = obj.wf2 ./ get(obj.wf1, 'I');
                else
                    obj.I = get(obj.wf1, 'I') ./ obj.wf2;
                end
            else
                validate(obj)
                if obj.reverse
                    obj.I = get(obj.wf2, 'I') ./ get(obj.wf1, 'I');
                else
                    obj.I = get(obj.wf1, 'I') ./ get(obj.wf2, 'I');
                end
            end
            updateTimeStuff(obj)
        end
    end

end
