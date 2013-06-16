function [rewards,counter,belief_distance] = eval_policy(mdp,h,restarts,option1,option2)


%% Notes
% 'option1' decides how action is determined 
% 'option2' decides the type of belief update
% policy should be embedded in the mdp struct

%% check inputs
if nargin<5; option2=1; end;	%default belief update
if nargin<4; option1=3;	end;	%default action selection
if nargin<3; restarts=0;end;
if nargin<2; h=10;		end;

%% Load variables from mdp problem
ac=mdp.ac;				ag=mdp.ag;			ob=mdp.ob;
states=mdp.nrStates;	b0=getStart(mdp);	policy=mdp.global_policy;

%% Initialise variables
rewards=zeros(1,h);			total_rewards=zeros(restarts+1,h);
beliefs=zeros(ag,states);	counter=0;
uniform = ones(1,states)*(1/states);%uniform belief to go to if 
									%anything goes wrong..(NaNs n'such)
option1Labels = strvcat('mlspolicy','qmdppolicy','alphaVector','localAlphaVector','randomAction');
option2Labels = strvcat('localBelief + Policy','LocalBelief','LocalBelief + globalAction','LocalBelief + globalObservation','Global Belief','Global Knowledge');
disp(['Evaluating [' deblank(option2Labels(option2,:)) '] with [' deblank(option1Labels(option1,:)) ']'])
%belief_distance=zeros(restarts+1,h);

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
% 			if option1==4 %local alpha vectors
% 			beliefs(i,:) = getLocalUpdate(localObservations(i),...
% 				beliefs(i,:),localActions(i),global_action,o,mdp,policy,i,s,option2);
% 			else
			if option1==5 %random action
				%beliefs(i,:)=beliefs(i,:); %not even necessary
			else
			beliefs(i,:) = getLocalUpdate(localObservations(i),...
				beliefs(i,:),localActions(i),global_action,...
				o,mdp,policy,i,s,option2);
			end
		end
		realstate=zeros(1,states); state(s)=1;
		belief_distance(starts,step)=norm(beliefs(1,:)-beliefs(2,:),2);
		truth_distance1(starts,step)=norm(beliefs(1,:)-realstate,2);
		truth_distance2(starts,step)=norm(beliefs(2,:)-realstate,2);
		
	%	check for invalid beliefs(NaNs) (and keep a counter)
		for i=1:ag
			if any(isnan(beliefs(i,:))) %|| sum(beliefs(i,:))<1 || sum(beliefs(i,:))>1 || all(beliefs(i,:))==0
				beliefs(i,:)=uniform;
				disp('belief reset!!');
				%[sum(beliefs(i,:))<1,sum(beliefs(i,:))>1,all(beliefs(i,:))==0]
			end
		end
end %timesteps loop
total_rewards(starts,:)=rewards;
%for i=1:length(rewards); discount_reward = discounted_reward*discount+rewards(i); end;
end %restarts loop
clear counter
counter.td1=truth_distance1;
counter.td2=truth_distance2;

rewards=total_rewards;
end

function belief = getLocalUpdate(o_local,b,a_local,a_global,o_global,mdp,policy,agent,state,option)
if		option==1	% Local Belief + global Policy
	belief = belief_update_local_policy(o_local,b,a_local,mdp,agent);
elseif	option==2	% Local Belief
	belief = belief_update_local_action(o_local,b,a_local,mdp,agent);
elseif	option==3	% Global Action
	belief = belief_update_global_action(o_local,b,a_global,mdp,agent);
elseif option==4	% Global Observation
	belief = belief_update_global_observation(o_global,b,a_local,mdp,agent);
elseif	option==5	% Global Observation + Global Action
	belief = belief_update_global(o_global,b,a_global,mdp.P,mdp.O);
elseif  option==6	% Perfect Knowledge
	belief = zeros(1,length(b)); belief(state) = 1;
elseif	option==7
	belief = belief_update_local_policy_testalteration(o_local,b,a_local,mdp,agent);
else
	belief = ones(1,length(b))/length(b);	%uniform belief
end
end

function action = getLocalAction(mdp,belief,agent,option)
if		option == 1  %action based on most likely state
	action = mlsPolicy(belief,mdp.global_policy,mdp,agent);
elseif	option == 2 %action based on Qmdp
	action = qmdpPolicy(belief,mdp.global_policy_valuefunc,mdp,agent);
elseif	option == 3 %action based on alpha vectors
	global_action = getAction(belief,mdp.alphaV);
	action = singlact(global_action,mdp.ac,mdp.ag);
	action = action(agent);
elseif	option == 4
	action = getAction(belief,mdp.localAlphaV);
else		 %random action
	action = gendist(ones(1,mdp.ac)/mdp.ac,1,1);
end
end
