%% ��������
% ��LDPC��������ƥ��
%% �������
% DataIn����������
% E������ƥ���ĳ���
% RV������汾
% Z����LDPC�����й�;
% BGSign����ͼѡ��
% Qm = 4�����ƽ���16Qam
%% �������
% DataOut:����ƥ��������������
function DataOut = RateMatchLDPC(DataIn,E,RV,Z,BGSign,Qm)
iLBRM = 0;%��ʵ�϶�������LDPC��ȡֵ1
N = length(DataIn);
%% ȷ��Nref,Ncb
rLBRM = 2/3;
if iLBRM==0
    Ncb = N;
else
    Ncb = min(N,Nref);
end
%% ȷ��k0
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
%% bit ��֯

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