%% Function Description
%  PDSCH DMRS mapping to physical resources (refer to 3GPP TS38.211 Sec.7.4.1.1)
%% Input
%  gnbConfig：Structure.
%             Configuration information for gNB.
%  pdschConfig：Structure.
%               Configuration information for PDSCH.
%% Output
%  DMRSMatrixSet:cell array(RANK 1-4)
%                each cell:3-Dimensional array (subcarrier-symbol-rank).
%                          DMRS sequence mapping for all layers.
%  CDMGroupMapSet：cell array(RANK 1-4)
%                  each cell:CDM group for all active ports.
%% Modify History
%  2018/04/17 created by Liu Chunhua 
%  2018/04/23 modified by Li Yong
%  2018/04/25 modified by Li Yong
%%
function [DMRSMatrixSet, CDMGroupMapSet]= nrPDSCHDmrsMatrix(gnbConfig,pdschConfig)  
%% parameter initialization
PDSCH_SYMBOLS_PER_SLOT = length(pdschConfig.PdschSymbolsLocation);
RBNum = length(pdschConfig.PRBSet);
%RANK = pdschConfig.Rank;
RANKMax = 4;
PDSCH_DMRS_CONFIG_TYPE = pdschConfig.DmrsConfigType;
PDSCH_DMRS_MAPPING_TYPE = pdschConfig.DmrsMappingType;
DL_DMRS_TYPEA_POS = pdschConfig.DmrsTypeAPos;
DL_DMRS_TYPEB_POS = pdschConfig.DmrsTypeBPos;
DL_DMRS_ADD_POS = pdschConfig.DmrsAddPos;
BETA_DMRS = pdschConfig.betaDmrs;
SYMBOLS_PER_SLOT = pdschConfig.SymbolsPerSlot;
SUBCARRIERS_PER_RB = pdschConfig.SubcarriersPerRB;

%% 中间变量
SubcarrierNum = SUBCARRIERS_PER_RB*RBNum;
if PDSCH_DMRS_CONFIG_TYPE == 'type 1'
    nMax = SubcarrierNum/4-1;
elseif PDSCH_DMRS_CONFIG_TYPE == 'type 2'
    nMax = SubcarrierNum/6-1;
end
rLen = 2*(nMax+1);    % length of DMRS sequence
% r= ones(1,rLen);
%% determine lPrime (refer to Table 7.4.1.1.2-5)
if PDSCH_DMRS_CONFIG_TYPE == 'type 1'
    if RANKMax <= 4
        lPrime = [0];
        IsSingleSymbolDMRS = true;
    else
        lPrime = [0 1];
        IsSingleSymbolDMRS = false;
    end
elseif PDSCH_DMRS_CONFIG_TYPE == 'type 2'
    if RANKMax <= 6
        lPrime = [0];
        IsSingleSymbolDMRS = true;
    else
        lPrime = [0 1];
        IsSingleSymbolDMRS = false;
    end
end

%% determine lBar
if IsSingleSymbolDMRS == true    % refer to Table 7.4.1.1.2-3
    if PDSCH_DMRS_MAPPING_TYPE == 'type A'      % l is defined relative to the start of the slot
        L0 = DL_DMRS_TYPEA_POS;                 
        if DL_DMRS_ADD_POS == 0
            lBar = L0;
        elseif DL_DMRS_ADD_POS == 1
            if PDSCH_SYMBOLS_PER_SLOT == 9
                lBar = [L0,7];
            elseif PDSCH_SYMBOLS_PER_SLOT >= 10 && PDSCH_SYMBOLS_PER_SLOT <= 12
                lBar = [L0,9];
            elseif PDSCH_SYMBOLS_PER_SLOT >= 13 && PDSCH_SYMBOLS_PER_SLOT <= 14
                lBar = [L0,11];
            else
                error('Invalid DL-DMRS-add-pos parameter!');
            end
         elseif DL_DMRS_ADD_POS == 2
            if PDSCH_SYMBOLS_PER_SLOT >=10 && PDSCH_SYMBOLS_PER_SLOT <= 12
                lBar = [L0,6,9];
            elseif PDSCH_SYMBOLS_PER_SLOT >=13 && PDSCH_SYMBOLS_PER_SLOT <= 14
                lBar = [L0,7,11];
            else
                error('Invalid DL-DMRS-add-pos parameter!');
            end
        elseif DL_DMRS_ADD_POS == 3
            if PDSCH_SYMBOLS_PER_SLOT >= 12 && PDSCH_SYMBOLS_PER_SLOT <= 14
                lBar = [L0,5,8,11];
            else
                error('Invalid DL-DMRS-add-pos parameter!');
            end
        end
    elseif PDSCH_DMRS_MAPPING_TYPE == 'type B'    % l  is defined relative to the start of the scheduled PDSCH resources
        L0 = DL_DMRS_TYPEB_POS;
        if DL_DMRS_ADD_POS == 0
            lBar = L0;
        elseif DL_DMRS_ADD_POS == 1
            if PDSCH_SYMBOLS_PER_SLOT == 7
                lBar = [L0,4];
            else
                error('Invalid DL-DMRS-add-pos parameter!');
            end
        else
            error('Invalid DL-DMRS-add-pos parameter!');
        end
    end
elseif IsSingleSymbolDMRS == false        % refer to Table 7.4.1.1.2-4
    if PDSCH_DMRS_MAPPING_TYPE == 'type A'    % l is defined relative to the start of the slot
        L0 = DL_DMRS_TYPEA_POS;
        if DL_DMRS_ADD_POS == 0
            lBar = L0;
        elseif DL_DMRS_ADD_POS == 1
            if PDSCH_SYMBOLS_PER_SLOT >= 10 && PDSCH_SYMBOLS_PER_SLOT <= 12
                lBar = [L0,8];
            elseif PDSCH_SYMBOLS_PER_SLOT >= 13 && PDSCH_SYMBOLS_PER_SLOT <= 14
                lBar = [L0,10];
            else
                error('Invalid DL-DMRS-add-pos parameter!');
            end
        else
            error('Invalid DL-DMRS-add-pos parameter!');
        end
    elseif PDSCH_DMRS_MAPPING_TYPE == 'type B'    % l  is defined relative to the start of the scheduled PDSCH resources
        L0 = DL_DMRS_TYPEB_POS;
        if DL_DMRS_ADD_POS == 0
            lBar = L0;
        else
            error('Invalid DL-DMRS-add-pos parameter!');
        end
    end
end

%% PDSCH DMRS Configuration Type
if PDSCH_DMRS_CONFIG_TYPE == 'type 1'        % refer to Table 7.4.1.1.2-1
    port = [1000 1000 1001 1001 1000 1000 1001 1001];     
    CDMGroup = [0 0 1 1 0 0 1 1];
    delta = [0 0 1 1 0 0 1 1];
    WfkTemp = [ones(1,8);1 -1 1 -1 1 -1 1 -1];
    WtlTemp = [ones(1,8);1 1 1 1 -1 -1 -1 -1];
elseif PDSCH_DMRS_CONFIG_TYPE == 'type 2'    % refer to Table 7.4.1.1.2-2
    port = [1000 1000 1001 1001 1002 1002 1000 1000 1001 1001 1002 1002];  
    CDMGroup = [0 0 1 1 2 2 0 0 1 1 2 2];
    delta = [0 0 2 2 4 4 0 0 2 2 4 4];
    WfkTemp = [ones(1,12);1 -1 1 -1 1 -1 1 -1 1 -1 1 -1];
    WtlTemp = [ones(1,12);1 1 1 1 1 1 -1 -1 -1 -1 -1 -1];
end
 DMRSMatrix = zeros(SubcarrierNum,SYMBOLS_PER_SLOT,RANKMax);
 DMRSMatrixSet = cell(1,RANKMax);
 CDMGroupMapSet = cell(1,RANKMax);
%% 计算各个数组的长度
kPrime = [0,1];
kPrimeLen = length(kPrime);
lPrimeLen = length(lPrime);
lBarLen = length(lBar);

%% 计算各个位置上的DMRS sequence
for lBarInd = 1:lBarLen
    for lPrimeInd = 1:lPrimeLen
        if PDSCH_DMRS_MAPPING_TYPE == 'type A'       % l is defined relative to the start of the slot
            L = lBar(lBarInd)+lPrime(lPrimeInd)+1;   % OFDM symbols are indexed from 0 while matlab array elements are indexed from 1
        elseif PDSCH_DMRS_MAPPING_TYPE == 'type B'   % l  is defined relative to the start of the scheduled PDSCH resources
            L = pdschConfig.PdschSymbolsPerSlot(1)+lBar(lBarInd)+lPrime(lPrimeInd)+1;
        end
          r = nrPdschDmrs(rLen, gnbConfig.NSlot, gnbConfig.NCellID, L-1);  % the last argument is the OFDM symbol number within the slot
         for p = 1:RANKMax        
            for n=0:nMax
                for  kTempInd = 1:kPrimeLen
                    if PDSCH_DMRS_CONFIG_TYPE == 'type 1'
                        k = 4*n+2*kPrime(kTempInd)+delta(p)+1;
                    elseif PDSCH_DMRS_CONFIG_TYPE == 'type 2'
                        k = 6*n+kPrime(kTempInd)+delta(p)+1;
                    end
                   DMRSMatrix(k,L,p) = BETA_DMRS*WfkTemp(kPrime(kTempInd)+1,p)*WtlTemp(lPrime(lPrimeInd)+1,p)*r(2*n+kPrime(kTempInd)+1);
                end
            end
        end
    end
end
for i = 1:RANKMax 
    DMRSMatrixSet{i} = DMRSMatrix(:,:,1:i);
    CDMGroupMapSet{i} = CDMGroup(1:i);
end
end