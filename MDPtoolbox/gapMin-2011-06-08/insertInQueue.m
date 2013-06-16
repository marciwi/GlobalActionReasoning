function [beliefQueue,gapQueue,probQueue,depthQueue,pathQueue] = insertInQueue(belief,gap,prob,depth,path,beliefQueue,gapQueue,probQueue,depthQueue,pathQueue)
%function [beliefQueue,gapQueue,probQueue,depthQueue,pathQueue] = insertInQueue(belief,gap,prob,depth,path,beliefQueue,gapQueue,probQueue,depthQueue,pathQueue)

if isempty(gapQueue) || gap < gapQueue(end)
  gapQueue = [gapQueue; gap];
  beliefQueue = [beliefQueue; belief];
  probQueue = [probQueue; prob];
  depthQueue = [depthQueue; depth];
  pathQueue = {pathQueue{:}, path};
  return;
end

id = findBelief(belief,beliefQueue);
if id > 0
  gap = gap + gapQueue(id);
  prob = prob + probQueue(id);
  depth = min(depth,depthQueue(id));
  path = pathQueue{id};
  gapQueue = gapQueue([1:id-1,id+1:end]);
  beliefQueue = beliefQueue([1:id-1,id+1:end],:);
  probQueue = probQueue([1:id-1,id+1:end]);
  depthQueue = depthQueue([1:id-1,id+1:end]);
  pathQueue = pathQueue([1:id-1,id+1:end]);
end

for i = length(gapQueue):-1:2
  if gapQueue(i-1) > gap && gap >= gapQueue(i)
    gapQueue = [gapQueue(1:i-1);gap;gapQueue(i:end)];
    beliefQueue = [beliefQueue(1:i-1,:);belief;beliefQueue(i:end,:)];
    probQueue = [probQueue(1:i-1);prob;probQueue(i:end)];
    depthQueue = [depthQueue(1:i-1);depth;depthQueue(i:end)];
    pathQueue = {pathQueue{1:i-1},path,pathQueue{i:end}};
    return;
  end
end

beliefQueue = [belief; beliefQueue];
gapQueue = [gap; gapQueue];
probQueue = [prob; probQueue];
depthQueue = [depth; depthQueue];
pathQueue = {path,pathQueue{:}};

