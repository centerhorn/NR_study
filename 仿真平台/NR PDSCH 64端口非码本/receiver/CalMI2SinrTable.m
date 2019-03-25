clc;clear;
MI2SinrTable = -20:0.5:27;
Modulation = [1,2,4,6,8];
for i = 1:length(Modulation)
    Qm = Modulation(i);
    m = 1;
    for x1 = -20:0.5:27        
        x = 10^(x1/10);
        Im(m) = MutualInfor(x,Qm);
        m  = m+1;
    end
    MI2SinrTable = [MI2SinrTable;Im];
end