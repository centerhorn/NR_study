function [h]=JakesGen(v,fc,t,seed)
%����[h]=myjakesmodel(v,t,fc,k)��
%�ó������øĽ���jakesģ��������������ƽ̹������˥���ŵ�
%Yahong R.Zheng and Chengshan Xiao "Improved Models for
%the Generation of Multiple Uncorrelated Rayleigh Fading Waveforms"
%IEEE Commu letters, Vol.6, NO.6, JUNE 2002
%�������˵����
%  fc���ز�Ƶ�� ��λHz
%  v:�ƶ�̨�ٶ�  ��λm/s
%  t :�ŵ�����ʱ��  ��λs
%  seed: ����˥������������
%  hΪ����������ŵ���������һ��ʱ�亯��������
%���ߣ�¦�Ŀ�   ���ڣ�05.3.13
%������k�����������
rand('state',seed);
%��������䲨��Ŀ
N=40;
%��Ų������ٶȼ�����
c=3*10^8;
%��������Ƶ��
wm=2*pi*fc*v/c;
%ÿ���޵����䲨��Ŀ��������Ŀ
N0=N/4;
%�ŵ�������ʵ��
Tc=zeros(1,length(t));
%�ŵ��������鲿
Ts=zeros(1,length(t));
%��һ������ϵ��
P_nor=sqrt(1/N0);
%�������·���ľ��ȷֲ������λ
sita=2*pi*rand(1,1)-pi;
for I=1:N0
    %��i�����䲨�������
    alfa(I)=(2*pi*I-pi+sita)/N;
    %��ÿ�����ز�������(-pi,pi)֮����ȷֲ��������λ
    fi_tc=2*pi*rand(1,1)-pi;
    fi_ts=2*pi*rand(1,1)-pi;
    %����弤��Ӧ����
    Tc=Tc+cos(cos(alfa(I))*wm*t+fi_tc);
    Ts=Ts+cos(sin(alfa(I))*wm*t+fi_ts);
end
%�˹�һ������ϵ���õ����亯��
h=P_nor*(Tc+1i*Ts );