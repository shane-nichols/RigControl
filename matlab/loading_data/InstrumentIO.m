classdef InstrumentIO < matlab.mixin.Copyable & dynamicprops
    
    methods
        function obj = InstrumentIO()
        end
        
        function ax = plot(obj)
            figure();
            ax = axes('NextPlot', 'add');
            names = properties(obj);
            for i=1:length(names)
                plot(obj.(names{i}), ax);
            end
            legend(names);
        end
    end
end     
    