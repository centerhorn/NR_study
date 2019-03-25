%% 函数功能
% 对LDPC下行解速率匹配
%% 输入参数
% DataIn：输入数据
% N：解速率匹配后的长度
% RV：冗余版本
% Z：与LDPC编码有关;
% BGSign：基图选择
% Qm = 2：调制阶数
%% 输出参数
% DataOut：解速率匹配后的数据
function DataOut = DeRateMatchLDPC(DataIn,N,RV,Z,BGSign,Qm)
iLBRM = 0;%事实上对于下行LDPC，取值1
E = length(DataIn);
%% 确定Nref,Ncb
rLBRM = 2/3;
if iLBRM==0
    Ncb = N;
else
    Ncb = min(N,Nref);
end
%% 确定k0
if BGSign ==1
    k0Total = [0, floor(17*Ncb/66/Z)*Z, floor(33*Ncb/66/Z)*Z, floor(56*Ncb/66/Z)*Z];
elseif BGSign==2
    k0Total = [0, floor(13*Ncb/50/Z)*Z, floor(25*Ncb/50/Z)*Z, floor(43*Ncb/50/Z)*Z];
end
k0 = k0Total(RV+1);
%% bit解交织
DataTemp = reshape(DataIn,Qm,E/Qm);
DataTemp1 = DataTemp.';
DataTemp2 = reshape(DataTemp1,1,E);
%% bit selection
DataTe = [DataTemp2,zeros(1,(ceil(E/Ncb)*Ncb-E))];
DataTe2 = reshape(DataTe,Ncb,ceil(E/Ncb));
DataTe3 = DataTe2.';
DataTe4 = sum(DataTe3,1);
DataTe5 = [DataTe4(Ncb-k0+1:end),DataTe4(1:Ncb-k0)];
DataOut = [DataTe5,zeros(1,N-Ncb)];
end
%% bit interleaving