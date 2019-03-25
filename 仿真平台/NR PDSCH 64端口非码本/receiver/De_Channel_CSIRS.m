%% 函数功能
% 获得CSI-RS的信道增益，参考3GPP TS38.211 7.4.1节
%% 输入参数
% ROW_INDEX：CSI-RS的配置行，注意协议中没有行数为6的情况，但本平台包含6，没有19
% DataIn：经过信道后的数据流
%% 输出参数
% CsirsH：各端口CSIRS的信道增益
%% Modified history
% 2018/1/17 created by Liu Chunhua 
%% Coding
function CsirsH = De_Channel_CSIRS(DataIn,ROW_INDEX,CSIRS_MAP,PORT_CSIRS,pdschConfig)
switch ROW_INDEX
    case {1 2}
        %% ROW_INDEX为1 2，No CDM
        PilotSymOut = Deofdm_Modulation_CSIRS(DataIn,CSIRS_MAP(:,:,1));
        CsirsH = PilotSymOut;
    case {3 4 5 6 7 9 11 13 16}
        %% ROW_INDEX为3 4 5 6 7 9 11 13 16，FD-CDM2
        CDMMatrix = [1 1;1 -1];
        for CMDGInd = 1:PORT_CSIRS/2
            %PilotSymOut = Deofdm_Modulation_CSIRS(DataIn,CSIRS_MAP(:,:,CMDGInd));
            PilotSymOut = Deofdm_Modulation_CSIRS(DataIn,CSIRS_MAP(:,:,CMDGInd),pdschConfig);
            PilotLen = length(PilotSymOut);
            CDMLen = PilotLen/2;
            PilotGroup = reshape(PilotSymOut,2,CDMLen);
            for CDMInd = 1:CDMLen
                Htemp = 1/2*CDMMatrix*PilotGroup(:,CDMInd);
                PilotH1(1:2,CDMInd) = Htemp(1);
                PilotH2(1:2,CDMInd) = Htemp(2);
            end
            CsirsH(CMDGInd,:) = reshape(PilotH1,1,PilotLen);
            CsirsH(CMDGInd+PORT_CSIRS/2,:) = reshape(PilotH2,1,PilotLen);
        end
    case {8 10 12 14 17}
        %% ROW_INDEX为8 10 12 14 17，CDM4 (FD2,TD2)
        CDMMatrix = [1 1;1 -1];
        for CMDGInd = 1:PORT_CSIRS/4
            PilotSymOut = Deofdm_Modulation_CSIRS(DataIn,CSIRS_MAP(:,:,CMDGInd),pdschConfig);
            PilotLen = length(PilotSymOut);
            CDMLen = PilotLen/4;
            PilotGroupTemp = [PilotSymOut(1:PilotLen/2).',PilotSymOut((PilotLen/2+1):PilotLen).'];
            for CDMInd = 1:CDMLen
                CDMTempMat = PilotGroupTemp(((CDMInd-1)*2+1):(CDMInd*2),:);
                Htemp1 = 1/2*CDMMatrix*CDMTempMat;
                Htemp = 1/2*CDMMatrix*Htemp1.';
                PilotH1((2*CDMInd-1):2*CDMInd,1:2) = Htemp(1);
                PilotH2((2*CDMInd-1):2*CDMInd,1:2) = Htemp(3);
                PilotH3((2*CDMInd-1):2*CDMInd,1:2) = Htemp(2);
                PilotH4((2*CDMInd-1):2*CDMInd,1:2) = Htemp(4);
            end
            CsirsH(CMDGInd,:) = reshape(PilotH1,1,PilotLen);
            CsirsH(CMDGInd+PORT_CSIRS/4,:) = reshape(PilotH2,1,PilotLen);
            CsirsH(CMDGInd+PORT_CSIRS/2,:) = reshape(PilotH3,1,PilotLen);
            CsirsH(CMDGInd+3*PORT_CSIRS/4,:) = reshape(PilotH4,1,PilotLen);
        end
    case {15 18}
        %% ROW_INDEX为15 18，CDM8 (FD2,TD4)
        CDMMatrix2 = [1 1;1 -1];
        CDMMatrix4 = [1 1 1 1;1 -1 1 -1;1 1 -1 -1;1 -1 -1 1];
        for CMDGInd = 1:PORT_CSIRS/8
            PilotSymOut = Deofdm_Modulation_CSIRS(DataIn,CSIRS_MAP(:,:,CMDGInd),pdschConfig);
            PilotLen = length(PilotSymOut);
            CDMLen = PilotLen/8;
            PilotGroupTemp = [PilotSymOut(1:PilotLen/4).',PilotSymOut((PilotLen/4+1):PilotLen/2).',...
               PilotSymOut((PilotLen/2+1):(3*PilotLen/4)).',PilotSymOut((3*PilotLen/4+1):PilotLen).' ];
            for CDMInd = 1:CDMLen
                CDMTempMat = PilotGroupTemp(((CDMInd-1)*2+1):(CDMInd*2),:);
                Htemp1 = 1/4*CDMTempMat*CDMMatrix4;
                Htemp = 1/2*CDMMatrix2*Htemp1;
                PilotH1((2*CDMInd-1):2*CDMInd,1:2) = Htemp(1);
                PilotH2((2*CDMInd-1):2*CDMInd,1:2) = Htemp(2);
                PilotH3((2*CDMInd-1):2*CDMInd,1:2) = Htemp(3);
                PilotH4((2*CDMInd-1):2*CDMInd,1:2) = Htemp(4);
                PilotH5((2*CDMInd-1):2*CDMInd,1:2) = Htemp(5);
                PilotH6((2*CDMInd-1):2*CDMInd,1:2) = Htemp(6);
                PilotH7((2*CDMInd-1):2*CDMInd,1:2) = Htemp(7);
                PilotH8((2*CDMInd-1):2*CDMInd,1:2) = Htemp(8);        
            end
            CsirsH(CMDGInd,:) = reshape(PilotH1,1,PilotLen);
            CsirsH(CMDGInd+PORT_CSIRS/8,:) = reshape(PilotH2,1,PilotLen);
            CsirsH(CMDGInd+2*PORT_CSIRS/8,:) = reshape(PilotH3,1,PilotLen);
            CsirsH(CMDGInd+3*PORT_CSIRS/8,:) = reshape(PilotH4,1,PilotLen);
            CsirsH(CMDGInd+4*PORT_CSIRS/8,:) = reshape(PilotH5,1,PilotLen);
            CsirsH(CMDGInd+5*PORT_CSIRS/8,:) = reshape(PilotH6,1,PilotLen);    
            CsirsH(CMDGInd+6*PORT_CSIRS/8,:) = reshape(PilotH7,1,PilotLen);
            CsirsH(CMDGInd+7*PORT_CSIRS/8,:) = reshape(PilotH8,1,PilotLen);       
        end
end
end