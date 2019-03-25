%% 5G (New Radio) Physical Downlink Shared Channel (PDSCH)
% Copyright 2018 Wireless Signal Processing & Network Lab
%% Simulation Control
clear; clc;
addpath(genpath(pwd));
NSlots = 1;                % Number of PDSCH slots to be simulated
SNRIn = [30];            % SNR range
hwait = waitbar(0,'Please wait>>>>>>>>');
stepWaitBar=NSlots/100;

%% System Parameters
% Initialize gNodeB parameters
gnb = nrGNBInit();  %#OK
% Initialize UE parameters
ue = nrUEInit();  %#OK
% Initialize PDSCH parameters
pdsch = nrPDSCHInit();  %#OK
% Initialize channel parameters
channel = nrChannelInit(pdsch, gnb, ue);                 %#OK  

%% simulation statistics
simStatistics = nrSimStatisticsInit(SNRIn,NSlots,pdsch.TBNum);     %#OK

%% Processing Loop
for snrIdx = 1:numel(SNRIn)
    
    % Set the random number generator to default values
    rng('default');
    
    SNRdB = SNRIn(snrIdx);
  
    % Initialize the state of all HARQ processes
    harqProcesses = nrHARQInit(pdsch);  %#OK
    
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
        
        %% ---------- resource elements available and Correlation matrix calculate ---------- %%
        [pdsch.DMRSMatrix, pdsch.CDMGroupMap]= nrPDSCHDmrsMatrix(gnb, pdsch);  %#OK
        pdsch.RSMapMatrix = nrPDSCHRSMapMatrix(pdsch.DMRSMatrix, pdsch.PdcchSymbolsLocation);  %#OK
        [pdsch.DMRSLocation,pdsch.DataLocation] = nrGetRSDataLocation(pdsch.RSMapMatrix);     %#OK
        [pdsch.RhhDMRS,pdsch.RdhDMRS] = nrCalRhhRdh(pdsch.DMRSLocation,pdsch.DataLocation,channel);       %#OK
        pdschIndices = nrPDSCHIndices(pdsch.RSMapMatrix);  %#OK
        
        %% ---------- transport block(s) ---------- %%
        % Get HARQ process index for the current PDSCH
        harqProcIdx = mod(nslot, pdsch.NHARQProcesses) + 1;   %#OK
        % Update current HARQ process information
        harqProcesses(harqProcIdx) = nrHARQScheduling(harqProcesses(harqProcIdx), pdsch);   %#OK residualBler
        % Extract the current PDSCH transport block size(s)
        trdata = harqProcesses(harqProcIdx).data;
        
        %% ----------  transport channel coding ---------- %%
        ncw = length(trdata);
        cw = cell(1, ncw);
        % Get data length after rate matching for each cw.
        codedTrBlkSizes = CalCWCodeLength(length(pdschIndices), pdsch.Modulation, pdsch.Rank);  %#OK
        bgSign = zeros(1,ncw);
        
        for i = 1:ncw
            % RV
            pdsch.RV(i) = pdsch.RVSeq(harqProcesses(harqProcIdx).RVIdx(i));
            % target code rate
            pdsch.TargetCodeRate(i) = pdsch.TrBlkSizes(i) / codedTrBlkSizes(i);
            % LDPC base graph selection
            bgSign(i) = nrLDPCBaseGraphSelect(length(trdata{i}), pdsch.TargetCodeRate(i));   %#OK
            % Transport block CRC attachment (TS38.212 Section 7.2.1)
            crced = nrCRCEncode(trdata{i}');   %#OK
            % Code block segmentation and code block CRC attachment
            segmented = nrCodeBlockSegmentLDPC(crced, bgSign(i));             %#OK
            cbssize{i} = ones(length(segmented),1)*size(segmented{1},2);      %size of each cb
            cbNum = length(segmented);                                        %nums of cb
            % Get data length after rate matching for each cb
            codedCbBlkSizes = CalCBCodeLength(codedTrBlkSizes(i),cbNum);      %#OK
            % Channel coding
            coded = nrLDPCEncode(segmented, bgSign);                          %#OK
            % Rate matching and codeblock combine
            cw{i} = nrRateMatchLDPC(coded,cbssize{i},codedCbBlkSizes,pdsch.RV(i),bgSign(i),pdsch.Modulation);     %#OK       iLBRM的取值？？？
        end
        
        
        
        %% ---------- PDSCH complex symbols generation ---------- %%
        scrambled = cell(1,ncw);
        modulated = cell(1,ncw);
        for i = 1:ncw
            % Scrambling
            scramblingSeq = nrScrambling(gnb.NCellID,pdsch.RNTI,i-1,size(cw{i},1));%s %#OK
            scrambled{i} = xor(cw{i},scramblingSeq.');
            %  scrambled{i} = cw{i};             %test code!!!
            % Modulation
            modulated{i} = nrSymbolModulate(scrambled{i},pdsch.Modulation); %#OK
        end
        % Layer mapping
        layered = nrLayerMap(pdsch.Rank,modulated); %#OK
        % Data Precoding
        symbols = nrDLPrecode(pdsch.Codebook,layered); % codebook的确定!!!
        % DMRS Precoding
        DMRSMatrixAfterPrecode = nrDLPrecodeDMRS(pdsch.Codebook,pdsch.DMRSMatrix); % codebook的确定
        % Resource Mapping
        pdschGrid = nrResourceMapping(symbols,DMRSMatrixAfterPrecode,pdsch.RSMapMatrix,pdsch);      %#OK
        % OFDM modulation of associated resource elements
        txWaveform = nrOFDMModulate(gnb, pdsch, pdschGrid);      %#OK
        
        
        
        %% ---------- Pass data through channel model -------------%%
%         Generate  channel
        H=GenerateChannel(nslot,channel);                       %#OK
        if nslot == 0
            PreInterfere=zeros(gnb.TxAntNum*ue.RxAntNum,pdsch.Ts);
        end
        [rxWaveform, PreInterfere]=PassChannel(txWaveform,PreInterfere,H,channel);      %#OK
        % Calculate linear noise gain
        SNR = 10^(SNRdB/20);
        % Normalize noise power
        N0 = 1/(sqrt(2.0)*SNR);
        % Create additive white Gaussian noise
        noise = N0*complex(randn(size(txWaveform)),randn(size(txWaveform)));
        % Add AWGN to the received time domain waveform
        % rxWaveform = rxWaveform + noise_test;           %测试代码！！
        rxWaveform = rxWaveform + noise;
        
         
        %% ---------- PDSCH complex symbols receive ---------- %%
        %OFDM Demodulate
        rxGrid = nrOFDMDemodulate(pdsch,rxWaveform);   %#OK
        %Resource Element Demapping
        [rxData,rxDMRS] = nrDeResourceMapping(rxGrid,pdsch.DMRSMatrix,pdsch.RSMapMatrix,pdsch.CDMGroupMap);     %#OK
        
        if pdsch.IdealChanEstEnabled== 1                                 %%not finished!!!
            %Ideal channel estimation
            HIdeal = nrPerfectChannelEstimate(pdsch,channel,H,codebook);
            % Ideal channel MMSE detection
            [ MMSESymbols, MMSESinr ] = nrMMSEDetectorMIMO( rxData, HIdeal, SNR^2,pdsch.Rank);
        else
            %Real channel estimation
            HReal = nrChannelEstimation(rxDMRS,pdsch.Modulation,pdsch.RhhDMRS,pdsch.RdhDMRS,SNR^2,ue.RxAntNum); %#OK            
            % Real channel MMSE detection
            [ MMSESymbols, MMSESinr ] = nrMMSEDetectorMIMO( rxData, HReal, SNR^2,pdsch.Rank);         %#OK
        end
        %RB bundle deInterleaver
        if pdsch.EnableRbBundleInterleave == 1
            MMSESymbols = nrDeInterleaveRBBundle(MMSESymbols,pdsch.RSMapMatrix,pdsch);  %#OK
            MMSESinr = nrDeInterleaveRBBundle(MMSESinr,pdsch.RSMapMatrix,pdsch);
        end
        %Layer demapping
        delayerSymbol = nrDeLayerMap(MMSESymbols); %#OK
        delayerSinr = nrDeLayerMap(MMSESinr);
        
        for i = 1:ncw
            % Demodulation
            demodulated{i} = nrSymbolDemodulate(delayerSymbol{i},pdsch.Modulation,delayerSinr{i}); %#OK
            % DeScramble
            scramblingSeq = nrScrambling(gnb.NCellID,pdsch.RNTI,i-1,size(demodulated{i},1)) ;      %#OK
            scramblingSeq2 = 1-2*scramblingSeq;
            dlschBits{i} = demodulated{i}.*scramblingSeq2.';
        end
        
        
        
        %% ----------  transport channel decoding ---------- %%
        for i = 1:ncw
            RVIdx = harqProcesses(harqProcIdx).RVIdx(i);
            % Rate recovery
            codedCbBlkSizes = CalCBCodeLength(codedTrBlkSizes(i),cbNum);
            % raterecovered = nrRateDematcher(dlschBits{i},cbssize{i},codedCbBlkSizes,pdsch.RVSeq(RVIdx),harqProcesses(harqProcIdx).decState(i).CBSBuffers,pdsch.Modulation);  %#OK
            [raterecovered,harqProcesses(harqProcIdx).decState(i).CBSBuffers] = nrRateDematcher(dlschBits{i},cbssize{i},codedCbBlkSizes,pdsch.RVSeq(RVIdx),harqProcesses(harqProcIdx).decState(i).CBSBuffers,pdsch.Modulation);
            % Channel decoding
            decoded = nrLDPCDecode(raterecovered,cbssize{i},codedCbBlkSizes);       %#OK
            % Code block desegmentation and code block CRC decoding
            [desegmented,harqProcesses(harqProcIdx).decState(i).CBSCRC] = nrCodeBlockDesegmentLDPC(decoded);          %#OK
            % Transport block CRC decoding
            [out,harqProcesses(harqProcIdx).decState(i).BLKCRC] = nrCRCDecode(desegmented,length(trdata{i}));         %#OK
            % block num statistics
            simStatistics{snrIdx}.BlkErrNum = simStatistics{snrIdx}.BlkErrNum + harqProcesses(harqProcIdx).decState(i).BLKCRC;
            if RVIdx == length(pdsch.RVSeq)  && harqProcesses(harqProcIdx).decState(i).BLKCRC==1
                simStatistics{snrIdx}.NewBlkErrNum = simStatistics{snrIdx}.NewBlkErrNum +1;
            end
            if RVIdx == 1
                simStatistics{snrIdx}.NewBlkNum = simStatistics{snrIdx}.NewBlkNum +1;
            end
        end
        
        
        % timing update for slot/subframe/frame indexes
        nslot = nslot + 1;
        gnb = nrGNBTimingUpdate(gnb, pdsch);
    end
    
    %% -----------  Bit error rate statistics ---------- %%
    simStatistics{snrIdx}.Bler = simStatistics{snrIdx}.BlkErrNum ./simStatistics{snrIdx}.BlkNum;
    simStatistics{snrIdx}.ResidualBler = simStatistics{snrIdx}.NewBlkErrNum./simStatistics{snrIdx}.NewBlkNum;
end

    %% ----------- display results ---------- %%
for snrIdx = 1:numel(SNRIn)
    display(simStatistics{snrIdx})
end


close(hwait);          % Close the progress bar