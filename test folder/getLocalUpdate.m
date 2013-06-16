function belief = getLocalUpdate(o,b,a,a_global,mdp,policy,agent,option)
if		option==1
	belief = belief_update_local_policy(o,b,a,mdp,agent);
elseif	option==2
	belief = belief_update_local_action(o,b,a,mdp,agent);
elseif	option==3
	belief = belief_update_local(o,b,a_global,mdp,agent);
elseif	option==4
	belief = belief_update_local_policy_testalteration(o,b,a,mdp,agent);
%elseif option==5
%	belief = informationContent(o,b,a,mdp,agent);
else
	belief = ones(1,length(b))/length(b);	%uniform belief
end
end