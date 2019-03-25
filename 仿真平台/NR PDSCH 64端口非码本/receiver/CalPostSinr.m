
function SINR = CalPostSinr(H,SnrLinear)

n_power=1/SnrLinear;                          % ‘Î…˘∑Ω≤Ó
RankNum = size(H,2);
SINR = ones(RankNum,1);
HtempSquare = (abs(H)).^2;
HtempSum = sum(HtempSquare,1);
for RankInd = 1:RankNum
    temp_u = n_power*HtempSum(RankInd) + abs(det(H'*H));
    temp_d = n_power*(n_power+sum(HtempSum)-HtempSum(RankInd));
    SINR(RankInd) = temp_u/temp_d;
    
end


end