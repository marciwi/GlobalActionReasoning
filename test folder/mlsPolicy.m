function action = mlsPolicy(b,global_policy,mdp,option,V,agent)

% option variable is either 1 or 2 (default = 1)
% 2 will determine the local action on the Q-Value
% 1 will determine the local action on the global policy

%% Notes
%From koltunova Veronika thesis pg. 36
%Most likely state (MLS) policy determination
%where pi(b)=argmax_a{ sum_s[ b(s)Q(s,a) ] }
% - dependent on:	- mdp_computePR
%					- singlact

%% check inputs
if nargin<6;    agent=1;    end;
if nargin<5;	option=1;	end;	%can't use option 1 without V
if nargin<4;	option=2;	end;

%% Load values from mdp
P=mdp.P;	R=mdp.R;
ac=mdp.ac;	ag=mdp.ag;
discount=mdp.discount;

%% compute global and local actions
[foo, state]=max(b);
global_action = global_policy(state);

if option==2
	PR = mdp_computePR(P,R); %converts a R(S,S',A) to R(S,A)
	A = size(P,3);
	for a=1:A
		Q(:,a) = PR(:,a) + discount*P(:,:,a)*V;
	end
	[value global_action] = max(Q(state,:));
end

action = singlact(global_action,ac,ag);
action = action(agent);

end