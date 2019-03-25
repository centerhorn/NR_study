%% ���ݸ�����ԴԪ���ϵ�DmrsSymMatrix�����DMRS�˿ڵ�pilot�ŵ�����
function PilotH = DecodeDMRS(PilotSymOut,CDMGroupNum,DMRS_MAP)
SubcarrierNum = size(DMRS_MAP,1);
PilotLen = length(PilotSymOut);%DMRS�����г���
SubcarrierDmrs = SubcarrierNum/2;%DMRS�����ز����������˿�1/2
SymbolDmrs = PilotLen/SubcarrierDmrs;%DMRS�ķ��Ÿ���
CDMMatrix = [1 1;1 -1];
switch CDMGroupNum
    case 1
        %% CDMGroupNum == 1
        PilotH = PilotSymOut;
    case 2
        %% CDMGroupNum == 2
        CDMLen = PilotLen/2;
        PilotGroup = reshape(PilotSymOut,2,CDMLen);
        for CDMInd = 1:CDMLen
            Htemp = 1/2*CDMMatrix*PilotGroup(:,CDMInd);
            PilotH1(1:2,CDMInd) = Htemp(1);
            PilotH2(1:2,CDMInd) = Htemp(2);
        end
        PilotH = [reshape(PilotH1,1,PilotLen);reshape(PilotH2,1,PilotLen)];
    case 3
        %% CDMGroupNum == 3
        PilotH = [];
        TimeGroup = SymbolDmrs/2;%ʱ�����ж��ٸ�˫����
        for TimeGroupInd = 1:TimeGroup
            CDMLen = SubcarrierDmrs/2;
            PilotGroupTemp = [PilotSymOut(((TimeGroupInd-1)*2*SubcarrierDmrs+1):((TimeGroupInd-1)*2*SubcarrierDmrs+SubcarrierDmrs)); ...
                PilotSymOut(((TimeGroupInd-1)*2*SubcarrierDmrs+SubcarrierDmrs+1):(TimeGroupInd*2*SubcarrierDmrs))];
            PilotGroup = reshape(PilotGroupTemp,4,CDMLen);
            for CDMInd = 1:CDMLen
                CDMTempMat = (reshape(PilotGroup(:,CDMInd),2,2)).';
                Htemp = 1/2*CDMMatrix*CDMTempMat;
                PilotH1(1:2,(2*CDMInd-1):2*CDMInd) = 1/2*(Htemp(1)+Htemp(3));
                PilotH2(1:2,(2*CDMInd-1):2*CDMInd) = Htemp(2);
                PilotH3(1:2,(2*CDMInd-1):2*CDMInd) = 1/2*(Htemp(1)-Htemp(3));
            end
            PilotHTem = [PilotH1(1,:),PilotH1(2,:);PilotH2(1,:),PilotH2(2,:);PilotH3(1,:),PilotH3(2,:)];
            PilotH = [PilotH,PilotHTem];
        end
    case 4
        %% CDMGroupNum == 4
        PilotH = [];
        TimeGroup = SymbolDmrs/2;%ʱ�����ж��ٸ�˫����
        for TimeGroupInd = 1:TimeGroup
            CDMLen = SubcarrierDmrs/2;
            PilotGroupTemp = [PilotSymOut(((TimeGroupInd-1)*2*SubcarrierDmrs+1):((TimeGroupInd-1)*2*SubcarrierDmrs+SubcarrierDmrs)); ...
                PilotSymOut(((TimeGroupInd-1)*2*SubcarrierDmrs+SubcarrierDmrs+1):(TimeGroupInd*2*SubcarrierDmrs))];
            PilotGroup = reshape(PilotGroupTemp,4,CDMLen);
            for CDMInd = 1:CDMLen
                CDMTempMat = (reshape(PilotGroup(:,CDMInd),2,2)).';
                Htemp1 = 1/2*CDMMatrix*CDMTempMat;
                Htemp = 1/2*CDMMatrix*Htemp1.';
                PilotH1(1:2,(2*CDMInd-1):2*CDMInd) = Htemp(1);
                PilotH2(1:2,(2*CDMInd-1):2*CDMInd) = Htemp(3);
                PilotH3(1:2,(2*CDMInd-1):2*CDMInd) = Htemp(2);
                PilotH4(1:2,(2*CDMInd-1):2*CDMInd) = Htemp(4);
            end
            PilotHTem = [PilotH1(1,:),PilotH1(2,:);PilotH2(1,:),PilotH2(2,:);PilotH3(1,:),PilotH3(2,:);PilotH4(1,:),PilotH4(2,:)];
            PilotH = [PilotH,PilotHTem];
        end
end
end
