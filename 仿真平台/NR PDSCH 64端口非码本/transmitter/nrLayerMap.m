%% Function Description
%  layer map for cw  (reference to TS38.211 Section 7.3.1.3)
%% Input
% Nlayers:  double
%           numbers of layers
% in     :  cell array(1 or 2 cell)
%           symbols after modulate
%% Output
% out    :  2-Dimension array(layers-symbols_per_layer)
%           data after layer mapping
%% Modify History
% 2018/3/28 created by Liu Chunhua 
% 2018/5/18 modified by Song Erhao(editorial changes only)

function out = nrLayerMap(Nlayers,in)
% 获得码字的个数
CWNum = length(in);
if CWNum>2
    error('码字数目超出协议规定的范围！');
end
% 层映射
if CWNum==1 && Nlayers<=4
   OutputLen = length(in{1})/Nlayers;
   out = (reshape(in{1},Nlayers,OutputLen)); 
elseif CWNum==2 && Nlayers>4 && Nlayers<=8
   CW1 = in{1};
   CW2 = in{2};
   CW1LayNum = floor(Nlayers/CWNum);
   CW2LayNum = ceil(Nlayers/CWNum);
   
   OutputLen = length(CW1)/CW1LayNum;
   DataOutCW1 = reshape(CW1,CW1LayNum,OutputLen); 
   DataOutCW2 = reshape(CW2,CW2LayNum,OutputLen); 
   out = ([DataOutCW1;DataOutCW2]);
end

end