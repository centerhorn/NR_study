%% Function Description
%   Layer demapping
%% Input
%   in :  2-Dimensional array (Rank-DataRENum)
%         data or SINR of data after MMSE detection
%% Output
%   out : cell array (1 or 2 cell)    
%         data after layer demapping,each array is a column vector
%% Modify history
% 2018/3/28 created by Liu Chunhua 
% 2018/5/22 modified by Song Erhao


function out = nrDeLayerMap(in)
% 获得层数
  LayerNum = size(in,1);
% 获得码字个数
if LayerNum<=4
    % 一个码字，解层映射
    out{1} = reshape(in,[],1);
    out{1} = out{1}.';
else
    % 两个码字
    CWNum = 2;
    CW1LayNum = floor(LayerNum/CWNum);
    % 解层映射
    out{1} = reshape(in(1:CW1LayNum,:),[],1);
    out{2} = reshape(in(CW1LayNum+1:end,:),[],1);
    out{1} = out{1}.';
    out{2} = out{2}.';
end
end