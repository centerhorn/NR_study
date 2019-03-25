%% Function Description
%  Initialize PDSCH configurations
%% Input
%  gnbConfig :  Structure.
%               Configuration information for PDSCH
%% Output
%  pdschConfig：Structure.
%               Configuration information for PDSCH.
%% Modify History
%  2018/04/17 created by Liu Chunhua 
%  2018/04/18 modified by Li Yong (editorial changes only)
%  2018/05/16 modified by Song Erhao
%%
function pdschConfig = nrPDSCHInit(gnbConfig)  %#OK

% basic configuration
pdschConfig.RNTI = 1;
pdschConfig.NDLRB = 10;
pdschConfig.PRBSet = (0:pdschConfig.NDLRB-1)';  % Fullband PDSCH allocation
pdschConfig.SubcarrierSpacing = 15;             % 15,30,60,120,240 (kHz)               
pdschConfig.SubcarriersPerRB = 12;              % number of subcarriers per RB
pdschConfig.SlotDuration = 1*10^(-3)/(pdschConfig.SubcarrierSpacing/15);       
pdschConfig.SymbolsPerSlot = 14;                % number of OFDM symbols per slot
pdschConfig.PdschSymbolsLocation = 2:13;         % PDSCH symbol locations within a slot
pdschConfig.PdcchSymbolsLocation = 0:1;          % PDCCH (CORESET) symbol locations within a slot
pdschConfig.IfftSize = 2^length(dec2bin(pdschConfig.NDLRB*pdschConfig.SubcarriersPerRB)); 
pdschConfig.Ts = pdschConfig.IfftSize*15;       % number of samples per slot
mu = log2(pdschConfig.SubcarrierSpacing/15);
pdschConfig.SamplesPerLongCP = (144+16*2^mu) * (pdschConfig.IfftSize/2048);     % refer to TS 38.211 Section 5.3 (need some derivation)
pdschConfig.SamplesPerShortCP = 144 * (pdschConfig.IfftSize/2048);              % refer to TS 38.211 Section 5.3 (need some derivation)
pdschConfig.LongCPPeriod = 7 * 2^mu;                                            % refer to TS 38.211 Section 5.3 (there should be two long-CP symbols per 1ms subframe for any SCS)
pdschConfig.IdealChanEstEnabled= 0;              %ideal channel estimation
% link parameters
pdschConfig.TBNum = 1;                          %TB num for each slot(1 or 2)
pdschConfig.EnableAdaptiveRank = false;         % 'true' or 'false'
pdschConfig.Rank = 2;                           % applicable only for the first slot when EnableAdaptiveRank is true              
pdschConfig.EnableAMC = true;                  % 'true' or 'false'
pdschConfig.Enable256QAM = true;                % 'true' or 'false'
pdschConfig.LayerNum =nrCalLayerNum(pdschConfig.Rank);          % layer num of each cw
if  pdschConfig.TBNum >2
    error('NR supports at most 2 codewords!');
end
%if ceil(pdschConfig.Rank/4) ~= numel(pdschConfig.Modulation)
if ceil(pdschConfig.Rank/4) ~= pdschConfig.TBNum
    error('The numbers of codewords and layers do not match!');
end

% HARQ
pdschConfig.NHARQProcesses = 8;
pdschConfig.EnableHARQ = true;                  % 'true' or 'false'
if pdschConfig.EnableHARQ
    pdschConfig.RVSeq = [0 1 2 3];
else
    pdschConfig.RVSeq = 0;                      % no retransmissions
end

% DMRS (refer to TS 38.211 Section 7.4.1.1)
pdschConfig.DmrsConfigType = 'type 1';        % 'type 1' or 'type 2'
pdschConfig.DmrsMappingType = 'type A';         % 'type A' or 'type B'
pdschConfig.DmrsTypeAPos = 3;                 % DMRS type A position, valued by 3 or 2
pdschConfig.DmrsTypeBPos = 0;                 % DMRS type B position
pdschConfig.DmrsAddPos = 0;                   % additional DMRS position number                1改为0
if pdschConfig.DmrsAddPos == 3 && pdschConfig.DmrsTypeAPos ~= 2
    error('The case DL-DMRS-add-pos equal to 3 is only supported when DL-DMRS-typeA-pos is equal to 2!');
end
pdschConfig.betaDmrs = 1;                     % the power offset for DMRS

%CSI-RS
pdschConfig.CSIRSPeriod = 2;%10ms，可供选择的周期有 [5 10 20 40 80 160 320 640]ms
pdschConfig.CSIRSSlotOffset = 0;%在0-（CSIRS_PERIOD-1）之间
pdschConfig.Density = 1;%csi-rs的密度，对于rowInd为1时，density仍然取1。
pdschConfig.BetaCSIRS = 1;
pdschConfig.L0CSIRS = 5;%configured by the higher-layer parameter CSI-RS-ResourceMapping.
pdschConfig.L1CSIRS = 12;
pdschConfig.RowIndex = 3;

%CSI Report parameters
pdschConfig.CQIDelay = 2;%CQI时延
pdschConfig.CQIPeriod = 6;%CQI周期
pdschConfig.PMIPeriod = 6;%PMI周期
pdschConfig.PMIDelay = 2;%PMI时延

%Codebook
pdschConfig.CodebookBased = 1; %基于码本
pdschConfig.CodebookSelectPrinciple = 2;
pdschConfig.PortCSIRS = gnbConfig.TxAntNum;
if pdschConfig.PortCSIRS >2
    CodeBookMode = 1;
    N1N2Conf = [2 2 4 3 6 4 8 4 6 12 4 8 16;1 2 1 2 1 2 1 3 2 1 4 2 1];
    O1O2Conf = [4*ones(1,13);1 4 1 4 1 4 1 4 4 1 4 4 1];
    pdschConfig.PCSIRSConf = [4 8 8 12 12 16 16 24 24 24 32 32 32];
    IndTemp = find(pdschConfig.PCSIRSConf==pdschConfig.PortCSIRS);
    IndT = IndTemp(1);
    ON12 = [O1O2Conf(1,IndT),O1O2Conf(2,IndT),N1N2Conf(1,IndT),N1N2Conf(2,IndT)];
else
    CodeBookMode = 0;
    ON12 = zeros(1,4);
end
pdschConfig.CodebookTotal = Type1_SinglePanel_Codebook(pdschConfig.PortCSIRS,pdschConfig.Rank,CodeBookMode,ON12);

% RB bundle interleaving
pdschConfig.EnableRbBundleInterleave = true;
pdschConfig.RbBundleSize = 2;