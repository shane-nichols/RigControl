function indices = makeRandomOnColumns(N, skip, start, stop)

indices = zeros(1, N);
i = start;
while i <= stop
    p = rand() > 0.8;
    if p
        indices(i) = 1;
        i = i + skip;
    else
        i = i + 1;
    end
end

end