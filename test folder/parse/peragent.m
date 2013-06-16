function out = peragent(var,ag)
%%used in mdp_parse
if nargin<2;	ag=1;	end;

sz =  size(var);
if isa(var,'char')
	out=var(1,:);
else
	if sz(1)>1
		out=var(1);
	else
		%out=log(var)/(log(ag));
		out=var^(1/ag);
		%out=nr;
	end
end
end