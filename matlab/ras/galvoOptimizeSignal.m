function new_signal = galvoOptimizeSignal(control, feedback, target_wf_obj, ax) 
% feedback correction approach

p = [0.9994   -0.0056];
feedback = mean(reshape(feedback, length(control), []), 2).';
feedback = timeshift_galvo_feedback(control, polyval(p, feedback));
feedback = imgaussfilt(feedback, 10);
% pts = round(1E-5 / target_wf_obj.get_homogeneous_dt());
% er = imgaussfilt((target_wf_obj.waveform - feedback) .* ...
%     Waveform.expandLogical(target_wf_obj.rampShutter, -pts, -pts), 10);
er = imgaussfilt((target_wf_obj.waveform - feedback), 10);
new_signal = control + er / 10;
plot(ax, er);
end
