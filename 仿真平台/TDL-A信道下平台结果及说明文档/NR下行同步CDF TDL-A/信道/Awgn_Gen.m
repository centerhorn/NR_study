%% �������ܣ�
% ���ݴ������ݺ�����ȣ������ض�������������ģ���ź�ͨ������AWGN�ŵ�
%% ���������
% DataIn:�ѵ������ź�
% SnrLinear���������������
%% �������
% NoiseVec: ���ӵ���������
%% Modify history
% 2016/06/22 created by Zhao Zhongyuan
%% code
function [NoiseVec] = AwgnGen(DataIn, SnrLinear)
NoiseLength = length(DataIn);          % �����źų���
NoisePow = 1 / SnrLinear;              % ����ϵͳ����������ȼ������˹�������Ĺ��ʣ���λ��W
NoiseVec = (sqrt(NoisePow / 2)) * complex(randn(1,NoiseLength), randn(1,NoiseLength));  %��������ΪN�ĸ���˹����������
end