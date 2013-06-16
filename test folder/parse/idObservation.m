function idObservation(mdp,cell,option)
%option decides local or global observation number default==global
if nargin<3; option=1;	end;

if strcmp(cell2mat(cell),'*')
	observation=':';
else
	observation = [];
	for i=1:length(cell)
		[foo,localO]=max(strcmp(linediv(mdp.localObservations),cell(i)));
		if foo==0
			observation = [observation str2double(cell2mat(cell(i)))];
		else
			observation = [observation localO];
		end
	end

	if option==1
		observation =globact(observation,mdp.nrStates,mdp.ag);
	end
end

end