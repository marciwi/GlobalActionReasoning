function dist=getStart(mdp)

if		isfield(mdp,'start')
	if strcmp(mdp.start,'uniform')
		dist = ones(1,mdp.nrStates)*(1/mdp.nrStates);
	else
		dist = mdp.start;
	end
elseif	isfield(mdp,'start_include')
	dist=zeros(1,mdp.nrStates);
	include =		linediv(mdp.start_include);
	compareto=	linediv(mdp.states);
	for i=1:length(include)
		dist = dist + (strcmp(include(i),compareto))';
	end
	dist=dist*(1/sum(dist));
end
end

function words = linediv(line)
    C = textscan(line,'%s');
    words=cellstr(C{1});
end
