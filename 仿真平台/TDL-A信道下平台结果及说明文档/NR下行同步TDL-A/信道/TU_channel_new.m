%% �������ܣ�
% ģ�����ݰ����ŵ��Ĺ��̣�������ŵ���������Լ����¸����ݰ���ǰ�����
%% ���������
% signal �����ŵ�ǰ�������ź�
% pre_interfere��������һ����֡��ǰ�����
% H���ŵ�
% delays�������ӳ�
% mul_path���ྶ��Ŀ
%% ���������
% final_sig�����ŵ���������ź�
% signal_fere������֡����һ����֡��ǰ�����
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

N=length(signal);%�����źų���

pre_seq_max=size(pre_interfere,2);%ǰ����ŵĵڶ�ά��ά��
now_seq=floor(delays);%�Ը���·��delaysʱ������������ȡ��
now_seq_max=max(now_seq);%ȡ���·��ʱ����������
inte_signal=zeros(UE_ANT_NUM*NB_ANT_NUM,N+now_seq_max);%��ʼ�������źž��󣬵�һά��������ϣ��ڶ�ά���źų��ȼ������ʱ�ӵ���
%h=zeros(U*S,mul_path,N+now_seq_max);
%�õ���Ӧ�ŵ����ϵ��ŵ�����
for u=1:UE_ANT_NUM %��������
    for s=1:NB_ANT_NUM %��������
        for b=1:mul_path %�ŵ�
            delay_add=delays(b)+1;
            %h((u-1)*2+s,b,:)=H(u,s,b,:);%*Am(i);
            temp_h(1,:)=H(u,s,b,:);%h((u-1)*2+s,b,:);
            inte_signal((u-1)*NB_ANT_NUM+s,delay_add:delay_add+N-1)=inte_signal((u-1)*NB_ANT_NUM+s,delay_add:delay_add+N-1)+signal(s,:).*temp_h(1,delay_add:delay_add+N-1);%signal�Է�������Ϊ׼
        end
    end
end
%h(1,b,:)=H(1,1,b,:);%*Am(i);
%h(2,b,:)=H(1,2,b,:);%*Am(i);
%h(3,b,:)=H(2,1,b,:);%*Am(i);
%h(4,b,:)=H(2,2,b,:);%*Am(i);

%for n=1:mul_path%�ྶ����
%    delay_add=delays(n)+1;
%    for m=1:U*S
%        aa(m,:)=h(m,n,:);
%    end
%    inte_signal(1,delay_add:delay_add+N-1)=inte_signal(1,delay_add:delay_add+N-1)+signal.*aa(1,delay_add:delay_add+N-1);
%inte_signal(2,delay_add:delay_add+N-1)=inte_signal(2,delay_add:delay_add+N-1)+signal.*aa(2,delay_add:delay_add+N-1);
%inte_signal(3,delay_add:delay_add+N-1)=inte_signal(3,delay_add:delay_add+N-1)+temp_signal.*aa(3,delay_add:delay_add+N-1);
%inte_signal(4,delay_add:delay_add+N-1)=inte_signal(4,delay_add:delay_add+N-1)+temp_signal.*aa(4,delay_add:delay_add+N-1);
%end
for j=1:UE_ANT_NUM*NB_ANT_NUM%�ϸ���Ա���ĸ���
    inte_signal(j,1:pre_seq_max)=inte_signal(j,1:pre_seq_max)+pre_interfere(j,:);
end
%����ź�
final_sig=inte_signal(:,1:N);
signal_fere=inte_signal(:,N+1:N+now_seq_max);