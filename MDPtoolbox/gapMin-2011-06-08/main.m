function main(problemName,maxTime,upperBoundString)
% function main(problemName,maxTime,upperBoundString)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Arguments:
%   problemName: name of a POMDP problem
%   maxTime: maximum amount of time after which the program is stopped (default: infinity)
%   upperBoundString: type of upper bound {'LP','sawtooth'} (default: 'LP')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Pascal Poupart (copyright 2011)
% 
% While this code is made publicly available, all work that uses this code, extends this code or makes a comparison to this code is required to cite the following paper which describes the GapMin algorithm:
% 
% Pascal Poupart, Kee-Eung Kima and Dongho Kim, 
% Closing the Gap: Improved Bounds on Optimal POMDP Solutions,
% International Conference on Automated Planning and Scheduling (ICAPS), Freiburg, Germany, 2011.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear global;
global SAWTOOTH LP upperBoundType sawtoothMaxIter
SAWTOOTH = 0;
LP = 1;

if exist('maxTime','var') & ~isempty(maxTime)
  maxTimeString = sprintf('-time%i',maxTime);
else
  maxTimeString = [];
end

if exist('upperBoundString','var') & ~isempty(upperBoundString)
  if strcmp(upperBoundString,'sawtooth')
    upperBoundType = SAWTOOTH;
  elseif strcmp(upperBoundString,'LP')
    upperBoundType = LP;
  else
    error('invalid argument: upperBoundString = %s',upperBoundString);
  end
else % default
  upperBoundType = LP; 
end

if exist('sawtoothMaxIterArg','var') & ~isempty(sawtoothMaxIterArg)
  sawtoothMaxIter = sawtoothMaxIterArg;
else
  sawtoothMaxIter = 1;
end
sawtoothMaxIterString = sprintf('%i',sawtoothMaxIter);

fprintf('loading problems/%s.POMDP\n',problemName);
if ~exist(['problems/',problemName,'.mat'],'file')
  pomdp = readPOMDP_SPAAN(['problems/',problemName,'.POMDP']);
  POMDP = spaan2pascal(pomdp)
  save(['problems/',problemName,'.mat'],'POMDP');
else
  load(['problems/',problemName,'.mat']);
  POMDP = POMDP
end 

if ~exist('extPts','var') | isempty(extPts)
  extPts = true;  
end
if extPts
  extPtsString = [];
  startIndex = 1;
else
  extPtsString = '-noExtPts';
  startIndex = POMDP.nStat+1;
end

if ~exist('tightLB','var') | isempty(tightLB)
  tightLB = false;
end
if tightLB
  tightLBstring = '-tightLB';
else
  tightLBstring = [];
end

startTime = cputime;
t1 = tic;

valFn.lb.alphaVectors = pureStrategies(POMDP);
valFn.lb.beliefSet = [POMDP.initBel];

valFn.ub.alphaVectors = solveFIB(POMDP);
valFn.ub.beliefSet = [POMDP.initBel];
%valFn.ub.beliefSet = [valFn.lb.beliefSet; eye(POMDP.nStat)];
valFn.ub.values = max(valFn.ub.beliefSet * valFn.ub.alphaVectors,[],2);
alphaVectors = [valFn.ub.alphaVectors; valFn.ub.beliefSet * valFn.ub.alphaVectors];


ubNewBeliefs = [];
lbNewBeliefs = [];

lbInitVal(1) = lowerBound(POMDP.initBel, valFn.lb.alphaVectors);
sizeLbBeliefSet(1) = size(valFn.lb.beliefSet,1);
ubInitVal(1) = upperBound(POMDP.initBel,valFn.ub.beliefSet,valFn.ub.values,valFn.ub.alphaVectors);
sizeUbBeliefSet(1) = size(valFn.ub.beliefSet,1);
cpuTime(1) = cputime - startTime;
elapsedTime(1) = toc(t1);
if upperBoundType == LP
  save(['results/',problemName,maxTimeString,'-LP',extPtsString,tightLBstring,'.mat'],'ubInitVal','lbInitVal','cpuTime','elapsedTime','sizeLbBeliefSet','sizeUbBeliefSet');
else
  save(['results/',problemName,maxTimeString,'-sawtooth',sawtoothMaxIterString,extPtsString,tightLBstring,'.mat'],'ubInitVal','lbInitVal','cpuTime','elapsedTime','sizeLbBeliefSet','sizeUbBeliefSet');
end
%fprintf('Gap = %f\n',ubInitVal(1) - lbInitVal(1));
fprintf('\niter\tgap      \tlb      \tub      \tsizeLb\tsizeUb\tcpuTime(s)\telapsedTime(s)\n');
fprintf('%i\t%f\t%f\t%f\t%i\t%i\t%i\t%i\n',1,ubInitVal(1)-lbInitVal(1),lbInitVal(1),ubInitVal(1),sizeLbBeliefSet(1),sizeUbBeliefSet(1),cpuTime(1),elapsedTime(1));


i = 1;
% stop when relative gap is less than 3 significant digits
%if ubInitVal(i) - lbInitVal(i) < POMDP.tol * 2 / (1-POMDP.discount)
while ubInitVal(i) - lbInitVal(i) > 1e-8 && ubInitVal(i) - lbInitVal(i) >= 10^(ceil(log10(max(abs(ubInitVal(i)),abs(lbInitVal(i)))))-3)
  i = i + 1;

  % adjust tolerance to 3 significant digits 
  ubInit = upperBound(POMDP.initBel,valFn.ub.beliefSet,valFn.ub.values,valFn.ub.alphaVectors);
  POMDP.tol = 10^(ceil(log10(max(abs(ubInitVal(end)),abs(lbInitVal(end)))))-3)*(1-POMDP.discount)/2;
  %POMDP.tol = 1e-8;

  % find new belief points
  [lbNewBeliefs,ubNewBeliefs,newVals] = selectReachableBeliefs(POMDP,valFn.ub,valFn.lb,max(20,0.2*(size(valFn.ub.beliefSet,1)+size(valFn.lb.beliefSet,1))),extPts,tightLB);
  %[lbNewBeliefs,ubNewBeliefs,newVals] = beliefRollout(POMDP,valFn.ub,valFn.lb,20);
  valFn.lb.beliefSet = [valFn.lb.beliefSet; lbNewBeliefs];
  valFn.ub.beliefSet = [valFn.ub.beliefSet; ubNewBeliefs];
  valFn.ub.values = [valFn.ub.values; newVals];
  %if exist('alphaVectors','var') & ~isempty(usefulUbBeliefIds)
  %  size(usefulUbBeliefIds)
  %  alphaVectors = alphaVectors([1:POMDP.nStat,POMDP.nStat+usefulUbBeliefIds],:);
  %end

  % update lower bound with pbvi
  [valFn.lb.alphaVectors,uselessBeliefs] = pbvi(POMDP, valFn.lb);
  usefulBeliefs = setdiff(1:size(valFn.lb.beliefSet,1),uselessBeliefs);
  valFn.lb.beliefSet = valFn.lb.beliefSet(usefulBeliefs,:);
  lbInitVal(i) = lowerBound(POMDP.initBel, valFn.lb.alphaVectors);
  sizeLbBeliefSet(i) = size(valFn.lb.beliefSet,1);
  %sizeLbAlphaVectors = size(valFn.lb.alphaVectors,2)

  % update upper bound with FIB
  %if exist('FIB_POMDP','var')
  %  FIB_POMDP = constructPOMDP(POMDP,valFn.ub,extPts,FIB_POMDP);
  %else
    FIB_POMDP = constructPOMDP(POMDP,valFn.ub,extPts);
  %end
  if exist('alphaVectors','var') && exist('newVals','var') 
    if size(newVals,1) > 0
      alphaVectors = solveFIB(FIB_POMDP,[alphaVectors;newVals*ones(1,size(alphaVectors,2))],startIndex);
    else
      alphaVectors = solveFIB(FIB_POMDP,alphaVectors,startIndex);
    end
  else
    alphaVectors = solveFIB(FIB_POMDP,[],startIndex);
  end
  valFn.ub.alphaVectors = alphaVectors(1:POMDP.nStat,:);
  valFn.ub.values = max(alphaVectors(POMDP.nStat+1:end,:),[],2);


  % clean up upper bound 
  [valFn.ub,FIB_POMDP.reachableBeliefs,alphaVectors] = cleanupUB(valFn.ub,POMDP.tol/2,FIB_POMDP.reachableBeliefs,alphaVectors);

  % save statistics
  ubInitVal(i) = upperBound(POMDP.initBel,valFn.ub.beliefSet,valFn.ub.values,valFn.ub.alphaVectors);
  sizeUbBeliefSet(i) = size(valFn.ub.beliefSet,1);
  cpuTime(i) = cputime - startTime;
  elapsedTime(i) = toc(t1);
  if upperBoundType == LP
    save(['results/',problemName,maxTimeString,'-LP',extPtsString,tightLBstring,'.mat'],'ubInitVal','lbInitVal','cpuTime','elapsedTime','sizeLbBeliefSet','sizeUbBeliefSet');
  else
    save(['results/',problemName,maxTimeString,'-sawtooth',sawtoothMaxIterString,extPtsString,tightLBstring,'.mat'],'ubInitVal','lbInitVal','cpuTime','elapsedTime','sizeLbBeliefSet','sizeUbBeliefSet');
  end

  %fprintf('Gap = %f\n',ubInitVal(i) - lbInitVal(i));
  fprintf('%i\t%f\t%f\t%f\t%i\t%i\t%i\t%i\n',i,ubInitVal(i)-lbInitVal(i),lbInitVal(i),ubInitVal(i),sizeLbBeliefSet(i),sizeUbBeliefSet(i),cpuTime(i),elapsedTime(i));


  % stop when time is up
  if exist('maxTime','var') & elapsedTime(end) > maxTime
    break;
  end

  % stop when no new beliefs added
  if size(lbNewBeliefs,1) == 0 & size(ubNewBeliefs,1) == 0 & length(lbInitVal) > 1 & (ubInitVal(end-1) - lbInitVal(end-1)) - (ubInitVal(end) - lbInitVal(end)) < POMDP.tol * 5
    break;
  end
end

if upperBoundType == LP
  fprintf(['\nDone: statistics saved in results/',problemName,maxTimeString,'-LP',extPtsString,tightLBstring,'.mat\n']);
else
  fprintf(['\nDone: statistics saved in results/',problemName,maxTimeString,'-sawtooth',sawtoothMaxIterString,extPtsString,tightLBstring,'.mat\n']);
end
