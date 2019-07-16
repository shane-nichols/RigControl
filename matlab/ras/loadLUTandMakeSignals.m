v = dlmread('C:\Program Files\National Instruments\LabVIEW 2016\vi.lib\RAS\voltsLUT.dat');
[control, blank] = galvoTriangleWave2(v(:,1).',5E6, 1/250000);
target = galvoTriangleWave2(v(:,2).', 5E6, 1/250000);
optimized = dlmread('optimizedGalvoWaveform.dat', '\t');
figure; 
plot([circshift(control, -41); optimized].');


