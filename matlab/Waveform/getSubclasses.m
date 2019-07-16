function out = getSubclasses()
% returns a string listing subclasses to 'Waveform'
names = strsplit(ls(pwd));
names = sort(names(endsWith(names, '.m')));
out = [];
for i=1:length(names)
    name = names{i};
    fid = fopen(name);
    if contains(fgetl(fid), '< Waveform')
        [~, nameNoExt] = fileparts(name);
        out = [out, nameNoExt, newline];
    end
    fclose(fid);
end
end
