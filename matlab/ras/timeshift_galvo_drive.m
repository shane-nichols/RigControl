function [shifted_waveform, i] = timeshift_galvo_drive(drive_waveform, feedback_waveform)
% galvo feedback signals lag behind the actual drive signal. The amount is 
% mostly constant but seems to vary a bit with galvo speed. This function
% just finds the optimal shift and returns the corrected waveform.
%
% i is the number of samples that the feedback waveform was shifted to
% match the drive waveform

fun = @(i) sum((drive_waveform - circshift(feedback_waveform, -i)).^2);
max_shift = length(drive_waveform);

i = 1;
error = fun(0);
delta_error = inf;
while delta_error > 0
    new_error = fun(i);
    delta_error = error - new_error;
    error = new_error;
    i = i + 1;
    if i == max_shift
        warning('max shift reached, no minimum found')
        break
    end
end
i = i - 2;
shifted_waveform = circshift(drive_waveform, i);



