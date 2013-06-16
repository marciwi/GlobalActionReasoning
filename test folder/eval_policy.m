function [rewards,counter] = eval_policy(mdp,h,restarts,option1,option2)


%% Notes
% 'option' will determine how action is determined and/or beliuef update
% policy should be embedded in the mdp struct

%% check inputs
if nargin<5; option2=1; end;	%default belief update
if nargin<4; option1=3;	end;	%default action selection
if nargin<3; restarts=0;end;
if nargin<2; h=4;		end;

%% Load variables from mdp problem
ac=mdp.ac;				ag=mdp.ag;			ob=mdp.ob;
states=mdp.nrStates;	b0=getStart(mdp);	policy=mdp.global_policy;

%% Initialise variables
rewards=zeros(1,h);			total_rewards=zeros(restarts+1,h);
beliefs=zeros(ag,states);	counter=0;
uniform = ones(1,states)*(1/states);%uniform belief to go to if 
									%anything goes wrong..(NaNs n'such)
option1Labels = strvcat('mlspolicy1','mlspolicy2','qmdppolicy','alphaVector Policy');
option2Labels = strvcat('localBelief + Policy','LocalBelief','LocalBelief + globalAction','localBelief Anomaly','uniform Belief');
disp(['Evaluating [' deblank(option2Labels(option2,:)) '] with [' deblank(option1Labels(option1,:)) ']'])

%% Loop through decisions
for starts=1:(restarts+1)
	s = gendist(b0,1,1);					%(re)set initial state
	for i=1:ag;	beliefs(i,:)=b0;	end;	%(re)set initial beliefs
for step=1:h
	% determine action(s)
		for i=1:ag
			localActions(i)=getLocalAction(mdp,beliefs(i,:),i,option1);
		end
	% couple actions
		global_action = globact(localActions,ac,ag);
	% state transition
		[s,o,r] = getTransition(s,global_action,mdp);
	% add reward
		rewards(step) = r;
	% split observations
		localObservations =	singlobs(o,ob,ag);
	% belief update
		for i=1:ag
			beliefs(i,:) = getLocalUpdate(localObservations(i),...
				beliefs(i,:),localActions(i),global_action,mdp,policy,i,option2);
		end
	% check for invalid beliefs(NaNs) (and keep a counter)
		for i=1:ag
			if any(isnan(beliefs(i,:)))
				beliefs(i,:)=uniform;
				counter=counter+1;
			end
		end	
end %timesteps loop
total_rewards(starts,:)=rewards;
end %restarts loop
rewards=total_rewards;
end