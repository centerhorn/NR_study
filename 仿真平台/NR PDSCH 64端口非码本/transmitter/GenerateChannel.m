%% Function Description
%  Generate channel   (include TDL-A,TDL-B,TDL-C,CDL-A,CDL-B,CDL-C,CDL-D,CDL-E)
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
% 2018/5/21 created by Song Erhao
function [H] = GenerateChannel(BlockInd,channel,coefficientH,coefficientT)

if strcmp(channel.Type,'CDL-C')
    H = GenerateCDL_C(BlockInd,channel,coefficientH,coefficientT);
elseif strcmp(channel.Type,'CDL-D')
    H = GenerateCDL_D(BlockInd,channel,coefficientH,coefficientT);
end
end

