function img = make_grating_image_for_SLM(pitches, grating_template)
% This function returns a 512x512 img for the SLM. Each column is a grating
% function with properties determined by the grating_template. 

% pitches, 512 element array of pitch values, or a waveform object 
% grating_template, Waveform object to use for grating function. Should
%                   have a 'f' property

img = zeros(512, 512);

if isa(pitches, 'Waveform')
    pitches = pitches.waveform();
end

for i=1:512
    img(:, i) = grating_template.set('f', 1/pitches(i)).waveform;
end

