function action = idAction(mdp,cell,option)
%option decides local or global action number default==global
if nargin<3; option=1;	end;

if strcmp(cell2mat(cell),'*')
	action=':';
else
	action = [];
	for i=1:length(cell)
		[foo,localA]=max(strcmp(linediv(mdp.localActions),cell(i)));
		if foo==0
			action = [action str2double(cell2mat(cell(i)))];
		else
			action = [action localA];
		end
	end

	if option==1
		action=globact(action,mdp.nrStates,mdp.ag);
	end
end
end