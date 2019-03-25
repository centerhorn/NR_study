%% 5G (New Radio) Physical Downlink Shared Channel (PDSCH)
% Copyright 2018 Wireless Signal Processing & Network Lab
%% Simulation Control
tic;
clear; clc;
addpath(genpath(pwd));
NSlots =32;                % Number of PDSCH slots to be simulated
SNRIn = [0 ];             % SNR range
hwait = waitbar(0,'Please wait>>>>>>>>');
stepWaitBar=NSlots/100;
%% System Parameters
% Initialize gNodeB parameters
gnb = nrGNBInit();  %#OK
% Initialize UE parameters
ue = nrUEInit();  %#OK
% Initialize PDSCH parameters
pdsch = nrPDSCHInit(gnb);  %#OK
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
    
   % Initialize  PMI parameter
    PMISeq = ones(1,pdsch.PMIDelay);
    CodebookIndexEst = 1;%Initialize PMI
    
    % Initialize  CQI parameter
    CQISeq = ones(pdsch.CQIDelay,pdsch.TBNum);
    CqiIndexEst = ones(1,pdsch.TBNum);
    CqiIndex = ones(1,pdsch.TBNum); 
    
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
        
        % Update  PMI parameter
        PMISeq(1:(pdsch.PMIDelay-1)) = PMISeq(2:pdsch.PMIDelay);
        PMISeq(pdsch.PMIDelay) = CodebookIndexEst;
        CodebookIndex = PMISeq(1);
        
        % Update CQI parameter
        CQISeq(1:(pdsch.CQIDelay-1),:) = CQISeq(2:pdsch.CQIDelay,:);
        CQISeq(pdsch.CQIDelay,:) = ceil((CqiIndexEst+CqiIndex)/2);
        CqiIndex = CQISeq(1,:);
                
        %% ---------- HARQ Schedule ---------- %%
        % Get HARQ process index for the current PDSCH
        harqProcIdx = mod(nslot, pdsch.NHARQProcesses) + 1;   %#OK
        % Update current HARQ process information
        harqProcesses(harqProcIdx) = nrHARQScheduling(harqProcesses(harqProcIdx), pdsch);   %#OK
        
        %%   ---------- resource elements available and Correlation matrix calculate ---------- %%
        [DMRSMatrix, CDMGroupMap]= nrPDSCHDmrsMatrix(gnb,pdsch);  %#OK        %DMRS资源位置
        %Determine if CSIRS exists in the current time slot
        if pdsch.TBNum==2
            RVIdx = max(harqProcesses(harqProcIdx).RVIdx(1),harqProcesses(harqProcIdx).RVIdx(2));
        else
            RVIdx = harqProcesses(harqProcIdx).RVIdx(1);
        end
          if mod(nslot+1-(RVIdx-1)*pdsch.NHARQProcesses,pdsch.CSIRSPeriod) == pdsch.CSIRSSlotOffset+1     %根据初传时隙判断
            WithCSIRS = 1;
            CSIRSMatrix = nrCSIRSMapping(pdsch);         %伪随机序列初始化为了1！！！！       %CSIRS的位置
            RSMapMatrix = nrPDSCHRSMapMatrixWithCSIRS(DMRSMatrix,CSIRSMatrix,pdsch.PdcchSymbolsLocation);   %#OK   %有CSIRS时的资源网格
            [DMRSLocation,DataLocation] = nrGetRSDataLocation(RSMapMatrix);               %#OK        %有CSIRS时的DMRS位置和数据位置
            CSIRSLocation = nrGetCSIRSLocation(CSIRSMatrix);                              %#OK        %CSIRS的位置
            [RhhDMRS,RdhDMRS] = nrCalRhhRdh(DMRSLocation,DataLocation,channel);  %#OK                 %有CSIRS时的DMRS和Data相关矩阵
            [RhhCSIRS,RdhCSIRS]=nrCalRhhRdh(CSIRSLocation,DataLocation,channel); %#OK                 %CSIRS和Data的相关矩阵
            pdsch.pdschIndices = nrPDSCHIndices(RSMapMatrix);  %#OK                                         %有CSIRS时的数据位置
         else
            WithCSIRS = 0;
            RSMapMatrix = nrPDSCHRSMapMatrix(DMRSMatrix, pdsch.PdcchSymbolsLocation);  %#OK   %无CSIRS时的资源网格
            [DMRSLocation,DataLocation] = nrGetRSDataLocation(RSMapMatrix);     %#OK          %无CSIRS时的DMRS位置和数据位置
            [RhhDMRS,RdhDMRS] = nrCalRhhRdh(DMRSLocation,DataLocation,channel);       %#OK           %无CSIRS时的DMRS和Data相关矩阵
            pdsch.pdschIndices = nrPDSCHIndices(RSMapMatrix);  %#OK                           %无CSIRS时的数据位置
         end
        
         %%   ----------- transport block scheduling -------------%%
         for cwInd = 1:pdsch.TBNum
             if  harqProcesses(harqProcIdx).RVIdx(cwInd) == 1
                 [harqProcesses(harqProcIdx).data{cwInd},harqProcesses(harqProcIdx).modu(cwInd),harqProcesses(harqProcIdx).R(cwInd),harqProcesses(harqProcIdx).TbLength(cwInd)] = nrCWScheduling(CqiIndex(cwInd),pdsch.LayerNum(cwInd),pdsch);
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
        codedTrBlkSizes = CalCWCodeLength(length(pdsch.pdschIndices), modu, pdsch.Rank);  %  根据有无CSIRS判断传入参数！！
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
            % Get data length after rate matching for each cb
            codedCbBlkSizes = CalCBCodeLength(codedTrBlkSizes(i),cbNum);      %#OK
            % Channel coding
            coded = nrLDPCEncode(segmented, bgSign);                          %#OK
            % Rate matching and codeblock combine
            cw{i} = nrRateMatchLDPC(coded,cbssize{i},codedCbBlkSizes,pdsch.RV(i),bgSign(i),modu(i));     %#OK       iLBRM的取值？？？
        end
        
        
        
        %% ---------- PDSCH complex symbols generation ---------- %%
        scrambled = cell(1,ncw);
        modulated = cell(1,ncw);
        for i = 1:ncw
            % Scrambling
            scramblingSeq = nrScrambling(gnb.NCellID,pdsch.RNTI,i-1,size(cw{i},1));%s %#OK
            scrambled{i} = xor(cw{i},scramblingSeq.');
            scrambled{i} = cw{i};             %test code!!!
            % Modulation
            modulated{i} = nrSymbolModulate(scrambled{i},modu(i)); %#OK
        end
        % Layer mapping
        layered = nrLayerMap(pdsch.Rank,modulated); %#OK        是否要返回每层的调制阶数？？
        % codebook select
        if pdsch.CodebookBased == 1
            if pdsch.PortCSIRS==1
                CodebookIndex=1;
            end
            PrecodingMatrix= pdsch.CodebookTotal(:,(CodebookIndex-1)*pdsch.Rank+1:CodebookIndex*pdsch.Rank);
        else
            PrecodingMatrix= CodebookEst;
        end
        % Data Precoding
        symbols = nrDLPrecode(PrecodingMatrix,layered); % codebook的确定!!!
        % DMRS Precoding
        DMRSMatrixAfterPrecode = nrDLPrecodeDMRS(PrecodingMatrix,DMRSMatrix); % codebook的确定
        % Resource Mapping
        pdschGrid = nrResourceMapping(symbols,DMRSMatrixAfterPrecode,RSMapMatrix,pdsch,WithCSIRS,CSIRSMatrix);      %  #OK
        % OFDM modulation of associated resource elements
        txWaveform = nrOFDMModulate(gnb, pdsch, pdschGrid);      %#OK
        
        
        
        %% ---------- Pass data through channel model -------------%%
        % Generate  channel
        H=GenerateChannel(nslot,channel);                       %#OK
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
        %CSI-RS receive 
        if WithCSIRS == 1
              CsirsH = nrDeChannelCSIRS(rxWaveform,pdsch.RowIndex,CSIRSMatrix,pdsch);
              %CSIRS信道估计
              HCsirsEst = nrChannelEstimation(CsirsH,modu(1),RhhCSIRS,RdhCSIRS,SNR^2,ue.RxAntNum);
               if mod(nslot+1-(RVIdx-1)*pdsch.NHARQProcesses,pdsch.CQIPeriod) == pdsch.CSIRSSlotOffset+1   
                   %CSIRS MIMO联合检测
                  MMSESinrCSIRS = nrMMSEDetectorMIMOCsirs(HCsirsEst, SNR^2,pdsch.Rank,PrecodingMatrix,ue.RxAntNum);
                  DeLayerSinrCSIRS = nrDeLayerMap(MMSESinrCSIRS);
                  % EESM合并  对每个CW分别进行，由于他们的长度不同,缺少256QAM调制的beita
                  CodeRateUe = harqProcesses(harqProcIdx).TbLength./modu.'./pdsch.LayerNum/length(pdsch.pdschIndices);
                  SINROutCsirs = nrEESM(DeLayerSinrCSIRS,CodeRateUe,modu,modulated);
                  % CQI反馈阶数 应该对每个CW分别进行！！！！
                  CqiIndexEst=nrCQIFeedback(10*log10(SINROutCsirs));
               end                                                       
              if pdsch.CodebookBased==1
                   if mod(nslot+1-(RVIdx-1)*pdsch.NHARQProcesses,pdsch.PMIPeriod) == pdsch.CSIRSSlotOffset+1  
                      HCsirsEstMean = mean(HCsirsEst,2);
                      HMean = (reshape(HCsirsEstMean,pdsch.PortCSIRS,ue.RxAntNum)).';
                      %码本选择
                      CodebookIndexEst =nrCodeBookSelect(HMean,pdsch.CodebookTotal,pdsch);
                   end
              end
        end
              
        %OFDM Demodulate
        rxGrid = nrOFDMDemodulate(pdsch,rxWaveform);   %#OK
        %Resource Element Demapping
        [rxData,rxDMRS] = nrDeResourceMapping(rxGrid,DMRSMatrix,RSMapMatrix,CDMGroupMap);     %#OK
        
        if pdsch.IdealChanEstEnabled== 1                                 %%not finished!!!
            % Ideal channel estimation
            HIdeal = nrPerfectChannelEstimate(pdsch,channel,H);
            % Ideal channel MMSE detection
            [ MMSESymbols, MMSESinr ] = nrMMSEDetectorMIMO( rxData, HIdeal, SNR^2,pdsch.Rank);
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
            scramblingSeq = nrScrambling(gnb.NCellID,pdsch.RNTI,i-1,size(demodulated{i},1)) ;      %#OK
            scramblingSeq2 = 1-2*scramblingSeq;
            dlschBits{i} = demodulated{i}.*scramblingSeq2.';
            dlschBits{i} = demodulated{i};
        end
        
        
        
        %% ----------  transport channel decoding ---------- %%
        for i = 1:ncw
            RVIdx = harqProcesses(harqProcIdx).RVIdx(i);
            % Rate recovery
            codedCbBlkSizes = CalCBCodeLength(codedTrBlkSizes(i),cbNum);
            % raterecovered = nrRateDematcher(dlschBits{i},cbssize{i},codedCbBlkSizes,pdsch.RVSeq(RVIdx),harqProcesses(harqProcIdx).decState(i).CBSBuffers,pdsch.Modulation);  %#OK
            [raterecovered,harqProcesses(harqProcIdx).decState(i).CBSBuffers] = nrRateDematcher(dlschBits{i},cbssize{i},codedCbBlkSizes,pdsch.RVSeq(RVIdx),harqProcesses(harqProcIdx).decState(i).CBSBuffers,modu(i));
            % Channel decoding
            decoded = nrLDPCDecode(raterecovered,cbssize{i},codedCbBlkSizes);       %#OK
            % Code block desegmentation and code block CRC decoding
            [desegmented,harqProcesses(harqProcIdx).decState(i).CBSCRC] = nrCodeBlockDesegmentLDPC(decoded);          %#OK
            % Transport block CRC decoding
            [out,harqProcesses(harqProcIdx).decState(i).BLKCRC] = nrCRCDecode(desegmented,length(trdata{i}));         %#OK
            % block num statistics
            simStatistics{snrIdx}.BlkErrNum = simStatistics{snrIdx}.BlkErrNum + harqProcesses(harqProcIdx).decState(i).BLKCRC;
            if RVIdx == length(pdsch.RVSeq)  && harqProcesses(harqProcIdx).decState(i).BLKCRC==1
                CqiIndex(i) = max(1,CqiIndex(i)-1);
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
toc;
 %profile viewer;
% p = profile('info');
% profsave(p,'profile_results_CDL') % 保存profile 结果