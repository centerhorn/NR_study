%% 函数功能：
% 用于生成codebook的函数
%% 输入参数：
% n：序号
%% 输出参数
% PhiN：函数值
%% Modify history
% 2018/1/9 created by Liu Chunhua
%% code
function PhiN = Phy(n)
    PhiN = exp(1i*pi*n/2);
end