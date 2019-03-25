%% Function Description
% Merge received signal together
%% Input
%  DataAfterChannel :    2-Dimensional array(UE_ANT_NUM*NB_ANT_NUM-(number of samples per slot))
%                        data after channel
%  channel          :    structure
%                   :    Configuration Information for channel
%% Output  
%  DataMerge        :    2-Dimensional array(UE_ANT_NUM-number of samples  per slot
%                   :    data after merge
%% Modify history
%  2018/5/19 created by Song Erhao

function DataMerge = nrSignalMerge(DataAfterChannel,channel)
% ºÏ²¢ÐÅºÅ
if channel.NBAntNum==1 && channel.UEAntNum==1
    DataMerge = DataAfterChannel;
else
    DataMerge = [];
    for RxAntNum = 1:channel.UEAntNum
        DataMerge = [DataMerge;sum(DataAfterChannel((RxAntNum-1)*channel.NBAntNum+1:RxAntNum*channel.NBAntNum,:))];
    end
end
end



