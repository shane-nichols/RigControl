function coef = fit_galvo_drive_feedback(drive_waveform, feedback_waveform)
% galvo feedback signals lag behind the actual drive signal. The amount is
% mostly constant but seems to vary a bit with galvo speed. The feedback
% signal is also shifted and scaled a bit. This function finds the optimal
% scaling coefficients and time shift and returns the corrected waveform.
%
% coef = [scaleFactor, offset, timeShift]
%
% drive = circshift(scaleFactor .* feedback + offset, -timeshift)

drive_s = sort(drive_waveform);
feedb_s = sort(feedback_waveform);
fun = @(coef) sum( ((coef(1) .* feedb_s + coef(2)) - drive_s).^2);
pout = fminsearch(fun, [1, 0]);
feedback_waveform = pout(1) .* feedback_waveform + pout(2);

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

coef = [pout, i];

end



