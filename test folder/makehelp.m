function makehelp(filename)

%% Explanation
%The idea is to automatically make some sort of help generator for the
% function files
% Don't alter ANYTHING about the files other than the lines that will be
% read by the help function. 
% The first line will be a copy of the function description with all inputs
% and outputs shown to the user
% further elaboration about the variables should be copied from within this
% file or the 'notes' file.

%% Variables
filename  = 'randomoutputfile.m'; %just used for testing
outputfile = 'randomoutputfile.m'; %just used for testing

fid = fopen(filename,'r');

file = '';
while ~feof(fid)
	line = fgetl(fid);
	if max(size(line))==0; line = ' ';	end;
	file = strvcat(file ,line);
end
[lines, maxwidth] = size(file);

fclose('all');

%% Parse first line for inputs and outputs
%check if its a function
if strcmp(file(1,[1:8]),'function')
	A = sscanf(file(1,:),'function %s =');	%all outputs
	C = sscanf(file(1,:),'%s',3);
	B = sscanf(file(1,:),'%s');
	B = B(1,1+length(C):end);				%function name and inputs
end

%% parse for outputs
stop=0;
outputs='';
if A(1)=='['; A = strtok(A(2:end),']'); end
while stop==0
	[word,A] = strtok(A,',');
	outputs = strvcat(outputs,word);
	if isempty(word); stop=1;	end;
end

%% parse fo fcn name and inputs
stop=0;
inputs='';
[fcnName,B]=strtok(B,'(');
if B(1)=='('; B = strtok(B(2:end),')'); end;
while stop==0
	[word,B] = strtok(B,',');
	inputs = strvcat(inputs,word);
	if isempty(word); stop=1;	end;
end

%% Define help section
hlpline='%';
hlpline = strvcat(hlpline,['%	' file(1,:)],'%');
hlpline = strvcat(hlpline,'% Inputs:....................');
[n,o]=size(inputs);
for i=1:n
	hlpline = strvcat(hlpline,varhelp(sscanf(inputs(i,:),'%s')));
end
hlpline = strvcat(hlpline,'% Outputs:....................');
[n,o]=size(outputs);
for i=1:n
	hlpline = strvcat(hlpline,varhelp(sscanf(outputs(i,:),'%s')));
end
hlpline = strvcat(hlpline,'%');

%% Maybe add disclaimer & copyright stuff here
%
%
%% Find and remove current help section
% might need to preserve some explanation..or copy that from a central file too
i=2;
hlp=0;
helplines = [];
while hlp==0
	if file(i,1) == '%' 
		helplines = [helplines i];
	else 
		hlp = i;
	end
	i=i+1;
end
pt1 = min(helplines);
pt2 = max(helplines)+1;

%% input new help section
file2 = strvcat(file(1:pt1,:),hlpline,file(pt2:end,:));
file=file2;

%% write to actual file and double up on % characters
outfid = fopen(outputfile,'w');
[n,o]=size(file);
for i=1:n
	if file(i,1)=='%'
		thisline = ['%' file(i,:)];
	else
		[b,e]=strtok(file(i,:),'%');
		thisline = [b '%' e];
		if thisline(end)=='%'; thisline=thisline(1:(end-1)); end;
	end
	fprintf(outfid,[deblank(thisline) '\n']);
end
fclose('all');

end

function fullstring = varhelp(str)
%compare str to given set of variables and add description to it
switch str
	case{'P'}
		ot='%   P(SxS''xA)			:state transition function';
	case{'O'}
		ot='%   O(AxS''xO)			:observation function';
	case{'R'}
		ot='%   R(SxS''xA) or R(SxA):reward function';
	case{'discount'}
		ot='%   discount			:reward discount factor';
	case{'ob'}
		ot='%   ob					:# of observations per agent';
	case{'st'}
		ot='%   st					:# of states per agent';
	case{'ac'}
		ot='%   ac					:# of actions per agent';
	case{'ag'}
		ot='%   ag					:# of agents';
	case{'V'}
		ot='%	V					:Value function';
	case{'b'}
		ot='%	b					:Belief State';
	case{'h'}
		ot='%	h					:Horizon length/depth';
	case{'mdp'}
		ot='%	mdp					:struct containing mdp problem';
	case{'bpSet'}
		ot='%	bpSet				:set of belief points';
	case{'filename'}
		ot='%	filename			:string containing filename';
	case{'global_policy'}
		ot='%	global_policy		:global policy';
	case{'local_policy'}
		ot='%	local_policy		:local policy';
	otherwise
		ot=['%	' str];
end
fullstring=ot;
end