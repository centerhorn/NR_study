%% Function Description
%  Generate channel   (include TDL-A,TDL-B,TDL-C,CDL-A,CDL-B,CDL-C,CDL-D,CDL-E)
%% Input
%  BlockInd : double
%             Index of slot 
%  channel :  structure
%             configuration information for channel
%% Output
%   H:        4-dimensional array (UE_ANT_NUM-NB_ANT_NUM-MUL_PATH-(number of samples per slot + Max_Delay)).
%             channel matrix
%% Modify history
% 2018/5/21 created by Song Erhao
function [H] = GenerateChannel(BlockInd,channel)

if strncmp(channel.Type,'TDL',3)
    H = GenerateTDLChannel(BlockInd,channel);     %#OK
elseif strcmp(channel.Type,'CDL-A') || strcmp(channel.Type,'CDL-B') || strcmp(channel.Type,'CDL-C')
    H= GenerateCDLNlosChannel(BlockInd,channel);         %#OK
elseif strcmp(channel.Type,'CDL-D') || strcmp(channel.Type,'CDL-E')
    H= GenerateCDLLosChannel(BlockInd,channel);          %#OK
else
    error('No such channel type!');
end
end

