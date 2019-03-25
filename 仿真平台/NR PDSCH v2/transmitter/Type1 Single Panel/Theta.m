%% 函数功能：
% 用于生成codebook的函数
%% 输入参数：
% p：序号
%% 输出参数
% ThetaP：函数值
%% Modify history
% 2018/1/9 created by Liu Chunhua
%% code
function ThetaP = Theta(p)
    ThetaP = exp(1i*pi*p/4);
end