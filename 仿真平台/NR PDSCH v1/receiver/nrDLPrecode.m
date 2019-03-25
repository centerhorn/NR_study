%% Function Description
%  precoding for data
%% Input
% codebook: 2-Dimension array(portNums-layerNums)
%           codebook for precoding
% in      : 2-Dimension array(layers-symbols_per_layer)
%           data after layer mapping
%% Output
%  out    : 2-Dimension array(ports-symbols_per_port)
%           data after Precoding
%% Modify History
% 2018/3/28 created by Liu Chunhua 
% 2018/5/18 modified by Song Erhao

%% code
function out = nrDLPrecode(codebook,in)

out = codebook*in;

end