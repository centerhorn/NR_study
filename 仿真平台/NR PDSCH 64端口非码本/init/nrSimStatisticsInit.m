%% Function Description
%  Initialize simulation statistics configurations
%% Input
%  SNR    :   array
%             SNR to simulate
%  NSlots :   double
%             number of slots to simulate
%  TBNum  :   double
%             1 or 2
%% Output
%  simStatistics£ºcell array (include numel(SNR) structures)
%                 Configuration information for simulation statistics.
%% Modify History
%  2018/05/21 created by Song Erhao
%  2018/05/25 modified by Song Erhao
%%
function simStatistics = nrSimStatisticsInit(SNR,NSlots,TBNum)
simStatistics = cell(1,numel(SNR));
for SnrInd=1:numel(SNR)
    simStatistics{SnrInd}=deal(struct());
end

for SnrInd=1:numel(SNR)
    simStatistics{SnrInd}.Snr = SNR(SnrInd);
    simStatistics{SnrInd}.BlkErrNum = 0;
    simStatistics{SnrInd}.BlkNum = NSlots*TBNum;
    simStatistics{SnrInd}.Bler = 0;
    simStatistics{SnrInd}.NewBlkErrNum = 0;
    simStatistics{SnrInd}.NewBlkNum = 0; 
    simStatistics{SnrInd}.ResidualBler = 0;
    simStatistics{SnrInd}.RightBitNum = 0;
    simStatistics{SnrInd}.Throughput = 0;
    
end

end
