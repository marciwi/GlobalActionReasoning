function dist=getStart(mdp)

if		isfield(mdp,'start')
	if strcmp(mdp.start,'uniform')
		dist = ones(1,mdp.nrStates)*(1/mdp.nrStates);
	elseif ischar(mdp.start)
		dist=zeros(1,mdp.nrStates);
		dist(idTerm(mdp,linediv(mdp.start),3))=1;
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

function result = idTerm(mdp,cell,termtype)

%termtype == action(1) , observation(2) or state(3)
%% Find local-string to compare to
comparer = strvcat('mdp.localActions','mdp.localObservations','mdp.states');
if all(isstrprop(char(cell),'digit'))
	if isa(eval(comparer(termtype,:)),'numeric')
		cmpcell = linediv(num2str(0:eval(comparer(termtype,:))-1));
	else
		sz = size(linediv(eval(comparer(termtype,:))));
		cmpcell = linediv(num2str(0:sz(1)-1));
	end
else
	cmpcell = linediv(char(eval(comparer(termtype,:))));
	if all(size(cmpcell)==[1 1])
		cmpcell = linediv(num2str(1:eval(comparer(termtype,:))));
	end
end

if strcmp(char(cell),'*')
	result=':';
else
	result = [];
	for i=1:length(cell)
		[foo,localterm]=max(strcmp(cmpcell,cell(i)));
		if foo==0
			result = [result str2double(cell2mat(cell(i)))];
		else
			result = [result localterm];
		end
	end

	if		termtype==1
		result=globact(result,mdp.ac,mdp.ag);
	elseif	termtype==2
		result=globobs(result,mdp.ob,mdp.ag);
	elseif	termtype==3
		%for now, expect global states in the definition
	end
end
end