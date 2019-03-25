%% 5G (New Radio) Physical Downlink Shared Channel (PDSCH)
% Copyright 2018 Wireless Signal Processing & Network Lab
%% Simulation Control
clear; clc;
addpath(genpath(pwd));
NSlots =4;                % Number of PDSCH slots to be simulated
SNRIn = [30];             % SNR range
hwait = waitbar(0,'Please wait>>>>>>>>');
stepWaitBar=NSlots/100;
%% System Parameters
% Initialize gNodeB parameters
gnb = nrGNBInit();
% Initialize UE parameters
ue = nrUEInit();
% Initialize PDSCH parameters
pdsch = nrPDSCHInit(gnb);
% Initialize channel parameters
channel = nrChannelInit(pdsch, gnb, ue);
[coefficientH,coefficientT] = nrChannelCoefficentInit(channel);
%% simulation statistics
simStatistics = nrSimStatisticsInit(SNRIn,NSlots,pdsch.TBNum);

MCSIndexCollect = [];
RankIndexCollect=[];

%Correlation matrix set calculation
[DMRSMatrixSet, CDMGroupMapSet]= nrPDSCHDmrsMatrix(gnb,pdsch);
RSMapMatrixSet = nrPDSCHRSMapMatrix(DMRSMatrixSet, pdsch.PdcchSymbolsLocation);
[DMRSLocationSet,DataLocationSet] = nrGetRSDataLocation(RSMapMatrixSet);
[RhhDMRSSet,RdhDMRSSet] = nrCalRhhRdh(DMRSLocationSet,DataLocationSet,channel);



%% Processing Loop
for snrIdx = 1:numel(SNRIn)
    
    % Set the random number generator to default values
    rng('default');
    
    SNRdB = SNRIn(snrIdx);
    
    % Initialize the state of all HARQ processes
    harqProcesses = nrHARQInit(pdsch);  %#OK
    
    % Initialize  MCS and OLLA parameter
    MCSIndex = ones(1,pdsch.TBNum);
    initOLLAoffset =[-0.5,-0.5,-0.5,-0.5];
    upoffset = 0.02;
    downoffset = upoffset*9;         %upoffset/(1/0.1-1);
    
    %Initialize  RI and LayerNum
    RI = 1;
    pdsch.Rank = RI;
    pdsch.LayerNum =nrCalLayerNum(pdsch.Rank);
    % Initialize codebook
    % 与基于非码本有关
    CodebookEst = [eye(pdsch.Rank);zeros(pdsch.PortCSIRS-pdsch.Rank,pdsch.Rank)]/sqrt(pdsch.Rank);
    % Running counter of the number of PDSCH transmission instances
    nslot = 0;
    
    while  nslot < NSlots
        %% ------------Progress bar settings-------------%%
        if NSlots-nslot<=5
            waitbar(nslot/NSlots,hwait,'Almost done');
            pause(0.05);
        else
            PerStr=fix(nslot/stepWaitBar);
            str=['SNR = ',num2str(SNRdB),'： ',num2str(PerStr),'% '];
            waitbar(nslot/NSlots, hwait, str);
            pause(0.05);
        end
        
        % Update Rank and LayerNum
        pdsch.Rank = RI;
        pdsch.LayerNum =nrCalLayerNum(RI);
        %% ---------- HARQ Schedule ---------- %%
        % Get HARQ process index for the current PDSCH
        harqProcIdx = mod(nslot, pdsch.NHARQProcesses) + 1;   %#OK
        % Update current HARQ process information
        harqProcesses(harqProcIdx) = nrHARQScheduling(harqProcesses(harqProcIdx), pdsch);   %#OK
        
        %%   ---------- resource elements available and Correlation matrix calculate ---------- %%
        %Determine if CSIRS exists in the current time slot
        if pdsch.TBNum==2
            RVIdx = max(harqProcesses(harqProcIdx).RVIdx(1),harqProcesses(harqProcIdx).RVIdx(2));
        else
            RVIdx = harqProcesses(harqProcIdx).RVIdx(1);
        end
        
        %Select Reaource Matrix and Correlation matrix by Rank
        DMRSMatrix  = DMRSMatrixSet{pdsch.Rank};
        CDMGroupMap = CDMGroupMapSet{pdsch.Rank};
        RSMapMatrix = RSMapMatrixSet{pdsch.Rank};                     %无CSIRS时的资源网格
        RhhDMRS = RhhDMRSSet{pdsch.Rank};                             %无CSIRS时的DMRS和Data相关矩阵
        RdhDMRS = RdhDMRSSet{pdsch.Rank};
        
        pdsch.pdschIndices = nrPDSCHIndices(RSMapMatrix);  %#OK                           %无CSIRS时的数据位置
        
        
        %%   ----------- transport block scheduling -------------%%
        for cwInd = 1:pdsch.TBNum
            if  harqProcesses(harqProcIdx).RVIdx(cwInd) == 1
                [harqProcesses(harqProcIdx).data{cwInd},harqProcesses(harqProcIdx).modu(cwInd),harqProcesses(harqProcIdx).R(cwInd),harqProcesses(harqProcIdx).TbLength(cwInd)] = nrCWScheduling(MCSIndex(cwInd),pdsch.LayerNum(cwInd),pdsch);
            end
        end
        %%  ---------Extract the current PDSCH transport block size(s),modu,R-------- %%
        trdata = harqProcesses(harqProcIdx).data;
        modu = harqProcesses(harqProcIdx).modu;
        R = harqProcesses(harqProcIdx).R;
        
        %% ----------  transport channel coding ---------- %%
        ncw = length(trdata);
        cw = cell(1, ncw);
        % Get data length after rate matching for each cw.
        codedTrBlkSizes = CalCWCodeLength(length(pdsch.pdschIndices), modu, pdsch.Rank);  %
        bgSign = zeros(1,ncw);
        
        for i = 1:ncw
            % RV
            pdsch.RV(i) = pdsch.RVSeq(harqProcesses(harqProcIdx).RVIdx(i));
            bgSign(i) = nrLDPCBaseGraphSelect(length(trdata{i}), R(i));
            % Transport block CRC attachment (TS38.212 Section 7.2.1)
            crced = nrCRCEncode(trdata{i});   %#OK
            % Code block segmentation and code block CRC attachment
            segmented = nrCodeBlockSegmentLDPC(crced, bgSign(i));             %#OK
            cbssize{i} = ones(length(segmented),1)*size(segmented{1},2);      %size of each cb
            cbNum = length(segmented);                                        %nums of cb
            harqProcesses(harqProcIdx).decState(i).CBSBuffers=cell(1,cbNum);
            
            % Get data length after rate matching for each cb
            codedCbBlkSizes = CalCBCodeLength(codedTrBlkSizes(i),cbNum,pdsch.Rank,modu(i));      %#OK
            % Channel coding
            Z(i) = LDPCPCMatrixSelect(cbssize{i}(1),bgSign(i));
            [HbmatrixBit{i},LDPCinflen(i),CodeLen(i)] = LDPCPCMatrix(Z(i));
            coded = nrLDPCEncode(segmented, cbssize{i}(1),Z(i),HbmatrixBit{i},LDPCinflen(i));                          %#OK
            % Rate matching and codeblock combine
            cw{i} = nrRateMatchLDPC(coded,codedCbBlkSizes,pdsch.RV(i),Z(i),bgSign(i),modu(i));     %#OK
        end
        
        
        
        %% ---------- PDSCH complex symbols generation ---------- %%
        scrambled = cell(1,ncw);
        modulated = cell(1,ncw);
        for i = 1:ncw
            % Scrambling
            scramblingSeq = nrScrambling(gnb.NCellID,pdsch.RNTI,i-1,size(cw{i},2));%s %#OK
            scrambled{i} = xor(cw{i},scramblingSeq);
            % Modulation
            modulated{i} = nrSymbolModulate(scrambled{i},modu(i)); %#OK
        end
        % Layer mapping
        layered = nrLayerMap(pdsch.Rank,modulated); %#OK
        % codebook select
        PrecodingMatrix= CodebookEst;
        % Data Precoding
        symbols = nrDLPrecode(PrecodingMatrix,layered);
        % DMRS Precoding
        DMRSMatrixAfterPrecode = nrDLPrecodeDMRS(PrecodingMatrix,DMRSMatrix);
        % Resource Mapping
        pdschGrid = nrResourceMapping(symbols,DMRSMatrixAfterPrecode,RSMapMatrix,pdsch);      %  #OK
        % Port Mapping
        PortMappingMat = nrGetPortMappingMatrix(gnb,pdsch);
        DataPortMap = nrAnalogPrecoding(PortMappingMat,pdschGrid);
        % OFDM modulation of associated resource elements
        txWaveform = nrOFDMModulate(gnb, pdsch, DataPortMap);      %#OK
        
        
        %% ---------- Pass data through channel model -------------%%
        % Generate  channel  according to  CoherenceTime
        if floor(channel.CoherenceTime/channel.SlotDuration) > 0
            if mod(nslot, floor(channel.CoherenceTime/channel.SlotDuration)) == 0
                H=GenerateChannel(nslot,channel,coefficientH,coefficientT);                       %#OK
            end
        else
            H=GenerateChannel(nslot,channel,coefficientH,coefficientT);
        end
        % Pass the channel, calculate the interference from last slot
        if nslot == 0
            PreInterfere=zeros(gnb.TxAntNum*ue.RxAntNum,pdsch.Ts);
        end
        [rxWaveform, PreInterfere]=PassChannel(txWaveform,PreInterfere,H,channel);      %#OK
        % Calculate linear noise gain
        SNR = 10^(SNRdB/20);
        % Normalize noise power
        N0 = 1/(sqrt(2.0)*SNR);
        % Create additive white Gaussian noise
        noise = N0*complex(randn(size(rxWaveform)),randn(size(rxWaveform)));
        % Add AWGN to the received time domain waveform
        rxWaveform = rxWaveform + noise;
        
        
        %% ---------- PDSCH complex symbols receive ---------- %%
        %OFDM Demodulate
        rxGrid = nrOFDMDemodulate(pdsch,rxWaveform);   %#OK
        %Resource Element Demapping
        [rxData,rxDMRS] = nrDeResourceMapping(rxGrid,DMRSMatrix,RSMapMatrix,CDMGroupMap);     %#OK
        
        % Ideal channel estimation
        [HIdeal,HIdealF] = nrPerfectChannelEstimate(pdsch,gnb,channel,H,PrecodingMatrix,RSMapMatrix,PortMappingMat);
        
        % SVD
        V1 = nrSVD(HIdeal,channel,pdsch);
        % Rank and MCS Select
        [RI,MCSIndex]=nrRankMCSSelect(ue,HIdeal,SNR^2,V1,initOLLAoffset,R(1),modu(1));
        CodebookEst= V1(:,1:RI)/sqrt(RI);%%取预编码矩阵的前RANK列
        
        % 记录所选的Rank和MCS
        RankIndexCollect= [RankIndexCollect,RI];
        MCSIndexCollect = [MCSIndexCollect,MCSIndex];
        
        
        % MMSE detection
        if pdsch.IdealChanEstEnabled== 1
            % Ideal channel MMSE detection
            [ MMSESymbols, MMSESinr ] = nrMMSEDetectorMIMO( rxData, HIdealF, SNR^2,pdsch.Rank);
        else
            %Real channel estimation
            HReal = nrChannelEstimation(rxDMRS,modu(1),RhhDMRS,RdhDMRS,SNR^2,ue.RxAntNum); %#OK
            % Real channel MMSE detection
            [ MMSESymbols, MMSESinr ] = nrMMSEDetectorMIMO( rxData, HReal, SNR^2,pdsch.Rank);         %#OK
        end
        %RB bundle deInterleaver
        if pdsch.EnableRbBundleInterleave == 1
            MMSESymbols = nrDeInterleaveRBBundle(MMSESymbols,RSMapMatrix,pdsch);
            MMSESinr = nrDeInterleaveRBBundle(MMSESinr,RSMapMatrix,pdsch);
        end
        %Layer demapping
        delayerSymbol = nrDeLayerMap(MMSESymbols); %#OK
        delayerSinr = nrDeLayerMap(MMSESinr);
        
        for i = 1:ncw
            % Demodulation
            demodulated{i} = nrSymbolDemodulate(delayerSymbol{i},modu(i),delayerSinr{i}); %#OK
            % DeScramble
            scramblingSeq = nrScrambling(gnb.NCellID,pdsch.RNTI,i-1,size(demodulated{i},2)) ;      %#OK
            scramblingSeq2 = 1-2*scramblingSeq;
            dlschBits{i} = demodulated{i}.*scramblingSeq2;
        end
        
        
        
        %% ----------  transport channel decoding ---------- %%
        for i = 1:ncw
            RVIdx = harqProcesses(harqProcIdx).RVIdx(i);
            codedCbBlkSizes = CalCBCodeLength(codedTrBlkSizes(i),cbNum,pdsch.Rank,modu(i));      %#OK
            [raterecovered,harqProcesses(harqProcIdx).decState(i).CBSBuffers] = nrRateDematcher(dlschBits{i},cbssize{i},codedCbBlkSizes,pdsch.RVSeq(RVIdx),Z(i),bgSign(i),LDPCinflen(i),CodeLen(i),harqProcesses(harqProcIdx).decState(i).CBSBuffers,modu(i));
            % Channel decoding
            decoded = nrLDPCDecode(raterecovered,cbssize{i},Z(i),HbmatrixBit{i},LDPCinflen(i));       %#OK
            % Code block desegmentation and code block CRC decoding
            [desegmented,harqProcesses(harqProcIdx).decState(i).CBSCRC] = nrCodeBlockDesegmentLDPC(decoded);          %#OK
            % Transport block CRC decoding
            [out,harqProcesses(harqProcIdx).decState(i).BLKCRC] = nrCRCDecode(desegmented,length(trdata{i}));         %#OK
            
            
            % change OLLA value according to BLKCRC
            if harqProcesses(harqProcIdx).decState(i).BLKCRC==1
                initOLLAoffset(pdsch.Rank) = initOLLAoffset(pdsch.Rank) - downoffset;
            else
                initOLLAoffset(pdsch.Rank) = initOLLAoffset(pdsch.Rank) + upoffset;
            end
            
            % block num statistics
            simStatistics{snrIdx}.BlkErrNum = simStatistics{snrIdx}.BlkErrNum + harqProcesses(harqProcIdx).decState(i).BLKCRC;
            if RVIdx == length(pdsch.RVSeq)  && harqProcesses(harqProcIdx).decState(i).BLKCRC==1
                MCSIndex(i) = max(1,MCSIndex(i)-1);
                simStatistics{snrIdx}.NewBlkErrNum = simStatistics{snrIdx}.NewBlkErrNum +1;
            end
            if RVIdx == 1
                simStatistics{snrIdx}.NewBlkNum = simStatistics{snrIdx}.NewBlkNum +1;
            end
            if harqProcesses(harqProcIdx).decState(i).BLKCRC==0
                simStatistics{snrIdx}.RightBitNum = simStatistics{snrIdx}.RightBitNum + length(trdata{i});
            end
        end
        
        
        % timing update for slot/subframe/frame indexes
        nslot = nslot + 1;
        gnb = nrGNBTimingUpdate(gnb, pdsch);
    end
    
    %% -----------  Bit error rate statistics ---------- %%
    simStatistics{snrIdx}.Bler = simStatistics{snrIdx}.BlkErrNum ./simStatistics{snrIdx}.BlkNum;
    simStatistics{snrIdx}.ResidualBler = simStatistics{snrIdx}.NewBlkErrNum./simStatistics{snrIdx}.NewBlkNum;
    simStatistics{snrIdx}.Throughput = simStatistics{snrIdx}.RightBitNum /(NSlots*pdsch.SlotDuration);
end

%% ----------- display results ---------- %%
for snrIdx = 1:numel(SNRIn)
    display(simStatistics{snrIdx})
    display(MCSIndexCollect)
    display(RankIndexCollect)
end
close(hwait);          % Close the progress bar
