function res = sizes(var)
%%used in mdp_parse
sz =  size(var);
res=1;
for i=1:sz(1)
	if isa(var(i,:),'char')
		split=size(linediv(var(1,:))); 
	else
		split=var;
	end
	if split(1)~=0; res=res*split(1); end;
end
end