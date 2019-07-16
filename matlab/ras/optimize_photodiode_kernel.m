function kernel = optimize_photodiode_kernel(signal, dt, rep_rate, N_samples)

% initial kernel as exponential decay
kernel = exp( - (0:(N_samples - 1)));
kernel = kernel ./ sum(kernel);
kernel = kernel.';

% construct error function
os = 1 / (dt * rep_rate);  % oversample factor
spike_times = true(size(signal));
spike_times(1:os:length(spike_times)) = false;


    function err = err_fun(kernel)
        Q = deconvreg(signal, kernel);
        err = std(Q(spike_times)).^2;
    end

kernel = fminunc(@(x) err_fun(x), kernel);

end