%% Run all MDP stuffz
%clear all;  clc;
%% Initiate Basic Vars
h = 10;          % Horizon
restarts=9;     % number of restarts
%filename = 'recycling.dpomdp';
%filename = 'dectiger.dpomdp';
%filename='fireFighting_2_4_3.dpomdp';
load problems/ffg233		% fire fighting problem 2 3 3

%% Build (Dec-)MDP problem 
% mdp_verbose();
% mdp = mdp_parse(filename);
% mdp.filename=filename;		mdp_check(mdp.P,mdp.R);
% mdp.R2 = mdp_computePR(mdp.P,mdp.R);	%reduced reward matrix

%% Retrieve some values for quick tests
mdp.discount=0.9; %overwrite for other problems
discount = mdp.discount; 
P = mdp.P;		R = mdp.R;		O = mdp.O;
ac=mdp.ac;		ag=mdp.ag;		ob=mdp.ob;		st=mdp.st;

%% Solve MDP
[mdp.global_policy, iter, cpu_time] = mdp_value_iteration(mdp.P,mdp.R,mdp.discount);
%[mdp.global_policy_Qfunc, mdp.global_policy_valuefunc, mdp.global_policy, mean_discrepancy] = mdp_Q_learning(mdp.P,mdp.R,mdp.discount, 100000);
%[V, policy, iter, cpu_time] = mdp_policy_iteration(mdp.P,mdp.R,mdp.discount);
%[policy, average_reward, cpu_time] = mdp_relative_value_iteration(mdp.P,mdp.R);
[mdp.Ppolicy, PRpolicy] = mdp_computePpolicyPRpolicy(mdp.P,mdp.R,mdp.global_policy);
mdp.global_policy_valuefunc = mdp_eval_policy_matrix(P,R,discount,mdp.global_policy);

%% Make own pomdp solution
addpath('pomdpSoftware-0.1/problems/recycling')
addpath('pomdpSoftware-0.1/generic')
bpSet = sampleBeliefPoints(restarts,mdp,mdp.global_policy,h);
global mdp
global problem
%problem.gamma=0.9;
runvi(bpSet)
% works-ish but not fine yet
global backupStats
mdp.alphaV = backupStats.V{end};

save(['problems/' mdp.filename(1:end-7)],'mdp')

%% Evaluation
%option1 == action decision setting [1:5]
option1Labels = strvcat('mlspolicy1','mlspolicy2','qmdppolicy','alphaVector');
option2Labels = strvcat('localBelief + Policy','LocalBelief','LocalBelief + globalAction','localBelief Anomaly','uniform Belief');

for option1=3:4
%option2=1;		%belief update setting [1:4]
tic;	rewards =  eval_policy(mdp,h,restarts,option1,1);	toc	%Localbelief+policy
tic;	rewards2 = eval_policy(mdp,h,restarts,option1,2);	toc	%LocalBelief
tic;	rewards3 = eval_policy(mdp,h,restarts,option1,3);	toc	%Global Action Known
tic;	reward_global = eval_global(mdp,h,50);				toc	%Global knowledge

%test weird performance of beliefupdate
tic;	[rewardtst,cnt]= eval_policy(mdp,h,restarts,option1,4);		toc
label = option1Labels(option1,:);
savefile = ['evaluations\' strtrim(filename(1:end-7)) '_' strtrim(option1Labels(option1,:)) '_rewards_' date];
save(savefile,'rewards','rewards2','rewards3','reward_global','rewardtst','mdp','label')
end

%% Plots
% colors=['r' 'g' 'b' 'c' 'k' 'm' 'y'];
known_results;		% Load known results from dec-pomdp page

for option1=1:4
file = ['evaluations\' strtrim(filename(1:end-7)) '_' strtrim(option1Labels(option1,:)) '_rewards_' date];
load(file)
figure(option1); hold on;
title(option1Labels(option1,:));
xlabel('horizon');	ylabel('cumulative reward');
plot(hPrevResults,RPrevResults,'r')
plot(1:length(mean(cumsum(reward_global,2))),mean(cumsum(reward_global,2)),'k')
plot(1:length(rewards),mean(cumsum(rewards,2)),'b')
plot(1:length(rewards2),mean(cumsum(rewards2,2)),'g')
plot(1:length(rewards3),mean(cumsum(rewards3,2)),'m')
plot(1:length(rewardtst),mean(cumsum(rewardtst,2)),'y')
legend('optimal decentral','optimal global','policyBelief','localBelief','globalActionKnown','anomalyBelief')
end
%% anomaly stuff
% tic;	rew1=eval_policy(mdp,h,restarts,1,4);	toc
% tic;	rew2=eval_policy(mdp,h,restarts,2,4);	toc
% tic;	rew3=eval_policy(mdp,h,restarts,3,4);	toc
% figure; hold on;
% title('all anomaly')
% plot(recycl_hPrevResults,recycl_RPrevResults,'r')
% plot(1:length(reward_global),mean(cumsum(reward_global,2)),'k')
% plot(1:length(rew1),mean(cumsum(rew1,2)),'b')
% plot(1:length(rew2),mean(cumsum(rew2,2)),'c')
% plot(1:length(rew3),mean(cumsum(rew3,2)),'g')
% plot(1:length(rewardtst),mean(cumsum(rewardtst,2)),'y')


%% Save workspace
save(['workspaces/' date])