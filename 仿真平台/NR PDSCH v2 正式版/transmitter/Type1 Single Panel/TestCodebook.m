clc;clear all;
PortCSIRS = 32;
LayerNum = 8;
if PortCSIRS >2
    CodebookMode = 1;
    N1N2Conf = [2 2 4 3 6 4 8 4 6 12 4 8 16;1 2 1 2 1 2 1 3 2 1 4 2 1];
    O1O2Conf = [4*ones(1,13);1 4 1 4 1 4 1 4 4 1 4 4 1];
    PCSIRSConf = [4 8 8 12 12 16 16 24 24 24 32 32 32];
    IndTemp = find(PCSIRSConf==PortCSIRS);
    IndT = IndTemp(1);

    ON12 = [O1O2Conf(1,IndT),O1O2Conf(2,IndT),N1N2Conf(1,IndT),N1N2Conf(2,IndT)];
    CodeBookTotal=Type1_SinglePanel_Codebook(PortCSIRS,LayerNum,CodebookMode,ON12);
else
    CodeBookTotal=Type1_SinglePanel_Codebook(PortCSIRS,LayerNum,0,zeros(1,4));
end

% CodeBookTotal=Type1_SinglePanel_Codebook(PortCSIRS,LayerNum,CodebookMode,ON12);
CodeBookNum = size(CodeBookTotal,2)/LayerNum