%% Function Description
%  PDSCH AMC
%% Input
%  MCSIndex:      double
%                 MCS index
%  LayerNum:      double
%                 layer nums for a cw
%  pdschConfig:   structure
%                 Configuration information for pdsch
%% Output
%  TBS:           double
%                 size of a TB block
%  QmF:           doulbe
%                 Modulation order
%  RF:            doulbe
%                 Rate
%% Modify History
%  2018/05/29 modified by Song Erhao 

function [TBS,QmF,RF] = nrAMC(MCSIndex,LayerNum,pdschConfig)
DATA_NUM=length(pdschConfig.pdschIndices);
RB_NUM =pdschConfig.NDLRB ;
DataNumPerRB = floor(DATA_NUM/RB_NUM);
SET_256QAM = pdschConfig.Enable256QAM;
%% 固定参数
% CQI_SE_Table
CQISETableWithout256 = [0.1523	0.2344	0.377	0.6016	0.877	1.1758	1.4766	1.9141	2.4063	2.7305	3.3223	3.9023	4.5234	5.1152	5.5547];
CQISETableWith256 = [0.1523	0.377	0.877	1.4766	1.9141	2.4063	2.7305	3.3223	3.9023	4.5234	5.1152	5.5547	6.2266	6.9141	7.4063];
% 第一行是调制阶数，第二行是与之对应的code rate，第三行是频谱效率
MCSTablePDSCHWithout256 = [2	2	2	2	2	2	2	2	2	2	4	4	4	4	4	4	4	6	6	6	6	6	6	6	6	6	6	6	6;
                           120	157	193	251	308	379	449	526	602	679	340	378	434	490	553	616	658	438	466	517	567	616	666	719	772	822	873	910	948;
                           0.2344 0.3066 0.3770	0.4902	0.6016	0.7402 0.8770	1.0273 1.1758 1.3262	1.3281	1.4766	1.6953 1.9141 2.1602 2.4063	 2.5703 2.5664	2.7305	3.0293	 3.3223  3.6094	3.9023	4.2129	 4.5234 4.8164	 5.1152	5.3320 5.5547];

MCSTablePDSCHWith256 = [2	2	2	2	2	4	4	4	4	4	4	6	6	6	6	6	6	6	6	6	8	8	8	8	8	8	8	8;
                        120	193	308	449	602	378	434	490	553	616	658	466	517	567	616	666	719	772	822	873	682.5	711	754	797	841	885	916.5	948;
                        0.2344	0.377	0.6016	0.877	1.1758	1.4766	1.6953	1.9141	2.1602	2.4063	2.5703	2.7305	3.0293	3.3223	3.6094	3.9023	4.2129	4.5234	4.8164	5.1152	5.332	5.5547	5.8906	6.2266	6.5703	6.9141	7.1602	7.4063];

MCSTablePDSCHWith256(2,:) = MCSTablePDSCHWith256(2,:)/1024;%code rate以1024为单位
MCSTablePDSCHWithout256(2,:) = MCSTablePDSCHWithout256(2,:)/1024;%code rate以1024为单位
%量化可用RE矩阵
QuantizedREMatrix = [6*ones(1,9),12*ones(1,6),18*ones(1,15),42*ones(1,27),72*ones(1,33),108*ones(1,36),144*ones(1,24),156*ones(1,18)];
%TBS表(NInfo<=3824)
TBSTableLess3824 = [24	32	40	48	56	64	72	80	88	96	104	112	120	128	136	144	152	160	168	176	184	192	208	224	240	256	272	288	304	320 ...
                    336	352	368	384	408	432	456	480	504	528	552	576	608	640	672	704	736	768	808	848	888	928	984	1032	1064	1128	1160	1192	1224	1256 ...
                    1288	1320	1352	1416	1480	1544	1608	1672	1736	1800	1864	1928	2024	2088	2152	2216	2280	2408	2472	2536	2600	2664	2728	2792	2856	2976	3104	3240	3368	3496 ...
                    3624 3752 3824];

%% 初始化参数
if SET_256QAM==0
    MCSTablePDSCH = MCSTablePDSCHWithout256;
    CQISETable = CQISETableWithout256;
elseif SET_256QAM==1
    MCSTablePDSCH = MCSTablePDSCHWith256;
    CQISETable = CQISETableWith256;
end
%% 确定每一阶MCS相对应的TBS

R = MCSTablePDSCH(2,MCSIndex);
Qm = MCSTablePDSCH(1,MCSIndex);

%% 程序
QuantizedRE = QuantizedREMatrix(DataNumPerRB);
TotalRE = QuantizedRE*RB_NUM;
NInfo = TotalRE*R*Qm*LayerNum;

if NInfo<=3824
    n = max(3,floor(log2(NInfo))-6);
    NInfoTemp = max(24,2^n*floor(NInfo/2^n));
    TempIndex = min(find(TBSTableLess3824>=NInfoTemp));
    TBSTemp = TBSTableLess3824(TempIndex);
else
    n = floor(log2(NInfo-24))-5;
    NInfoTemp = 2^n*round((NInfo-24)/2^n);
    if R<=1/4
       C = ceil((NInfoTemp+24)/3816);
       TBSTemp = 8*C*ceil((NInfoTemp+24)/8/C)-24; 
    else
        if NInfoTemp>8424
            C = ceil((NInfoTemp+24)/8424);
            TBSTemp = 8*C*ceil((NInfoTemp+24)/8/C)-24;   
        else
            TBSTemp  = 8*ceil((NInfoTemp+24)/8)-24;
        end
    end 
end

RF = MCSTablePDSCH(2,MCSIndex);
QmF = MCSTablePDSCH(1,MCSIndex);
TBS = TBSTemp;
end