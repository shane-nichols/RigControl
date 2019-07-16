function img = make_grating(pitch)

% CONSTANTS FOR DMD
WIDTH = 1280;
HEIGHT = 800;

try
    square_wave = SquareWave('dt', 1, 't', WIDTH, 'f', 1/pitch, 'height', 255);
catch
    addpath 'X:\Lab\Labmembers\Shane Nichols\Matlab\Waveform'
    square_wave = SquareWave('dt', 1, 't', WIDTH, 'f', 1/pitch, 'height', 255);
end
img = repmat((square_wave.I), HEIGHT, 1);

end