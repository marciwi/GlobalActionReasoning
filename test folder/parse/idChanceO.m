function chance=idChanceO(mdp,cell,action)

%type could be used to decide upon the chance matrix size

if strcmp(action,':'); actionln=mdp.nrActions;	else actionln=0;	end;

chance=zeros(mdp.nrActions,mdp.nrStates,mdp.nrObservations);
if		strcmp(cell2mat(cell),'identity')
	for i=1:max(actionln,length(action))
		chance(:,:,i)=eye(mdp.nrStates);
	end
elseif	strcmp(cell2mat(cell),'uniform')
	for i=1:max(actionln,length(action))
		chance(:,:,i)=repmat(1./(sum(ones(mdp.nrStates),2)),1,2);
	end
else
	chance=str2double(cell2mat(cell));
end

end