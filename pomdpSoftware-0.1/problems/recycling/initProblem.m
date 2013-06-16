function initProblem


clear global problem
global problem
global mdp

%% start basic stuff
problem				=	mdp;
problem.useSparse	=	0;		% Use sparse matrix computation.
problem.useSparseObs=	0;		% Use a full observation model.
problem.useReward3	=	1;

if isfield(mdp,'P');	problem.transition=permute(mdp.P,[2,1,3]);	problem=rmfield(problem,'P');	end;
if isfield(mdp,'R');	problem.reward3=mdp.R;		problem=rmfield(problem,'R');	end;
if isfield(mdp,'R2');	problem.reward=mdp.R2;		problem=rmfield(problem,'R2');	problem.useReward3=0;	end;

% other arrangement is used for runvi.m
if isfield(mdp,'O');	problem.observation=permute(mdp.O,[2,1,3]);		problem=rmfield(problem,'O');	end; %columns are differently defined...


if isfield(mdp,'discount');
						problem.gamma=mdp.discount;	problem=rmfield(problem,'discount'); end;
if isfield(mdp,'start');problem.startCum=cumsum(getStart(mdp)); end;
if isfield(mdp,'O');	problem.observationCum=cumsum(problem.observation,3); end;
if isfield(mdp,'P');	problem.transitionCum=cumsum(problem.transition);	end;

if isfield(problem,'reward'); problem.rewards=unique(problem.reward);
else		problem.rewards=unique(problem.reward3);	end;

%problem.description='MultiAgent Recycling Robots';

% String used for creating filenames etc.
problem.unixName=mdp.filename(1:end-7);

problem.baseDir=getDataDir;
problem.baseFilename=sprintf('%s/%s',problem.baseDir,problem.unixName);

end