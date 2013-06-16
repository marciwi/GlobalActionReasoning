function index = checkind(nr,words)
    if char(words(nr))=='*'
        index = ':';
	elseif char(words(nr))=='uniform'
		index = 1;
	else
        index = str2double(words(nr))+1;
    end
end