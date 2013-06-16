function b=informationContent(o,b,a,mdp,agent)
%kullback-leibler divergence (information gain)

%% Load variables from mdp
states=mdp.states;

%% 
belief=b;
ba=belief_update_local_action(o,b,a,mdp,agent);
bb=belief_update_local_policy(o,b,a,mdp,agent);
bm=belief_update_local_policy_testalteration(o,b,a,mdp,agent);

%%
% dkl=zeros(1,6);
% num=1;
% for i=1:states
% 	gain=ba(i)*log(ba(i)/bb(i));
% 	if ~isnan(gain);	dkl(num)=dkl(num)+gain; end;
% end
% 
% num=2;
% for i=1:states
% 	gain=bb(i)*log(bb(i)/ba(i));
% 	if ~isnan(gain);	dkl(num)=dkl(num)+gain; end;
% end
% 
% num=3;
% for i=1:states
% 	gain=ba(i)*log(ba(i)/bm(i));
% 	if ~isnan(gain);	dkl(num)=dkl(num)+gain; end;
% end
% 
% num=4;
% for i=1:states
% 	gain=bm(i)*log(bm(i)/ba(i));
% 	if ~isnan(gain);	dkl(num)=dkl(num)+gain; end;
% end
% 
% [a b]=max(dkl);

%% 
dk=zeros(3,4);

dk(1,:)=-log(ba);
dk(2,:)=-log(bb);
dk(3,:)=-log(bm);

for i=1:3
ddk(i)=sum(dk(i,~isinf(dk(i,:))));
end
[a b]=min(ddk);
if		b==1
	b=ba;
elseif	b==2
	b=bb;
elseif	b==3
	b=bm;
else 
	b=belief;
	disp('no best belief')
end