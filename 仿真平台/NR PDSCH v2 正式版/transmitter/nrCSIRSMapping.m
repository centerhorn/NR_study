%% Function Description
%  form resource mapping matrix for DMRS，CSIRS,Data,PDCCH    
%% Input
%  pdschConfig :  Structure.
%                 Configuration information for PDSCH
%% Output
%  CSIRSMap :     3-Dimensional array (subcarrier-symbol-Port).
%                 CSIRS sequence mapping for all Ports.
%% Modify History
%  2018/05/29 created by Song Erhao
%%

function CSIRSMap= nrCSIRSMapping(pdschConfig)
%% 初始化参数
PORT_CSIRS  = pdschConfig.PortCSIRS;
DENSITY = pdschConfig.Density;
SYMBOL_PER_SUBFRAME = pdschConfig.SymbolsPerSlot;
SUBCARRIER_PER_RB = pdschConfig.SubcarriersPerRB;
BETA_CSIRS = pdschConfig.BetaCSIRS;
L0_CSIRS = pdschConfig.L0CSIRS ;%configured by the higher-layer parameter CSI-RS-ResourceMapping.
L1_CSIRS = pdschConfig.L1CSIRS;
RBNum = pdschConfig.NDLRB;
RowInd = pdschConfig.RowIndex;
r = ones(1,RBNum*3);
SubcarrierNum = SUBCARRIER_PER_RB*RBNum;

%% 端口个数与Row的选择
rowPorts = [(1:18);1 1 2 4 4 8 8 8 12 12 16 16 24 24 24 32 32 32];
if rowPorts(2,RowInd)~=PORT_CSIRS
    display(['PortNum does not match RowInd!']);
end
%% 确定ki
if RowInd==1
%     k0 = randi([0 3],1,1);
    k0 = 0;
elseif RowInd==2
%     k0 = randi([0 11],1,1);
    k0 = 0;
elseif RowInd==4
%     k0 = 4*randi([0 3],1,1);
    k0 = 4*0;
else
    k0 = 0;
    k1 = 2;
    k2 = 4;
    k3 = 6;
    k4 = 8;
    k5 = 10;
end

%% 确定kTemp
if RowInd<=2
    kTemp = 0;
else
    kTemp = [0 1];
end
%% 确定lTemp
if RowInd<=7 || RowInd==9 || RowInd==11 || RowInd==13 || RowInd==16
    lTemp = 0;
elseif RowInd==8 || RowInd==10 || RowInd==12 || RowInd==14 || RowInd==17
    lTemp = [0 1];
elseif RowInd==15 || RowInd==18
    lTemp = [0 1 2 3];
end
%% 确定密度
if RowInd==1
    densityTemp = 1;%3在kQuantlQuant中已经体现出来了
elseif RowInd==2 || RowInd==3 || (RowInd>=11 && RowInd<=18)
    densityTemp = [1,0.5];
elseif RowInd>=4 && RowInd<=10
    densityTemp = 1;
end

if isempty(find(densityTemp==DENSITY))
    display(['density does not match RowInd!']);
end

%% 确定kQuantLQuant
switch RowInd
    case 1
        kQuantLQuant = [k0,k0+4,k0+8;L0_CSIRS,L0_CSIRS,L0_CSIRS];
    case 2
        kQuantLQuant = [k0;L0_CSIRS];
    case 3
        kQuantLQuant = [k0;L0_CSIRS];
    case 4
        kQuantLQuant = [k0,k0+2;L0_CSIRS,L0_CSIRS];
    case 5
        kQuantLQuant = [k0,k0;L0_CSIRS,L0_CSIRS+1];
    case 6
        kQuantLQuant = [k0,k1,k2,k3;L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS];
    case 7
        kQuantLQuant = [k0,k1,k0,k1;L0_CSIRS,L0_CSIRS,L0_CSIRS+1,L0_CSIRS+1];
    case 8
        kQuantLQuant = [k0,k1;L0_CSIRS,L0_CSIRS];
    case 9
        kQuantLQuant = [k0,k1,k2,k3,k4,k5;L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS];
    case 10    
        kQuantLQuant = [k0,k1,k2;L0_CSIRS,L0_CSIRS,L0_CSIRS];
    case 11
        kQuantLQuant = [k0,k1,k2,k3,k0,k1,k2,k3;L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS+1,L0_CSIRS+1,L0_CSIRS+1,L0_CSIRS+1];
    case 12
        kQuantLQuant = [k0,k1,k2,k3;L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS];
    case 13    
        kQuantLQuant = [k0,k1,k2,k0,k1,k2,k0,k1,k2,k0,k1,k2;L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS+1,L0_CSIRS+1,L0_CSIRS+1,L1_CSIRS,L1_CSIRS,L1_CSIRS,L1_CSIRS+1,L1_CSIRS+1,L1_CSIRS+1];
    case 14    
        kQuantLQuant = [k0,k1,k2,k0,k1,k2;L0_CSIRS,L0_CSIRS,L0_CSIRS,L1_CSIRS,L1_CSIRS,L1_CSIRS];
    case 15
        kQuantLQuant = [k0,k1,k2;L0_CSIRS,L0_CSIRS,L0_CSIRS];
    case 16
        kQuantLQuant = [k0,k1,k2,k3,k0,k1,k2,k3,k0,k1,k2,k3,k0,k1,k2,k3; ...
            L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS+1,L0_CSIRS+1,L0_CSIRS+1,L0_CSIRS+1,L1_CSIRS,L1_CSIRS,L1_CSIRS,L1_CSIRS,L1_CSIRS+1,L1_CSIRS+1,L1_CSIRS+1,L1_CSIRS+1];
    case 17
        kQuantLQuant = [k0,k1,k2,k3,k0,k1,k2,k3;L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS,L1_CSIRS,L1_CSIRS,L1_CSIRS,L1_CSIRS];
    case 18    
        kQuantLQuant = [k0,k1,k2,k3;L0_CSIRS,L0_CSIRS,L0_CSIRS,L0_CSIRS];        
end
%% 确定WfkTemp 、 WtlTemp
if RowInd<=2 %NO CDM
    WfkTemp = 1;
    WtlTemp = 1;
    LayerNum =  1;
elseif (RowInd>2 && RowInd<8) ||  RowInd==9 || RowInd==11 || RowInd==13 || RowInd==16%FD-CDM2
    WfkTemp = [1 1;1 -1];%行代表kTemp，列是index对应端口
    WtlTemp = [1 1];
    LayerNum =  2;
elseif RowInd==8 || RowInd==10 || RowInd==12 || RowInd==14 || RowInd==17 %CDM4
    WfkTemp = [ones(1,4);1 -1 1 -1];
    WtlTemp = [ones(1,4);1 1 -1 -1];
    LayerNum =  4;
elseif RowInd==15 || RowInd==18 %CDM8
    WfkTemp = [ones(1,8);1 -1 1 -1 1 -1 1 -1];
    WtlTemp = [ones(1,8);1 1 -1 -1 1 1 -1 -1;ones(1,4),-1*ones(1,4);1 1 -1 -1 -1 -1 1 1];
    LayerNum =  8;
end

%% 计算各个数组的长度
kTempLen = length(kTemp);
lQuantLen = size(kQuantLQuant,2);
lTempLen = length(lTemp);
a = zeros(SUBCARRIER_PER_RB,SYMBOL_PER_SUBFRAME,PORT_CSIRS);
CSIRSMapping = zeros(SubcarrierNum,SYMBOL_PER_SUBFRAME,PORT_CSIRS);
m=0;
%% 计算各个位置上的CSI-RS sequence
while (m*SUBCARRIER_PER_RB/DENSITY+12)<=SubcarrierNum
    for p = 1:LayerNum
        for lTempInd = 1:lTempLen
            for  kTempInd = 1:kTempLen
                if RowInd~=1
                    for lQuantInd = 1:lQuantLen
                        L = kQuantLQuant(2,lQuantInd)+lTemp(lTempInd)+1;%协议里从0开始标号，所以程序需要加1
                        portTemp =  (p-1)*lQuantLen+ lQuantInd;                              
                        k = kQuantLQuant(1,lQuantInd)+kTemp(kTempInd)+1;                                                         
                        a(k,L,portTemp) = BETA_CSIRS*WfkTemp(kTemp(kTempInd)+1,p)*WtlTemp(lTemp(lTempInd)+1,p)*r(m+1);
                    end
                else
                    for lQuantInd = 1:lQuantLen
                        L = kQuantLQuant(2,lQuantInd)+lTemp(lTempInd)+1;%协议里从0开始标号，所以程序需要加1                         
                        k = kQuantLQuant(1,lQuantInd)+kTemp(kTempInd)+1;                                                         
                        a(k,L,1) = BETA_CSIRS*WfkTemp(kTemp(kTempInd)+1,p)*WtlTemp(lTemp(lTempInd)+1,p)*r(m+1);
                    end
                end
            end
        end
    end
    % 与密度有关
    CSIRSMapping((m*SUBCARRIER_PER_RB/DENSITY+1):(m*SUBCARRIER_PER_RB/DENSITY+12),:,:) = a;
    m = m+1;    
end
CSIRSMap = CSIRSMapping;
end