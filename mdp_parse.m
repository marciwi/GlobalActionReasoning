function mdp = mdp_parse(filename)
% mdp = mdp_parse(filename)
%Arguments ----------------------------------------------------------
%   filename:     string of path to filename
%Evaluation ---------------------------------------------------------
%  mdp (struct) containing..
%    P(SxSxA)            :state transition function
%    R(SxSxA) or R(SxA)  :reward function
%    O(SxAxO)            :observation function
%    discount            :reward discount factor
%    reward              :defines wether 'cost' or 'reward' is used
%    states              :# of states in global problem
%    observations        :build up of observations in global problem
%    actions             :build up of actions in the global problem
%    start               :initial state distribution
%    ob                  :# of observations per agent
%    st                  :# of states per agent
%    ac                  :# of actions per agent
%    singlact            :build up of single agent actions
%    ag                  :# of agents
%
%% open the file
if ~isempty(filename)
file = fopen(filename,'r');
line = nxtline(file);

%% initialize basic variables
opts = strvcat('agents:','discount:','states:','values:',...
				'start:','start_include:','actions:','observations:');
mdp = struct();
stop=0;		% should be set to 1 when the first item of the transition
			% matrix is seen (will stop this part of the parsing process)
%parse all lines not associated with O,R,P
while(stop==0)
words = linediv(line);
	if max(strcmp(words(1),opts))
		identifier = char(words(1));
		if size(words)==1 %suspected information written in next line(s)
			addline = [];	brk=0;
			while brk==0;
				checkline=nxtline(file); %check next line
				smallcheck = linediv(checkline);
				if ~max(strcmp(smallcheck(1),strvcat(opts,'T:')))
					%add the line if it has no identifier
					addline = strvcat(addline,checkline);
				else
					%otherwise go to next identifier
					line=checkline;
					brk=1;
				end
			%actually add the stored lines
			mdp = setfield(mdp,identifier(1:end-1),addline);
			end
		else	%all info on current line
			mdp = setfield(mdp,identifier(1:end-1),...
				strtrim(line(length(identifier)+1:end)));
			line = nxtline(file);
		end
	elseif strcmp(words(1),'T:')
		stop=1;		
	end
end
saveline=line;	%These are overwritten in the re-eval part...stupid I know
savewords=words;%should be fixed later on
%% Reevaluate the variables
[n,foo]=size(opts);
for i=1:n
	identifier=strtrim(opts(i,:));	%obtain readable identifier from list
	if isfield(mdp,identifier(1:end-1))
		line=getfield(mdp,identifier(1:end-1));%read contents from mdp
		[height,foo]=size(line);
		values=[];
		% value should only be a digit (or space or punctuation)
		if isstrprop(line,'digit') + isstrprop(line,'punct') +isstrprop(line,'wspace')
			for k=1:height
				words=linediv(line(k,:));	%split contents up
				value = [];
				for j=1:length(words)
					value = [value, str2double(words(j))];
				end
				values=[values;value];
			end
			mdp=setfield(mdp,identifier(1:end-1),values); %alter values
		end
	end
end

%% Deduce other variables
mdp.nrAgents		= sizes(mdp.agents);
mdp.nrActions		= sizes(mdp.actions);
mdp.nrObservations	= sizes(mdp.observations);
mdp.nrStates		= sizes(mdp.states);

mdp.ag =  sizes(mdp.nrAgents);          ag=mdp.ag;%number of agents
mdp.ac =  mdp.nrActions^(1/ag);			ac=mdp.ac;%actions per agent
mdp.ob =  mdp.nrObservations^(1/ag);	ob=mdp.ob;%observations per agent
mdp.st =  peragent(mdp.states,ag);		st=mdp.st;%states per agent

mdp.localActions = peragent(mdp.actions,ag);
mdp.localObservations = peragent(mdp.observations,ag);
mdp.localStates = peragent(mdp.states,ag);

%% Build Transition Matrix
%T: <a1 a2...an> : <start-state> : <end-state> : %f
line=saveline;
words=savewords;
mdp.P=zeros(mdp.nrStates,mdp.nrStates,mdp.nrActions);
stop=0;
while stop==0
    if char(words(1))=='T:'
	words=	words(2:end); % remove 'T:'
	type=	find(strcmp(words,':'));	
	%action=	idAction(mdp,words(1:type(1)-1));
	action=	idTerm(mdp,words(1:type(1)-1),1);
	startstate = ':';		nxtstate=':';
	if length(type)>1
		%startstate=idState(mdp,words(type(1)+1:type(2)-1));
		startstate=idTerm(mdp,words(type(1)+1:type(2)-1),3);
		if length(type)>2
			%nxtstate=idState(mdp,words(type(2)+1:type(3)-1));
			nxtstate=idTerm(mdp,words(type(2)+1:type(3)-1),3);
		end
	end
	chance=	idChance(mdp,words(type(end)+1:end),action,'transition');
	mdp.P(startstate,nxtstate,action)=chance;
    %actionnr = globact([checkind(2,words) checkind(3,words)],ac,ag);
    %mdp.P(checkind(5,words),checkind(7,words),actionnr)=str2double(words(length(words)));%action is difficult
    line=nxtline(file);
    else
        stop = 1;
    end
words = linediv(line);
end

%% Build Observation Matrix
% O: <a1 a2...an> : <end-state> : <o1 o2 ... om> : %f
mdp.O = zeros(mdp.nrActions,mdp.nrStates,mdp.nrObservations);
stop=0;
while stop==0;
   if char(words(1))=='O:'
		words=	words(2:end); % remove 'O:'
		type=	find(strcmp(words,':'));	
		action=	idTerm(mdp,words(1:type(1)-1),1);
		nxtstate=':';		observation=':';
		if length(type)>1
			nxtstate=idTerm(mdp,words(type(1)+1:type(2)-1),3);
			if length(type)>2
				observation = idTerm(mdp,words(type(2)+1:type(3)-1),2);
			end
		end
		chance=	idChance(mdp,words(type(end)+1:end),action,'observation');
		mdp.O(action,nxtstate,observation)=chance;
		line=nxtline(file);
		
       %obsnr = globobs([checkind(7,words) checkind(8,words)],ob,ag);
       %actionnr = globact([checkind(2,words) checkind(3,words)],ac,ag);
       %mdp.O(actionnr,checkind(5,words),obsnr)=str2double(words(length(words)));
       %line=nxtline(file);
       %disp('observation funct')
       %observationnr=globobs(observations,ob,ag);
       %actionnr = globact([str2double(words(2))
       %str2double(words(3))],ac,ag);
   else
       stop=1;
   end
words = linediv(line);
end

%% Build Reward Matrix
%R: <a1 a2...an> : <start-state> : <end-state> : <o1 o2 ... om> : %f
mdp.R=zeros(mdp.nrStates,mdp.nrStates,mdp.nrActions);
stop=0;
while stop==0
    if char(words(1))=='R:'
		words=	words(2:end); % remove 'R:'
		type=	find(strcmp(words,':'));	
		action=	idTerm(mdp,words(1:type(1)-1),1);
		nxtstate=':';		startstate=':';
		if length(type)>1
			startstate=idTerm(mdp,words(type(1)+1:type(2)-1),3);
			if length(type)>2
				nxtstate = idTerm(mdp,words(type(2)+1:type(3)-1),3);
			end
		end
		chance=	idChance(mdp,words(type(end)+1:end),action,'reward');
		mdp.R(startstate,nxtstate,action)=chance;
		
    %actionnr = globact([checkind(2,words) checkind(3,words)],ac,ag);
    %mdp.R(checkind(5,words),checkind(7,words),actionnr)=str2double(words(length(words)));%action is difficult
    else
        stop = 1;
    end
    if feof(file)
        line = '!! end of file succesfully reached';
    else 
        line=nxtline(file);
    end
words = linediv(line);
end

%% closing up & cleaning up
%mdp.end     = line;     % Better if commented out later!!
%mdp.words   = words;    % Better if commented out later!!
fclose(file);
end
end

function chance=idChance(mdp,cell,action,which)
%%
if strcmp(action,':'); actionln=mdp.nrActions;	else actionln=1;	end;

%%
%type could be used to decide upon the chance matrix size

if		strcmp(which,'transition')
	chance =	zeros(mdp.nrStates,mdp.nrStates,actionln);
	identity =	eye(mdp.nrStates);
	unif =		repmat(1./(sum(ones(mdp.nrStates),2)),1,mdp.nrStates);
elseif	strcmp(which,'observation')
	chance =	zeros(actionln,mdp.nrStates,mdp.nrObservations);
	%identity =	eye()
	unif =	repmat(1./(sum(ones(mdp.nrStates,mdp.nrObservations),2)),1,mdp.nrObservations);
elseif	strcmp(which,'reward')
	% 'do nothing' would be the best here
	%chance=zeros(mdp.nrStates,mdp.nrStates,mdp.nrActions);
end

%%
if		strcmp(cell2mat(cell),'identity')
	for i=1:max(actionln,length(action))
		chance(:,:,i)=identity;
	end
elseif	strcmp(cell2mat(cell),'uniform')
	if	strcmp(which,'observation')
		for i=1:max(actionln,length(action))
			chance(i,:,:)=unif;
		end
	else
		for i=1:max(actionln,length(action))
			chance(:,:,i)=unif;
		end
	end
else
	chance=str2double(cell2mat(cell));
end
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

function out = peragent(var,ag)
%%used in mdp_parse
if nargin<2;	ag=1;	end;

sz =  size(var);
if isa(var,'char')
	out=var(1,:);
else
	if sz(1)>1
		out=var(1);
	else
		%out=log(var)/(log(ag));
		out=var^(1/ag);
		%out=nr;
	end
end
end

function words = linediv(line)
    C = textscan(line,'%s');
    words=cellstr(C{1});
end

function line = nxtline(file)
%%used in mdp_parse
i=0;
while(i==0)
    line = fgetl(file);
    if line(1)~='#'; i=1; end;
end
disp(line)
end

function res = sizes(var)
%%used in mdp_parse
sz =  size(var);
res=1;
for i=1:sz(1)
	if isa(var(i,:),'char')
		split=size(linediv(var(1,:))); 
	else
		split=var;
	end
	if split(1)~=0; res=res*split(1); end;
end
end
