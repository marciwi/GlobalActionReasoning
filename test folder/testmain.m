o=1;	a=3;
agent=1;
%%
compol=[];
comloc=[];
for i=1:length(bpSet)
	bestb=belief_update_local_policy_testalteration(o,bpSet(i,:),a,mdp,agent);
	loca=belief_update_local_action(o,bpSet(i,:),a,mdp,agent);
	pol=belief_update_local_policy(o,bpSet(i,:),a,mdp,agent);
	if all(~isnan(bestb))
		if all(~isnan(pol));	compol=[compol all(bestb==pol')];	end;
		if all(~isnan(loca));	comloc=[comloc all(bestb==loca')];	end;
	end
end

any(comloc)
any(compol)

all(comloc)
all(compol)

%% policy
bb=zeros(1,4);
for j=1:4
	bb(j)=pro(o,j,mdp,agent)*(b*(praa(a,j,mdp,agent)'.*squeeze(P(:,j,:))))';	
end
bb=bb/sum(bb)

%% anomaly
bp=zeros(1,4);
for j=1:4
	%bp(j)=sum(sum(squeeze(P(:,j,:))*pra(a,mdp,agent)*b'*pro(o,j,mdp,agent)));
	bp(j)=sum(sum(squeeze(P(:,j,:))*pra(a,mdp,agent)*b'*(proo(o,mdp,agent)*squeeze(O(:,j,:))')));
end
bp=bp/sum(bp)

%% display alpha vector graph for dectiger problem (discount 0.99)
v1=[644.1110 644.1110];		a1=1;
v2=[657.6699 587.6699];		a2=2;
v3=[587.6699 657.6699];		a3=3;

figure(1); hold on;
plot([0 1],v1);		plot([0 1],v2);		plot([0 1],v3);
%intersections represent the exact 'tipping point' in decision making

v1=[59.8174 59.8174];		a1=1;
v2=[73.8357 3.8357];		a2=9;
v3=[3.8357 73.8357];		a3=5;
figure(1); hold on;
plot([0 1],v1);		plot([0 1],v2);		plot([0 1],v3);
%% Accurate Q-value from value function
	PR = mdp_computePR(P,R); %converts a R(S,S',A) to R(S,A)
	%A = size(P,3);
Q=zeros(mdp.nrStates,mdp.nrActions);
	for a=1:actions
		Q(:,a) = PR(:,a) + discount*P(:,:,a)*V;
	end
	
Q2=zeros(mdp.nrStates,mdp.nrActions);
for a=1:actions
	Q2(:,a)=sum(P(:,:,a).*(R(:,:,a)+repmat(discount*V,1,mdp.nrStates)),2);
end