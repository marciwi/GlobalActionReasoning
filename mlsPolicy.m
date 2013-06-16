function action = mlsPolicy(b,global_policy,mdp,agent)

%% Notes
%Most likely state (MLS) policy determination
%where pi(b)=argmax_a{ sum_s[ b(s)Q(s,a) ] }
%					- singlact

%% check inputs
if nargin<4;    agent=1;    end;

%% Load values from mdp
P=mdp.P;	R=mdp.R;
ac=mdp.ac;	ag=mdp.ag;
discount=mdp.discount;

%% compute global and local actions
[foo, state]=max(b);
global_action = global_policy(state);

% if option==2	
% 	PR = mdp_computePR(P,R); %converts a R(S,S',A) to R(S,A)
% 	A = size(P,3);
% 	for a=1:A
% 		Q(:,a) = PR(:,a) + discount*P(:,:,a)*V;
% 	end
% 	[value global_action] = max(Q(state,:));
% end

action = singlact(global_action,ac,ag);
action = action(agent);

end