% x:SINR，线性值
% Qm:调制阶数
% Im:互信息
function Im = MutualInfor(x,Qm)
Im = 0;
switch Qm
    case{1}
        K = 1;
        a = 1;
        c = sqrt(2);
    case{2}
        K = 1;
        a = 1;
        c = 2;        
    case{4}
        K = 3;
        a = [0.5 0.25 0.25];
        c = [0.8 2.17 0.965];
    case{6}
        K = 3;
        a = [1/3 1/3 1/3];
        c = [1.47 0.529 0.366];
    case{8}
        K = 3;
        a = [0.6 0.36 0.04];
        c = [0.24 0.96 2.76];        
end

for k = 1:K
    Im = Im + a(k)*Jfuction(c(k)*sqrt(x));
end

end

function out = Jfuction(in)
if in<=1.6363
    out = -0.04210661*in^3 + 0.209252*in^2 - 0.00640081*in;
elseif in<=7.9999
    out = 1 - exp(0.00181492*in^3 - 0.142675*in^2 - 0.0822054*in + 0.0549608);
else
    out = 1;
end

end