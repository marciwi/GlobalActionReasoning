function state=idState(mdp,cell,option)

if nargin<3; option=1;	end;

state=[];
for i=1:length(cell)
	if ischar(mdp.states)
		[foo,localstate]=max(strcmp(linediv(mdp.states),cell(i)));
		if foo==0
			state=[state cell2mat(cell(i))];
		else
			state=[state localstate];
		end
	else
		state = [state str2double(cell2mat(cell(i)))];
	end
end

if length(cell)>1
	state=globstate(state,mdp.nrStates,mdp.ag);
end

end