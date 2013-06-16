function action = singlact(globact,ac,ag,agent)

%%  action = singlact(globact,ac,ag)
%
% converts the global action to a corresponding array of 
% single agent actions
%
%Inputs------------------------------------------------------------
%globact:         	global action corresponding to the single agent
%                   set of actions
%ac:                number of possible actions per agent
%ag:                number of agents in the problem
%
%Outputs-----------------------------------------------------------
%action:            array of single states per agent
%
%   See also: GLOBACT.

%% check inputs
if nargin<4; agent=0; end;	%optional input

%%
globact = globact-1;
base = dec2base(globact,ac,ag);

if any(size(base)>[inf,1]) && agent~=0 %multiple global act at once
	base=base(:,agent);
elseif agent~=0		%only one global act
	base=base(agent);
end

for i=1:length(base)
    action(i) = str2double(base(i))+1;
end
end
