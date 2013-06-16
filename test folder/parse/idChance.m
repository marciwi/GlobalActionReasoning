function chance=idChance(mdp,cell,action,which)

%%
if strcmp(action,':'); actionln=mdp.nrActions;	else actionln=1;	end;

%%
%type could be used to decide upon the chance matrix size

if		strcmp(which,'transition')
	chance =	zeros(mdp.nrStates,mdp.nrStates,actionln);
	identity =	eye(mdp.nrStates);
	unif =		repmat(1./(sum(ones(mdp.nrStates),2)),1,mdp.nrStates);
elseif	strcmp(which,'observation')
	chance =	zeros(actionln,mdp.nrStates,mdp.nrObservations);
	%identity =	eye()
	unif =	repmat(1./(sum(ones(mdp.nrStates,mdp.nrObservations),2)),1,mdp.nrObservations);
elseif	strcmp(which,'reward')
	% 'do nothing' would be the best here
	%chance=zeros(mdp.nrStates,mdp.nrStates,mdp.nrActions);
end

%%
if		strcmp(cell2mat(cell),'identity')
	for i=1:max(actionln,length(action))
		chance(:,:,i)=identity;
	end
elseif	strcmp(cell2mat(cell),'uniform')
	if	strcmp(which,'observation')
		for i=1:max(actionln,length(action))
			chance(i,:,:)=unif;
		end
	else
		for i=1:max(actionln,length(action))
			chance(:,:,i)=unif;
		end
	end
else
	chance=str2double(cell2mat(cell));
end


end