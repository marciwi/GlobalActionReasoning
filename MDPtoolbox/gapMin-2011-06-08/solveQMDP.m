function qFn = solveQMDP(POMDP, maxIter)
% function qFn = solveQMDP(POMDP, maxIter)

if ~exist('maxIter','var')
  maxIter = 10000;
end

fprintf('\nComputing qMDP value function\n');
qFn = zeros(POMDP.nStat,POMDP.nAct);
valFn = zeros(POMDP.nStat,1);
bellmanErr = POMDP.tol;
for i = 1:maxIter
  prevValFn = valFn;
  for actId = 1:POMDP.nAct
    qFn(:,actId) = POMDP.Rew(:,actId) + POMDP.discount * POMDP.spTa{actId} * prevValFn;
  end
  valFn = max(qFn,[],2);
  bellmanErr = max(abs(valFn-prevValFn));
  %fprintf('Bellman Error: %f\n',bellmanErr);
  if bellmanErr <= POMDP.tol
    break;
  end
end
%qFn = prunePointwise(qFn,POMDP.tol);
fprintf('qMDP init value: %f\t # iterations: %i\n',max(POMDP.initBel * qFn),i);

