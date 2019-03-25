function [h]=JakesGen(v,fc,t,seed)
%函数[h]=myjakesmodel(v,t,fc,k)，
%该程序利用改进的jakes模型来产生单径的平坦型瑞利衰落信道
%Yahong R.Zheng and Chengshan Xiao "Improved Models for
%the Generation of Multiple Uncorrelated Rayleigh Fading Waveforms"
%IEEE Commu letters, Vol.6, NO.6, JUNE 2002
%输入变量说明：
%  fc：载波频率 单位Hz
%  v:移动台速度  单位m/s
%  t :信道持续时间  单位s
%  seed: 产生衰落的随机数种子
%  h为输出的瑞利信道函数，是一个时间函数复序列
%作者：娄文科   日期：05.3.13
%产生第k条径的随机数
rand('state',seed);
%假设的入射波数目
N=40;
%电磁波传播速度即光速
c=3*10^8;
%最大多普勒频移
wm=2*pi*fc*v/c;
%每象限的入射波数目即振荡器数目
N0=N/4;
%信道函数的实部
Tc=zeros(1,length(t));
%信道函数的虚部
Ts=zeros(1,length(t));
%归一化功率系数
P_nor=sqrt(1/N0);
%区别个条路径的均匀分布随机相位
sita=2*pi*rand(1,1)-pi;
for I=1:N0
    %第i条入射波的入射角
    alfa(I)=(2*pi*I-pi+sita)/N;
    %对每个子载波而言在(-pi,pi)之间均匀分布的随机相位
    fi_tc=2*pi*rand(1,1)-pi;
    fi_ts=2*pi*rand(1,1)-pi;
    %计算冲激响应函数
    Tc=Tc+cos(cos(alfa(I))*wm*t+fi_tc);
    Ts=Ts+cos(sin(alfa(I))*wm*t+fi_ts);
end
%乘归一化功率系数得到传输函数
h=P_nor*(Tc+1i*Ts );