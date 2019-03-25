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
% ��ò���
  LayerNum = size(in,1);
% ������ָ���
if LayerNum<=4
    % һ�����֣����ӳ��
    out{1} = reshape(in,[],1);
    out{1} = out{1}.';
else
    % ��������
    CWNum = 2;
    CW1LayNum = floor(LayerNum/CWNum);
    % ���ӳ��
    out{1} = reshape(in(1:CW1LayNum,:),[],1);
    out{2} = reshape(in(CW1LayNum+1:end,:),[],1);
    out{1} = out{1}.';
    out{2} = out{2}.';
end
end