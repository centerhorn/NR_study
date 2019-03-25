%% Description
% Function zadoff_chu can be used to generate zadoff-chu sequence.
%% Input parameter
% length: the length of zadoff-chu sequence;
% index: zadoff-chu root sequence index;
%% Output parameter
% y: the generated zadoff_chu sequence;
%% Modify history
% 2017/3/9 created by He Yuexia
%% Codes
function y = zadoff_chu(length,index)

if (bitand(length,1))
  y=exp(-j*index*pi/length*(0:length-1).*(1:length));
else
  y=exp((-1).^[0:length-1].*j*index*2*pi/length.*floor([0:length-1]./2).^(floor([0:length-1]./2)+1));
end

