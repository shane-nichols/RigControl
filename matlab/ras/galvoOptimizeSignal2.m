function control = galvoOptimizeSignal2(control, feedback, target, ioDelay, ax) 
% galvoOptimizeSignal() optimizes the control signal from the feedback
% signal, but there the target voltages refer to the control signal itself.
% Thus, the scale, offset, and IO delay are compensated for before
% computing the error. This function, however, uses a target waveform that
% directly refers to the feedback signal. Therefore the error is computed
% by simply subtracting the target and feedback signals. The control signal
% is initially computed with an approipate IO delay with respect to the
% target. This delay has to be applied to each error signal before adding
% the error to the next control signal.

p = [0.9994   -0.0056];
feedback = mean(reshape(feedback, length(control), []), 2).';
feedback = timeshift_galvo_feedback(control, polyval(p, feedback));
feedback = imgaussfilt(feedback, 10);
% pts = round(1E-5 / target_wf_obj.get_homogeneous_dt());
% er = imgaussfilt((target_wf_obj.waveform - feedback) .* ...
%     Waveform.expandLogical(target_wf_obj.rampShutter, -pts, -pts), 10);
er = imgaussfilt((target.waveform - feedback), 10);
control = control + er / 10;
plot(ax, er);
end