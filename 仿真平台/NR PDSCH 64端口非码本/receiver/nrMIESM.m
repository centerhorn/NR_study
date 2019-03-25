function [SINRout] = nrMIESM(SINRinin,CodeRate,Qm)
beta = 1;
SINRin = 10*log10(SINRinin/beta);

load MI2SinrTableFile
SINRindex = MI2SinrTable(1,:);
maxSINR = SINRindex(end);
minSINR = SINRindex(1);
stepSINR = SINRindex(2) - SINRindex(1);

SINRin(find(SINRin>maxSINR)) = maxSINR;
SINRin(find(SINRin<minSINR)) = minSINR;

% 获得每个SINR对应的查表index
index = floor((SINRin-minSINR)/stepSINR)+1;

% 获得互信息
switch Qm
    case 1
        MIvalue = MI2SinrTable(2,:);
    case 2
        MIvalue = MI2SinrTable(3,:);
    case 4
        MIvalue = MI2SinrTable(4,:);
    case 6
        MIvalue = MI2SinrTable(5,:);
    case 8
        MIvalue = MI2SinrTable(6,:);
end

N = length(SINRin);
MIALL = zeros(1,N);
for n = 1:N
    MIALL(n) = MIvalue(index(n));
end
meanMIALL = mean(MIALL);
SINRconverseind = min(find(MIvalue>=meanMIALL));
if isempty(SINRconverseind)
   SINRconverseind =  length(SINRindex);
end
SINRconverse = SINRindex(SINRconverseind);
SINRout = SINRconverse+10*log10(beta);

end