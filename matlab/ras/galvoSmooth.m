function waveform = galvoSmooth(waveform, tau, dt)
    tmax = -log(0.001)*tau;
    t = dt:dt:tmax;
    length(t)
    kernal = exp(-t/tau);
    kernal = [flip(kernal), 1, kernal] / (2*sum(kernal) + 1);
    waveform = conv(waveform, kernal, 'same');
end