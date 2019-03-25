%% 函数功能：
% 模拟数据包过信道的过程，输出过信道后的数据以及对下个数据包的前块干扰
%% 输入参数：
% signal ：过信道前的数据信号
% pre_interfere：来自上一个子帧的前块干扰
% H：信道
% delays：各径延迟
% mul_path：多径数目
%% 输出参数：
% final_sig：过信道后的数据信号
% signal_fere：该子帧对下一个子帧的前块干扰
%% Modify history
% 2017/10/28 created by Liu Chunhua 
%% code
function[final_sig,signal_fere]=TU_channel_new(signal,pre_interfere,H,delays,mul_path)
global UE_ANT_NUM;
global NB_ANT_NUM;

%S    =2;               % number of receiving antennas
%U    =2;               % number of transmitting antennas
%Ts=1*10^(-3)/15/1024;
%Delay=10^(-9)*[0,310,710,1090,1730,2510];
%relative_power=[0,-1,-9,-10,-15,-20];
%Am=sqrt(10.^(0.1*relative_power));
%Am=Am./sqrt(sum(Am.^2));
%m_max=floor(max(Delay)/Ts);

N=length(signal);%输入信号长度

pre_seq_max=size(pre_interfere,2);%前块干扰的第二维的维数
now_seq=floor(delays);%对各条路径delays时延量化点数下取整
now_seq_max=max(now_seq);%取最大路径时延量化点数
inte_signal=zeros(UE_ANT_NUM*NB_ANT_NUM,N+now_seq_max);%初始化干扰信号矩阵，第一维是天线组合，第二维是信号长度加上最大时延点数
%h=zeros(U*S,mul_path,N+now_seq_max);
%得到对应信道的上的信道函数
for u=1:UE_ANT_NUM %接收天线
    for s=1:NB_ANT_NUM %发送天线
        for b=1:mul_path %信道
            delay_add=delays(b)+1;
            %h((u-1)*2+s,b,:)=H(u,s,b,:);%*Am(i);
            temp_h(1,:)=H(u,s,b,:);%h((u-1)*2+s,b,:);
            inte_signal((u-1)*NB_ANT_NUM+s,delay_add:delay_add+N-1)=inte_signal((u-1)*NB_ANT_NUM+s,delay_add:delay_add+N-1)+signal(s,:).*temp_h(1,delay_add:delay_add+N-1);%signal以发送天线为准
        end
    end
end
%h(1,b,:)=H(1,1,b,:);%*Am(i);
%h(2,b,:)=H(1,2,b,:);%*Am(i);
%h(3,b,:)=H(2,1,b,:);%*Am(i);
%h(4,b,:)=H(2,2,b,:);%*Am(i);

%for n=1:mul_path%多径叠加
%    delay_add=delays(n)+1;
%    for m=1:U*S
%        aa(m,:)=h(m,n,:);
%    end
%    inte_signal(1,delay_add:delay_add+N-1)=inte_signal(1,delay_add:delay_add+N-1)+signal.*aa(1,delay_add:delay_add+N-1);
%inte_signal(2,delay_add:delay_add+N-1)=inte_signal(2,delay_add:delay_add+N-1)+signal.*aa(2,delay_add:delay_add+N-1);
%inte_signal(3,delay_add:delay_add+N-1)=inte_signal(3,delay_add:delay_add+N-1)+temp_signal.*aa(3,delay_add:delay_add+N-1);
%inte_signal(4,delay_add:delay_add+N-1)=inte_signal(4,delay_add:delay_add+N-1)+temp_signal.*aa(4,delay_add:delay_add+N-1);
%end
for j=1:UE_ANT_NUM*NB_ANT_NUM%上个块对本块的干扰
    inte_signal(j,1:pre_seq_max)=inte_signal(j,1:pre_seq_max)+pre_interfere(j,:);
end
%输出信号
final_sig=inte_signal(:,1:N);
signal_fere=inte_signal(:,N+1:N+now_seq_max);