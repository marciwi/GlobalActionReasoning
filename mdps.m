%% Run all MDP stuffz
clear all;  close all;	clc;
%% Add necessary paths
	addpath('problems/')
	addpath('MDPtoolbox')
	addpath('pomdpSoftware-0.1/generic')

%% Initiate Basic Variables
h = 50;			% Horizon

restarts = 150;		% number of restarts

force=0;			% Force re-execution of everything
%force=2;
whichfile = 3;		% chooses which .dpomdp file to use

dpomdpfiles = strvcat(...
		'recycling.dpomdp',...
		'broadcastChannel.dpomdp',...
		'Grid3x3corners.dpomdp');
		
filename=deblank(dpomdpfiles(whichfile,:));

%% Build (Dec-)MDP problem 
if ~exist(['problems/' filename(1:end-7) '.mat'],'file') || force>0
	mdp_verbose();
	mdp			= mdp_parse(filename);
	mdp.filename= filename;			mdp_check(mdp.P,mdp.R);
else
	load(['problems/' filename(1:end-7) '.mat'])
end

mdp.R2		= mdp_computePR(mdp.P,mdp.R);	%reduced reward matrix
if mdp.discount==1
	mdp.discount= 0.9; %overwrite for problems with discount==1
end

known_results;		% Load known results from dec-pomdp page
if max(hPrevResults)>h;		h=max(hPrevResults);	end;

%% Solve underlying MDP
if force>1
	[mdp.global_policy, iter, cpu_time] = mdp_value_iteration(mdp.P,mdp.R,mdp.discount,1e-15);
	mdp.global_policy_valuefunc			= mdp_eval_policy_matrix(mdp.P,mdp.R,mdp.discount,mdp.global_policy);

	mdp.global_policy_Qfunc=zeros(mdp.nrStates,mdp.nrActions);
	for a=1:mdp.nrActions;	mdp.global_policy_Qfunc(:,a) = mdp.R2(:,a) + mdp.discount*mdp.P(:,:,a)*mdp.global_policy_valuefunc; end;
end

%% Build Belief point set
if ~isfield(mdp,'bpSet') || force>1
	bpSet = sampleBeliefPoints(restarts,mdp,h);
	mdp.bpSet=bpSet;
else
	bpSet = mdp.bpSet;
end

save(['problems/' mdp.filename(1:end-7)],'mdp')	%Save full problem to file

%% Solve underlying POMDP
if ~isfield(mdp,'alphaV') || force>0
	global mdp;			global problem;
	runvi(bpSet)
	global vi
		
	mdp.alphaV = vi.V;	%add optimized alpha to mdp
	mdp.POMDPh = h;
	mdp.restarts=restarts;
end

save(['problems/' mdp.filename(1:end-7)],'mdp')	%Save full problem to file

%% Evaluation
PolicyLabels = strvcat('mlspolicy','qmdppolicy',...
	'alphaVector','localAlphaVector','randomAction');
BeliefLabels = strvcat('LocalBelief + policy','LocalBelief',...
	'LocalBelief + globalAction','LocalBelief + globalObservation',...
	'Global Belief','Global Knowledge','LocalBelief Anomaly');
range=[1:3 5];	%which policy types
table = zeros(6,length(range));

%%
for option1=range
tic;	[rewards1,cnt1,bdist1] = eval_policy(mdp,h,restarts,option1,1);	t1=toc;	toc %Localbelief+policy
tic;	[rewards2,cnt2,bdist2] = eval_policy(mdp,h,restarts,option1,2);	t2=toc;	toc %LocalBelief
tic;	[rewards3,cnt3,bdist3] = eval_policy(mdp,h,restarts,option1,3);	t3=toc;	toc %Global Action Known
tic;	[rewards4,cnt4,bdist4] = eval_policy(mdp,h,restarts,option1,4);	t4=toc;	toc %Global observation Known
tic;	[rewards5,cnt5,bdist5] = eval_policy(mdp,h,restarts,option1,5);	t5=toc;	toc %Global observation and action Known
tic;	rewards6 = eval_policy(mdp,h,restarts,option1,6);	t6=toc;	toc %Global knowledge
%tic;	rewards6 = eval_global(mdp,h,restarts);				toc	%Global knowledge

label = PolicyLabels(option1,:);
savefile = ['evaluations\' date '_' strtrim(filename(1:end-7)) '_' strtrim(PolicyLabels(option1,:)) '_rewards'];
save(savefile,'rewards1','rewards2','rewards3','rewards4','rewards5','rewards6','t1','t2','t3','t4','t5','t6','h','bdist1','bdist2','bdist3','bdist4','bdist5','restarts','mdp','label')

%compute (average) discounted reward
discounted_reward=zeros(restarts+1,1);
	for m=1:6
		for n=1:h
			discounted_reward = mdp.discount*discounted_reward + eval(['rewards' num2str(m) '(:,n);']);
		end
	table(m,option1)=mean(discounted_reward);
	end
end

%% Create discounted Value file
if ~all(all(table==0))
	csvfilename = ['evaluations\' strtrim(filename(1:end-7)) '_Discounted_values_table' date '.csv'];
	fid=fopen(csvfilename,'w');
	for m=1:6
		fprintf(fid,[deblank(BeliefLabels(m,:)) sprintf(',%g',table(m,:)) '\n']);
	end
	fclose(fid);
end

%% Plots
known_results;		% Load known results from dec-pomdp page
dateused=date;		% change if you want to see older stored data

displayResults

%% Save workspace
save(['workspaces/' date])