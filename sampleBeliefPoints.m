function bpSet = sampleBeliefPoints(restarts,mdp,h,agent)

% copied from pompdSoftware-0.1 for now 
%h=horizon
%restarts=# of restarts
%mdp (should be clear)
%global_policy (should be clear too)
%% Notes
% Dependent on:	- getRandomAction.m (own version)
%				- addBelief	(might be implemented within this file)

%% Check input(s)
if nargin<4; agent=':';	end;
if nargin<3; h=1; end;

%% Load values from mdp
ac=mdp.ac;				ag=mdp.ag;		ob=mdp.ob;
states=mdp.nrStates;	b0=getStart(mdp);
%global_policy=mdp.global_policy;

%% Initialize other variables
bpSet = [];		beliefs = [];
counter = 0;	%counter for checking invalid beliefs (not really necessary for real use)
uniform = ones(1,states)*(1/states);%uniform belief to go to if 
									%anything goes wrong..(NaNs n'such)

%% 
for m=1:restarts+1
	for i=1:ag;	beliefs=[beliefs;b0]; end; %(re)set initial beliefs
	s = gendist(b0,1,1);				   %(re)set initial state
	bpSet = [bpSet; beliefs];
	disp(['belief point sampling: started ' num2str(m) ' out of ' num2str(restarts+1) ' times'])
	
for n=1:h
	% determine action(s)
		for i=1:ag; localActions(i)=randomLocalAction(ac); end;
	% couple actions
		global_action = globact(localActions,ac,ag);
	% state transition
		[s,o,r] = getTransition(s,global_action,mdp);
	% split observations
		localObservations =	singlobs(o,ob,ag);
	% belief update
		for i=1:ag
			beliefs(i,:) = belief_update_local_action(...
				localObservations(i),beliefs(i,:),...
				localActions(i),mdp,i);
		end
	% check for invalid beliefs(NaNs) (and keep a counter)
		for i=1:ag
			if any(isnan(beliefs(i,:)))
				beliefs(i,:)=uniform;
				counter=counter+1;
			end
		end
	%add belief to set
		bpSet = [bpSet; beliefs(agent,:)];
		bpSet = unique(bpSet,'rows');
end
end
%bpSet = [bpSet; eye(states)];
bpSet = unique(bpSet,'rows');

end

function localAction=randomLocalAction(ac)
	localAction=gendist(ones(1,ac)*(1/ac),1,1);
end