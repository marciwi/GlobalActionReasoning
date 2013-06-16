function line = nxtline(file)
%%used in mdp_parse
i=0;
while(i==0)
    line = fgetl(file);
    if line(1)~='#'; i=1; end;
end
end