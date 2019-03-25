%% 函数功能：
% 根据传输数据和信噪比，生成特定的噪声向量，模拟信号通过复数AWGN信道
%% 输入参数：
% DataIn:已调输入信号
% SnrLinear：线性输入信噪比
%% 输出参数
% NoiseVec: 叠加的噪声向量
%% Modify history
% 2016/06/22 created by Zhao Zhongyuan
%% code
function [NoiseVec] = AwgnGen(DataIn, SnrLinear)
NoiseLength = length(DataIn);          % 输入信号长度
NoisePow = 1 / SnrLinear;              % 利用系统给定的信噪比计算出高斯白噪声的功率，单位是W
NoiseVec = (sqrt(NoisePow / 2)) * complex(randn(1,NoiseLength), randn(1,NoiseLength));  %产生长度为N的复高斯白噪声向量
end