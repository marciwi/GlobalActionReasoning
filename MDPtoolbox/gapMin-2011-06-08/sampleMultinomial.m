% function id = sampleMultinomial(multinomial)
function id = sampleMultinomial(multinomial)

nonZeroIds = find(multinomial);

cumMultinomial = cumsum(multinomial(nonZeroIds)/sum(multinomial(nonZeroIds)));
prob = rand;
for nzId = 1:length(cumMultinomial)
  if cumMultinomial(nzId) >= prob
    break;
  end
end

%first = 0;
%last = length(cumMultinomial);
%while true
%  middle = ceil((first+last)/2);
%  if cumMultinomial(middle) >= prob
%    last = middle;
%  else
%    first = middle;  
%  end
%  if last - first <= 1
%    break;
%  end
%end

%if last ~= nzId
%  last
%  nzId
%  keyboard
%end

id = nonZeroIds(nzId);
