function qFn = solveFIB(POMDP, initQfn, startIndex, maxIter)
% function qFn = solveFIB(POMDP, initQfn, startIndex, maxIter)

%fprintf('\nComputing FIB value function\n');

if ~exist('maxIter','var')
  maxIter = 100000;
end

if exist('initQfn','var')
  qFn = initQfn;
else
  qFn = ones(POMDP.nStat,POMDP.nAct)*max(max(POMDP.Rew))/(1-POMDP.discount);
end

if ~exist('startIndex','var') | isempty(startIndex)
  startIndex = 1;
end

%if exist('intStartIndex', 'var')
  for i = 1:maxIter
    prevQFn = qFn;
    for actId = 1:POMDP.nAct
      qFn(startIndex:end,actId) = POMDP.Rew(:,actId);
      for obsId = 1:POMDP.nObs
        qFn(startIndex:end,actId) = qFn(startIndex:end,actId) + POMDP.discount*max(POMDP.spTao{obsId,actId} * prevQFn,[],2);
      end
    end
    qFn = min(qFn,prevQFn);
    bellmanErr = max(max(abs(prevQFn-qFn)));
    %fprintf('Bellman Error: %f\n',bellmanErr);
    if bellmanErr <= POMDP.tol
      break;
    end
  end
%else
%  for i = 1:maxIter
%    prevQFn = qFn;
%    for actId = 1:POMDP.nAct
%      qFn(:,actId) = POMDP.Rew(:,actId);
%      for obsId = 1:POMDP.nObs
%        qFn(:,actId) = qFn(:,actId) + POMDP.discount*max(POMDP.spTao{obsId,actId} * prevQFn,[],2);
%      end
%    end
%    qFn = min(qFn,prevQFn);
%    bellmanErr = max(max(abs(prevQFn-qFn)));
%    %fprintf('Bellman Error: %f\n',bellmanErr);
%    %fprintf('POMDP.tol: %f\n',POMDP.tol);
%    if bellmanErr <= POMDP.tol
%      break;
%    end
%  end
%end
%fprintf('FIB init value: %f \t in %i steps\n',max(POMDP.initBel * qFn),i);

