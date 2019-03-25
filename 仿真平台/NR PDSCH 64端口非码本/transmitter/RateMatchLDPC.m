%% 函数功能
% 对LDPC下行速率匹配
%% 输入参数
% DataIn：输入数据
% E：速率匹配后的长度
% RV：冗余版本
% Z：与LDPC编码有关;
% BGSign：基图选择
% Qm = 4：调制阶数16Qam
%% 输出参数
% DataOut:速率匹配后输出的数据流
function DataOut = RateMatchLDPC(DataIn,E,RV,Z,BGSign,Qm)
iLBRM = 0;%事实上对于下行LDPC，取值1
N = length(DataIn);
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
%% bit selection
DataTemp = DataIn(1:Ncb);
DataTemp1 = [DataTemp((k0+1):end),DataTemp(1:k0)];
DataTemp2 = repmat(DataTemp1(1:Ncb), 1, ceil(E/Ncb));
DataInter = DataTemp2(1:E);
%% bit 交织

% DataOut = zeros(1,E);
% for j = 1:E/Qm
%     for i = 1:Qm
%         DataOut(i+(j-1)*Qm) = DataInter((i-1)*E/Qm+j);
%     end
% end

DataReshape = reshape(DataInter,E/Qm,Qm);
DataReshapeT = DataReshape.';
DataOut = reshape(DataReshapeT,1,E);

end