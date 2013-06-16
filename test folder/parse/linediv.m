function words = linediv(line)
    C = textscan(line,'%s');
    words=cellstr(C{1});
end
