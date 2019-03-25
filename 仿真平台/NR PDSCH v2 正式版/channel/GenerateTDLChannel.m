%% Function Description
%  Generate TDL channel
%% Input
%  BlockInd : double
%             Index of slot 
%  channel :  structure
%             configuration information for channel
%% Output
%   H:        4-dimensional array (UE_ANT_NUM-NB_ANT_NUM-MUL_PATH-(number of samples per slot + Max_Delay)).
%             channel matrix
%% Modify history
% 2018/1/18 created by Liu Chunhua 
% 2018/5/17 modified by Song Erhao

function [H] = GenerateTDLChannel(BlockInd,channel)
%%%%%%%%%%%%%%%%% 产生信道（一个一个数据包产生）%%%%%%%%%%%%%%%%%%%%%
UE_SPEED = channel.UESpeed ;

CARRIER_FREQUENCY = channel.CenterFrequency ;
MUL_PATH = channel.MulPath ;
Am = channel.Am ;

UE_ANT_NUM = channel.UEAntNum ;
NB_ANT_NUM = channel.NBAntNum ;
MAX_DELAY = channel.MaxDelay ;
% 一个子slot的持续时间(s)
period=channel.SlotDuration;
% 产生信道的采样周期
Ts=1*10^(-3)/channel.T; 
%% 生成信道
for u=1:UE_ANT_NUM
    for s=1:NB_ANT_NUM
        %%%%%%%%%%%%%%产生信道%%%%%%%%%%%%%%%
        ChannelState=rand(1,MUL_PATH)*sum(100*clock);        
        t=BlockInd*period:Ts:((BlockInd+1)*period-Ts+MAX_DELAY*Ts);

        for n=1:MUL_PATH
            channel=JakesGen(UE_SPEED,CARRIER_FREQUENCY,t,ChannelState(n));
%             channel=Jakes_gen_yong(UE_SPEED,CARRIER_FREQUENCY,t);
% % % %             channel=Jakes_gen_ruili(UE_SPEED,CARRIER_FREQUENCY,Ts);
% % % %             H(u,s,n,:) = Am(n)*filter(channel,ones(1,NumSam));
            H(u,s,n,:)=channel*Am(n);
            
        end
    end
end
end