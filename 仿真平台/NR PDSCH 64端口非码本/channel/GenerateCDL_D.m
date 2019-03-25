%% Function Description
%  Generate CDL-D-CAICT channel
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
%  2018/5/30 modified by Song Erhao
function [H] = GenerateCDL_D_CAICT(BlockInd,channel,coefficientH,coefficientT)

% parameter
MAX_DELAY = channel.MaxDelay ;
period = channel.SlotDuration;
Ts=period/channel.T;
UEAntennaTotalNumber = channel.UEAntNum;
BSAntennaTotalNumber = channel.NBAntNum;
ClusterNum = channel.MulPath;

t=BlockInd*period:Ts:((BlockInd+1)*period-Ts+MAX_DELAY*Ts);   %采样时间向量         %实际采样间隔为Ts
P_num = size(t,2);

% channel generate
H = zeros(UEAntennaTotalNumber,BSAntennaTotalNumber,ClusterNum,P_num);
for u = 1 : UEAntennaTotalNumber
    for s = 1 : BSAntennaTotalNumber
        for iCluster =  1 : ClusterNum
            %             if iCluster == ClusterNum
            if iCluster == 1
                tmp = zeros(1,P_num);
                tmp(:) = coefficientH(u,s,iCluster,1)*exp(coefficientT(u,s,iCluster,1)*t);
            else
                tmp = zeros(20,P_num);
                for isubpath = 1 : 20
                    tmp(isubpath,:) = coefficientH(u,s,iCluster,isubpath)*exp(coefficientT(u,s,iCluster,isubpath)*t);
                end
                tmp = sum(tmp);
            end
            H(u,s,iCluster,:) = tmp;
        end
    end
end

end


