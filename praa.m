function pr=praa(mdp,a_local,belief,agent)

%% Check inputs
if nargin<4;	agent=1;		end;
if nargin<3;	belief=[];		end;

%P(A|a_local,s',s)
%% load mdp.variables
ac=mdp.ac;	ag=mdp.ag;
P=mdp.P;	states=mdp.nrStates;	actions=mdp.nrActions;
policy=mdp.global_policy;		Q=mdp.global_policy_Qfunc;

%% probabilities
% calculate P(A|a)
	paa=(singlact(1:actions,ac,ag,agent)==a_local);
	paa=paa/sum(paa);
	
if ~isempty(belief)
	pAs=belief*Q*(1/sum(belief*Q));
	
% combine
	pr=(pAs.*paa)*(1/sum(pAs.*paa));
else
	pr=paa;
end



end