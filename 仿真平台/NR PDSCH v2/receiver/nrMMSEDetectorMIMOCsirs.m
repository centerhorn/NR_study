%% Function Description
%   MMSE detection according to CSIRS
%% Input
%   HEst:      2-Dimensional array (TxAntNum*RxAntNum-DataRENum) 
%              channel estimation result of Data
%   SnrLinear: double
%               linear snr
%   rank :     double
%              rank
%   PrecodingMatrix:  2-Dimension array(portNums-layerNums)
%                     codebook for precoding
%   pdschConfig:    structure
%                   Configuration information for pdsch
%% Output
%   MMSESinr:       2-Dimensional array (Rank-DataRENum)
%                   sinr of every DataRE
%% Modify history
% 2018/1/17 created by Liu Chunhua
% 2018/5/30 modified by Song Erhao

function  MMSESinr = nrMMSEDetectorMIMOCsirs( HEst, SnrLinear, rank,PrecodingMatrix,RxAntNum)
PORT_CSIRS = size(PrecodingMatrix,1);
n_power=1/SnrLinear;                          % 噪声方差
Len = size(HEst,2);
Ir=eye(rank);
MMSESinr = zeros(rank,Len);                 % 检测出的信干噪比
for I_s = 1 : Len
    H = HEst(:,I_s);     % NumRec* NumTra
    H = reshape(H,PORT_CSIRS,RxAntNum);
    H = H.'*PrecodingMatrix;

    MMSEMat=pinv(H'*H+n_power*Ir)*H';
    % 检测SINR
    temp_u = zeros(rank,rank);         %分子
    temp_dl = zeros(rank,rank);        %左侧分母
    temp_dr = zeros(rank,rank);        %右侧分母
    for TraInd = 1:rank
       temp_u(TraInd)=(MMSEMat(TraInd,:)*H(:,TraInd)) * (MMSEMat(TraInd,:)*H(:,TraInd))';
       temp_dl(TraInd) = (MMSEMat(TraInd,:) * H) * (MMSEMat(TraInd,:) * H)'-temp_u(TraInd); 
       temp_dr(TraInd) = MMSEMat(TraInd,:)*MMSEMat(TraInd,:)'*n_power; 
       MMSESinr(TraInd ,I_s) = temp_u(TraInd)/(temp_dl(TraInd)+temp_dr(TraInd));                
    end        
end
end

