function voltsLUTinterpolate_old(datapath, lutPath, first, colInd, oversample)
% voltsLUTinterpolate(datapath, lutPath, first, last, colInd)
%
% The result of voltsLUTdataAuto is a good starting point, but not good
% enough. This program takes the data from the Start HS Galvo LUT button
% and adjust the LUT by interpolation.
%
% datapath: str, path to the pmt data file. 
% lutPath: str, path to the current LUT file (will be overwritten unless fails)
% first: int, first circshift value
% colInd: int[], SLM column indices (indexed from 1)
% oversample: int, over sample factor (sample rate / rep rate)
%
% Shane Nichols, 2019

data = dlmread(datapath);
centers = zeros(1, size(data, 2));
x = transpose(1:size(data,1));
for i = 1:size(data,2)
    f = fit(x, data(:,i), 'gauss1');
    centers(i) = f.b1 + first - 1;
end

centers = reshape(centers, [], 2);
figure;
plot(centers)
hold on
p1 = polyfit(colInd, centers(:,1).', 3);
plot(polyval(p1, colInd));
p2 = polyfit(colInd, centers(:,2).', 3);
plot(polyval(p2, colInd));
legend('Forward Sweep Centers', ...
       'Backward Sweep Centers', ...
       'Forward Poly3 Fit', ...
       'Backward Poly3 Fit', ...
       'location', 'northeastoutside')
ylabel('Circshift Value')

fullCols = 1:512;
interValsF = fullCols - (polyval(p1, fullCols) / oversample);
interValsB = fullCols - (polyval(p1, fullCols) / oversample);


v = dlmread(lutPath).';
fd = interp1(fullCols, v(1,:), interValsF, 'pchip', 'extrap');
ff = interp1(fullCols, v(2,:), interValsF, 'pchip', 'extrap');
bd = interp1(flip(fullCols), v(3,:), flip(interValsB), 'pchip', 'extrap');
bf = interp1(flip(fullCols), v(4,:), flip(interValsB), 'pchip', 'extrap');
v = [fd; ff; bd; bf].';

dlmwrite(lutPath, v, ',');
dlmwrite('voltsLUT.dat', ',');

end

