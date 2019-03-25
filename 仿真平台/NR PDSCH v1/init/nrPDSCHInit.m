%% Function Description
%  Initialize PDSCH configurations
%% Input
%  void
%% Output
%  pdschConfig£ºStructure.
%               Configuration information for PDSCH.
%% Modify History
%  2018/04/17 created by Liu Chunhua 
%  2018/04/18 modified by Li Yong (editorial changes only)
%  2018/05/16 modified by Song Erhao
%  2018/05/21 modified by Song Erhao(add IdealChanEstEnabled)
%%
function pdschConfig = nrPDSCHInit()  %#OK

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
%pdschConfig.IfftSize = 2048;                    %²âÊÔ´úÂë
pdschConfig.Ts = pdschConfig.IfftSize*15;       % number of samples per slot
mu = log2(pdschConfig.SubcarrierSpacing/15);
pdschConfig.SamplesPerLongCP = (144+16*2^mu) * (pdschConfig.IfftSize/2048);     % refer to TS 38.211 Section 5.3 (need some derivation)
pdschConfig.SamplesPerShortCP = 144 * (pdschConfig.IfftSize/2048);              % refer to TS 38.211 Section 5.3 (need some derivation)
pdschConfig.LongCPPeriod = 7 * 2^mu;                                            % refer to TS 38.211 Section 5.3 (there should be two long-CP symbols per 1ms subframe for any SCS)
pdschConfig.IdealChanEstEnabled=1;              %ideal channel estimation
% link parameters
pdschConfig.TBNum = 1;                          %TB num for each slot(1 or 2)
pdschConfig.EnableAdaptiveRank = false;         % 'true' or 'false'
pdschConfig.Rank = 1;                           % applicable only for the first slot when EnableAdaptiveRank is true 
% pdschConfig.Codebook = [0.7071 0.7071;0.7071 -0.7071];                      
pdschConfig.Codebook = [1];                      

pdschConfig.EnableAMC = false;                  % 'true' or 'false'
pdschConfig.Modulation = [2];                 % 2 for 'QPSK', 4 for '16QAM', 6 for '64QAM', 8 for '256QAM' (applicable only for the first slot when EnableAMC is true)
% pdschConfig.CodeRate = 0.5;                     % applicable only for the first slot when EnableAMC is true
pdschConfig.TrBlkSizes = [656];                  % applicable only when EnableAMC is true
pdschConfig.Enable256QAM = true;                % 'true' or 'false'
pdschConfig.CqiIndex(1) = 1;                    % initialize CQI index
if numel(pdschConfig.Modulation) > 2
    error('NR supports at most 2 codewords!');
end
if ceil(pdschConfig.Rank/4) ~= numel(pdschConfig.Modulation)
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
pdschConfig.DmrsAddPos = 0;                   % additional DMRS position number                1¸ÄÎª0
if pdschConfig.DmrsAddPos == 3 && pdschConfig.DmrsTypeAPos ~= 2
    error('The case DL-DMRS-add-pos equal to 3 is only supported when DL-DMRS-typeA-pos is equal to 2!');
end
pdschConfig.betaDmrs = 1;                     % the power offset for DMRS

% RB bundle interleaving
pdschConfig.EnableRbBundleInterleave = true;
pdschConfig.RbBundleSize = 2;