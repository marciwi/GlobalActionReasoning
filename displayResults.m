clear rewards1 rewards2 rewards3 rewards4 rewards5 rewards6
clear rewards1Discounted rewards2Discounted rewards3Discounted rewards4Discounted rewards5Discounted rewards6Discounted
clear rewards1Cumulative rewards2Cumulative rewards3Cumulative rewards4Cumulative rewards5Cumulative rewards6Cumulative
addpath('matlab2tikz/src')
addpath('for extra figures')

%% Average Cumulative Reward Graphs
sub=1;
for policytype=range
file = ['evaluations\' dateused '_' strtrim(mdp.filename(1:end-7)) '_' strtrim(PolicyLabels(policytype,:)) '_rewards'];
load(file)
figure(1);	subplot(2,2,sub);	hold on;
title([mdp.filename(1:end-7) ' ' PolicyLabels(policytype,:)]);
xlabel('horizon');	ylabel('cumulative reward');
plot(hPrevResults,RPrevResults,'r')
plot(1:length(mean(cumsum(rewards6,2))),mean(cumsum(rewards6,2)),'k')
plot(1:length(mean(rewards1)),mean(cumsum(rewards1,2)),'b')
plot(1:length(mean(rewards2)),mean(cumsum(rewards2,2)),'g')
plot(1:length(mean(rewards3)),mean(cumsum(rewards3,2)),'m')
plot(1:length(mean(rewards4)),mean(cumsum(rewards4,2)),'y')
plot(1:length(mean(rewards5)),mean(cumsum(rewards5,2)),'c')
sub=sub+1;
end
legend('optimal decentral','optimal global',...
	'policyBelief','localBelief','globalActionKnown',...
	'globalObservationKnown','global Belief','anomalyBelief')

legend('Location','NorthWest')
%axis([0 h 0 (max(max(rewards5))*1.05)])
matlab2tikz([mdp.filename(1:end-7) 'Rewards' dateused '.tex'],'showInfo', false);

[restarts,h]=size(rewards1); restarts=restarts-1;

%% Discounted Reward Build-up
sub=1;
for policytype=range
file = ['evaluations\' dateused '_' strtrim(mdp.filename(1:end-7)) '_' strtrim(PolicyLabels(policytype,:)) '_rewards'];
load(file)

%Calculate discounted rewards
for j=1:6	%for every belief type
	eval(['rewards' num2str(j) 'Discounted(:,1)=zeros(restarts+1,1);'])
	for i=1:h	%for every iteration
		eval(['rewards' num2str(j) 'Discounted(:,i+1) = rewards' num2str(j) '(:,i)+rewards' num2str(j) 'Discounted(:,i)*mdp.discount;']);
	end
end

figure(2);	subplot(2,2,sub);	hold on;
title([mdp.filename(1:end-7) ' ' PolicyLabels(policytype,:)]);
xlabel('time step');	ylabel('cumulative discounted reward');
plot(1:length(mean(rewards6Discounted)),mean(rewards6Discounted),'k')
plot(1:length(mean(rewards1Discounted)),mean(rewards1Discounted),'b')
plot(1:length(mean(rewards2Discounted)),mean(rewards2Discounted),'g')
plot(1:length(mean(rewards3Discounted)),mean(rewards3Discounted),'m')
plot(1:length(mean(rewards4Discounted)),mean(rewards4Discounted),'y')
plot(1:length(mean(rewards5Discounted)),mean(rewards5Discounted),'c')
sub=sub+1;
end
legend('Full Global Knowledge','policyBelief','localBelief',...
	'globalActionKnown','globalObservationKnown',...
	'global Belief')

legend('Location','NorthWest')
%axis([0 h 0 (max(max(rewards5))*1.05)])
matlab2tikz([mdp.filename(1:end-7) 'Discounted' dateused '.tex'],'showInfo', false);


%% Belief distance measurement
sub=1;
colors='kbgmyc';

for policytype=range
file = ['evaluations\' dateused '_' strtrim(mdp.filename(1:end-7)) '_' strtrim(PolicyLabels(policytype,:)) '_rewards'];
load(file)

figure(3); hold on;
for i=1:4
	xlabel('time step');	ylabel('belief distance between 2 agents');
	subplot(2,2,i); hold on;
	title([mdp.filename(1:end-7) ' ' BeliefLabels(i,:)]);
	plot(1:length(mean(bdist1)),mean(eval(['bdist' num2str(i)])),colors(policytype))
	%plot(1:length(mean(bdist1)),mean(mean(eval(['bdist' num2str(i)]))),[colors(policytype) '-.'])
end

sub=sub+1;
end
legend(PolicyLabels(range,:))

%% Bar Graph over Horizons
for policytype=range
file = ['evaluations\' dateused '_' strtrim(mdp.filename(1:end-7)) '_' strtrim(PolicyLabels(policytype,:)) '_rewards'];
load(file)

%Calculate Cumulate Rewards
for j=1:6		%for every belief type
	eval(['rewards' num2str(j) 'Cumulative(:,1)=zeros(restarts+1,1);'])
	for i=1:h	%for every iteration
		eval(['rewards' num2str(j) 'Cumulative(:,i+1) = rewards' num2str(j) '(:,i)+rewards' num2str(j) 'Cumulative(:,i);']);
	end
end

figure;	hold on;
title([mdp.filename(1:end-7) ' ' PolicyLabels(policytype,:)]);
xlabel('time step');	ylabel('cumulative reward');
bar(hPrevResults,[RPrevResults ;...
	mean(rewards1Cumulative(:,hPrevResults+1)) ;... %belief + policy
	mean(rewards2Cumulative(:,hPrevResults+1)) ;...	%belief local
	mean(rewards3Cumulative(:,hPrevResults+1)) ;... %belief+globalAction
	mean(rewards4Cumulative(:,hPrevResults+1)) ;...	%belief+globalObservation
	mean(rewards5Cumulative(:,hPrevResults+1)) ...% ;... %belief global
	%mean(rewards6Cumulative(:,hPrevResults+1)) ...	%knowledge global
	]',1,'group')

legend('optimal decentral',...
	'policyBelief','localBelief','globalActionKnown',...
	'globalObservationKnown','global Belief','Full Global Knowledge')
legend('Location','NorthWest')

axis([1.5 max(hPrevResults)+0.5 0 7])

%axis([1.5 15.5 0 55])		%recycling pt.1
%axis([19.5 40.5 0 150])	%recycling pt.2 
%axis([49.5 70.5 0 270])	%recycling pt.3

%axis([1.5 10.5 0 10])		%broadcast pt.1
%axis([14.5 30.5 0 30])		%broadcast pt.2

matlab2tikz([mdp.filename(1:end-7) 'Bar' strtrim(PolicyLabels(policytype,:)) dateused '.tex'],'showInfo', false);
end

%% Boxplot over finite horizon
% for policytype=range
% file = ['evaluations\' dateused '_' strtrim(mdp.filename(1:end-7)) '_' strtrim(PolicyLabels(policytype,:)) '_rewards'];
% load(file)
% 
% %Calculate Cumulate Rewards
% for j=1:6	%for every belief type
% 	eval(['rewards' num2str(j) 'Cumulative(:,1)=zeros(restarts+1,1);'])
% 	for i=1:h	%for every iteration
% 		eval(['rewards' num2str(j) 'Cumulative(:,i+1) = rewards' num2str(j) '(:,i)+rewards' num2str(j) 'Cumulative(:,i);']);
% 	end
% end
% 
% for j=1:6
% 	figure;
% 	eval(['boxplot(rewards' num2str(j) 'Cumulative(:,hPrevResults+1));']);
% 	title([mdp.filename(1:end-7) ' ' PolicyLabels(policytype,:) ' ' BeliefLabels(j,:)]);
% 	xlabel('iteration');	ylabel('cumulative reward');
% end
% 
% end

%% reCreate discounted Value file
table = zeros(6,length(range));
discounted_reward=zeros(restarts+1,1);
for policytype=range
	file = ['evaluations\' dateused '_' strtrim(mdp.filename(1:end-7)) '_' strtrim(PolicyLabels(policytype,:)) '_rewards'];
	load(file)
	for m=1:6
		for n=1:h
			discounted_reward = mdp.discount*discounted_reward + eval(['rewards' num2str(m) '(:,n);']);
		end
		table(m,policytype)=mean(discounted_reward);
	end
end

csvfilename1 = ['evaluations\RE-' strtrim(filename(1:end-7)) '_Discounted_values_table' dateused '.csv'];
fid=fopen(csvfilename1,'w');
for m=1:6
	fprintf(fid,[deblank(BeliefLabels(m,:)) sprintf(',%g',table(m,:)) '\n']);
end
fclose(fid);

%% Average Rewards gained at specific horizons per policy type
for policytype=range
	file = ['evaluations\' dateused '_' strtrim(mdp.filename(1:end-7)) '_' strtrim(PolicyLabels(policytype,:)) '_rewards'];
	load(file)
	csvfilename2=[file(1:end-7) 'average_per_horizon.csv'];
	fid=fopen(csvfilename2,'w');
	fprintf(fid,['horizon,optimal decentral,belief + policy,belief local,belief + global action,belief + global observation,global belief,full global knowledge\n']);
		for n=hPrevResults
			fprintf(fid,[num2str(n) ',' num2str(RPrevResults(find(n==hPrevResults))) ',' num2str(mean(sum(rewards1(:,1:n),2))) ',' num2str(mean(sum(rewards2(:,1:h),2))) ',' num2str(mean(sum(rewards3(:,1:h),2))) ',' num2str(mean(sum(rewards4(:,1:h),2))) ',' num2str(mean(sum(rewards5(:,1:h),2))) ',' num2str(mean(sum(rewards6(:,1:n),2))) '\n']);
		end
	fclose(fid);
end

%% The beliefupdate time for each belief-action decision combi
colors='kbgmyc';
dates=strvcat('02-May-2013','03-May-2013',' ',' ',' ',' ',' ','14-May-2013');
for problem=[1 2 8]
	name=strtrim(dpomdpfiles(problem,:));
	for policytype=range
		file=['evaluations\' dates(problem,:) '_' name(1:end-7) '_' strtrim(PolicyLabels(policytype,:)) '_rewards'];
		load(file)
		%figure; hold on;
		for i=1:6 %belief type
			eval(['t' num2str(problem) ...
				num2str(policytype) ...
				num2str(i) 'avg = t' num2str(i) '/(h*restarts);'])
			
		%	eval(['plot(i,t' num2str(problem) ...
		%		num2str(policytype) ...
		%		num2str(i) 'avg,''o'')'])
		end
		%xlabel('belief type')
		%ylabel('average time to update belief')
		%title([name(1:end-7) ' ' num2str(policytype)])
	end
end

range=[1 2 3];
tavg = zeros(3,6);
for problem=[1 2 8]
	for i=1:6
		for policytype=range
			eval(['tavg(find([1 2 8]==problem),i) = ' ...
				'tavg(find([1 2 8]==problem),i) + '...
				't' num2str(problem) ...
				num2str(policytype) ...
				num2str(i) 'avg/max(range);'])
		end
	end
end

for problem=[1 2 8]
	figure
	plot(tavg(find([1 2 8]==problem),:),'s-')
	title(strtrim(dpomdpfiles(problem,:)))
	xlabel('belief type')
	ylabel('average time for update')
end