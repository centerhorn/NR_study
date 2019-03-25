%% Function Description
%  Generate CDL-C-CAICT channel
%% Input
%  BlockInd : double
%             Index of slot
%  channel :  structure
%             configuration information for channel
%   coefficientH:        4-dimensional array (UE_ANT_NUM-NB_ANT_NUM-ClusterNum-Subpath
%                        channel coefficient
%   coefficientT:        4-dimensional array (UE_ANT_NUM-NB_ANT_NUM-ClusterNum-Subpath
%                        channel coefficient
%% Output
%   H:        4-dimensional array (UE_ANT_NUM-NB_ANT_NUM-MUL_PATH-(number of samples per slot + Max_Delay)).
%             channel matrix
%% Modify history
% 2018/5/24 created by Song Erhao
function [H] = GenerateCDL_C_CAICT(BlockInd,channel,coefficientH,coefficientT)

% parameter
MAX_DELAY = channel.MaxDelay ;
period = channel.SlotDuration;
Ts=period/channel.T;
UEAntennaTotalNumber = channel.UEAntNum;
BSAntennaTotalNumber = channel.NBAntNum;
ClusterNum = channel.MulPath;

t=BlockInd*period:Ts:((BlockInd+1)*period-Ts+MAX_DELAY*Ts);   %采样时间向量         %实际采样间隔为Ts
P_num = size(t,2);

 H = zeros(UEAntennaTotalNumber,BSAntennaTotalNumber,ClusterNum,P_num);
% channel generate
% for u = 1 : UEAntennaTotalNumber
%     for s = 1 : BSAntennaTotalNumber
%         for iCluster =  1 : ClusterNum
%             tmp = zeros(20,P_num);
%             for isubpath = 1 : 20
%                   tmp(isubpath,:) = coefficientH(u,s,iCluster,isubpath)*exp(coefficientT(u,s,iCluster,isubpath)*t);      
%             end
%             tmp = sum(tmp);
%             H(u,s,iCluster,:) = tmp;
%         end
%     end
% end

for u = 1 : UEAntennaTotalNumber
    for s = 1 : BSAntennaTotalNumber
        for iCluster =  1 : ClusterNum
            tmp = zeros(20,P_num);
            for isubpath = 1 : 20
                  tmp(isubpath,:) = coefficientH(u,s,iCluster,isubpath)*exp(coefficientT(u,s,iCluster,isubpath)*t);      
            end
%           tmp = squeeze(coefficientH(u,s,iCluster,:))*exp(squeeze(coefficientT(u,s,iCluster,:)).*t);
            tmp = sum(tmp);
            H(u,s,iCluster,:) = tmp;
        end
    end
end



end
