%% Function Description
%  MMSE detection
%% Input
%  DataSymOut :  2-Dimensional array (RxAntNum-DataRENum)
%                Data after demapping
%  HEst   ;      2-Dimensional array (TxAntNum*RxAntNum-DataRENum) 
%                channel estimation result of Data
%  SnrLinear :   double
%                linear SNR
%  RankNum    :  double
%                RANK
%% Output
%  MMSEOut    :  2-Dimensional array (Rank-DataRENum)
%                data after MMSE detection
%  MMSESinr   :  2-Dimensional array (Rank-DataRENum)
%                sinr of every DataRE
%% Modify History
% 2017/6/6 created by Bu Shuqing
% 2017/12/18 modified by Liu Chunhua
% 2018/5/22  modified by Song Erhao 

function [ MMSEOut, MMSESinr ] = nrMMSEDetectorMIMO( DataSymOut, HEst, SnrLinear, RankNum)
n_power=1/SnrLinear;                          % ��������
Len = size(DataSymOut,2);
Ir=eye(RankNum);

TotalAnt = size(HEst,1);
RxAntNum = TotalAnt/RankNum;
MMSEOut = zeros(RankNum,Len);                  % ������������
MMSESinr = zeros(RankNum,Len);                 % �������Ÿ����
    for I_s = 1 : Len
        H = HEst(:,I_s);     % NumRec* NumTra
        H = reshape(H,RankNum,RxAntNum);
        H = H.';
        
        MMSEMat=pinv(H'*H+n_power*Ir)*H';
        NorMat = zeros(RankNum,RankNum);
        for TraInd = 1:RankNum
            NorMat(TraInd,TraInd) = 1 / (MMSEMat(TraInd,:) * H(:,TraInd));    
        end            
        NorMMSEMat = NorMat * MMSEMat;            
        MMSEOut(:,I_s) = NorMMSEMat * DataSymOut(:,I_s); 
        % ���SINR
        temp_u = zeros(RankNum,RankNum);         %����
        temp_dl = zeros(RankNum,RankNum);        %����ĸ
        temp_dr = zeros(RankNum,RankNum);        %�Ҳ��ĸ
        for TraInd = 1:RankNum
           temp_u(TraInd)=(MMSEMat(TraInd,:)*H(:,TraInd)) * (MMSEMat(TraInd,:)*H(:,TraInd))';
           temp_dl(TraInd) = (MMSEMat(TraInd,:) * H) * (MMSEMat(TraInd,:) * H)'-temp_u(TraInd); 
           temp_dr(TraInd) = MMSEMat(TraInd,:)*MMSEMat(TraInd,:)'*n_power; 
           MMSESinr(TraInd ,I_s) = temp_u(TraInd)/(temp_dl(TraInd)+temp_dr(TraInd));                
        end        
    end
end

