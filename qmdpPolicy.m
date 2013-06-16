function action = qmdpPolicy(b,V,mdp,agent)

%% Notes
%From 'a point based pomdp algorithm for robot planning' pg. 2
%where pi(b)=argmax_a{ sum_s[ b(s)Q(s,a) ] }
% - dependent on:	- mdp_computePR
%					- singlact
%% check arguments
if nargin<4;    agent=1;    end;

%% Load values from mdp
P=mdp.P;	R=mdp.R;
ac=mdp.ac;	ag=mdp.ag;
discount=mdp.discount;	actions=mdp.nrActions;	states=mdp.nrStates;

%% compute global and local actions
PR = mdp_computePR(P,R); %converts a R(S,S',A) to R(S,A)
Q=zeros(states,actions);

for a=1:actions
	Q(:,a) = PR(:,a) + discount*P(:,:,a)*V; %copied from mdp_eval_policy_optimality
end
[value global_action] = max(b*Q);

action = singlact(global_action,ac,ag);
action=action(agent);
end