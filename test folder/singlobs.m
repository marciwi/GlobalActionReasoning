function obs = singlobs(globobs,ob,ag,agent)

%   obs = singlobs(globobs,ob,ag)
%
%convert the global observation to all agents' local observations assuming 
%homogeneity of the agents
%
%Inputs------------------------------------------------------------
%globobs:         	observation number [1,obs space]
%ob:                number of possible observations per agent
%ag:                number of agents in the problem
%
%Outputs-----------------------------------------------------------
%state:             vector of states per agent
%
%   See also: GLOBOBS.

if nargin<4; agent=0; end;	%optional input

globobs = globobs-1;
base = dec2base(globobs,ob,ag);

if any(size(base)>[inf,1]) && agent~=0 %multiple global obs at once
	base=base(:,agent);
elseif agent~=0		%only one global obs
	base=base(agent);
end

for i=1:length(base)
    obs(i) = str2double(base(i))+1;
end
end
