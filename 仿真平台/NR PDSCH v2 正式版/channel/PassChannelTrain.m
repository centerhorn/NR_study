%% Function Description
%  pass channel
%% Input
%  SignalIn :     2-Dimensional array(TxAntNum-symbols)
%                 data after OFDMModulate
%  PreInterfere : 2-Dimensional array(TxAntNum*RxAntNum-MaxDelay)
%                 interfere of last block
%  H  :           4-Dimensional array (UE_ANT_NUM-NB_ANT_NUM-MUL_PATH-(number of samples per slot + MaxDelay)).
%                 channel matrix    
%  channel:       Configuration Information for channel
%% Output  
%  SignalOut :   2-dimensional array(UE_ANT_NUM-(number of samples per slot))
%                data output
%  SignalInterfere: 2-dimensional array(TxAntNum*RxAntNum-MaxDelay)
%                   interfere for next block
%% Modify history
%  2018/1/18 created by Liu Chunhua 
%  2018/5/17 modified by Song Erhao(editorial changes only)
%  2018/5/21 modified by Song Erhao(add signal merge)
%% code
function [SignalOut, SignalInterfere] = PassChannelTrain(SignalIn,PreInterfere,H,channel)
UE_ANT_NUM=channel.UEAntNum;
NB_ANT_NUM=channel.NBAntNum;
MAX_DELAY=channel.MaxDelay;
delayout = channel.DelayOut;


MulPath  = size(H,3);
% 采样点个数
N = size(SignalIn,2);
% 前块干扰点数
PreSeqNum = min(MAX_DELAY,size(PreInterfere,2));
%% 信号过信道
SignalTemp = zeros(UE_ANT_NUM*NB_ANT_NUM,N+MAX_DELAY);
for u=1:UE_ANT_NUM %注意这是接收端天线
    for s=1:NB_ANT_NUM %发送天线
        for n=1:MulPath
            DelayAdd = delayout(n);
            HTemp=H(u,s,n,:);
%             SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):(DelayAdd+N)) = SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):(DelayAdd+N)) ...
%                 +SignalIn(s,:).*HTemp;
            SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):(DelayAdd+N)) = SignalTemp((u-1)*NB_ANT_NUM+s,(DelayAdd+1):((DelayAdd+N))) ...
                +SignalIn(s,:).*HTemp(1,(DelayAdd+1):(DelayAdd+N));
        end
    end
end
%% 整合前块干扰
for PathInd = 1:UE_ANT_NUM*NB_ANT_NUM
    SignalTemp(PathInd,1:PreSeqNum) = SignalTemp(PathInd,1:PreSeqNum)+PreInterfere(PathInd,1:PreSeqNum);
end
%% 输出信号
SignalOut = SignalTemp(:,1:N);
SignalInterfere = SignalTemp(:,N+1:N+PreSeqNum);