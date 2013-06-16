function action = getLocalAction(mdp,belief,agent,option)
if		option == 1 || option == 2 %action based on most likely state
	action = mlsPolicy(belief,mdp.global_policy,...
					mdp,option,mdp.global_policy_valuefunc,agent);
elseif	option == 3 %action based on Qmdp
	action = qmdpPolicy(belief,mdp.global_policy_valuefunc,mdp,agent);
elseif	option == 4 %action based on alpha vectors
	global_action = getAction(belief,mdp.alphaV);
	action = singlact(global_action,mdp.ac,mdp.ag);
	action = action(agent);
%elseif	option == 5
%	action = [];
else		 %random action
	action = gendist(ones(1,mdp.ac)/mdp.ac,1,1);
end
end