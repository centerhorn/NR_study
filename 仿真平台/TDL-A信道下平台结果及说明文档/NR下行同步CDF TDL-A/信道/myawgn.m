% �ó�������ģ���ź�ͨ������AWGN�ŵ������ڡ���·�����������ơ�����һ���ŵ�ģ��
function [y, noise_power]=myawgn(x,SNR_in_dB)
%y= myawgn(x,SNR_in_dB)
% x�ǳ���Ϊ1��Lp���ѵ������źţ�SNR_in_dBΪ��������ȣ���λΪdB��
%SNR_in_dB=S/N,S��1Ϊ�����źŹ��ʣ�N=N0/2= ��^2Ϊ���������ʣ�N0Ϊ�������ĵ��߹������ܶ�                              
% yΪxͨ��AWGN�ŵ��������ź�
%���ߣ�¦�Ŀ� ���ڣ�2005��2��22
if nargin~=2 
    error('input arguments are not matched ')
end
%���������ź����г���                         
N=length(x);
%����ϵͳ����������ȼ������˹�������Ĺ��ʣ���λ��W
SNR_linr=exp(SNR_in_dB*log(10)/10);
noise_power=1/SNR_linr;
%��������ΪN�ĸ���˹����������
noise_vector= (sqrt(noise_power/2))*(randn(1,N)+j*randn(1,N));
%���źŵ�������
y=x+noise_vector;