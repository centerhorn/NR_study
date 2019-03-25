function [EncodePara, DecodePara, CheckIndex, InformationBitLen, CodeLen] = MatrixSet(K, Flag)
%% 函数功能：
% 校验矩阵参数设置

%% Modify history
% 2017/12/27 created by Sharon Sha 
%% code
% 校验矩阵选择
if Flag==1
    PathNow = pwd;
    Path1 = [PathNow,'/support/HBM1'];
    addpath(Path1);
    CheckMatrix2=[2, 4, 8, 16, 32, 64, 128, 256];
    CheckMatrix3=[3, 6, 12, 24, 48, 96, 192, 384];
    CheckMatrix5=[5, 10, 20, 40, 80, 160, 320];
    CheckMatrix7=[7, 14, 28, 56, 112, 224];
    CheckMatrix9=[9, 18, 36, 72, 144, 288];
    CheckMatrix11=[11, 22, 44, 88, 176, 352];
    CheckMatrix13=[13, 26, 52, 104, 208];
    CheckMatrix15=[15, 30, 60, 120, 240];
    CheckMatrix=[CheckMatrix2,CheckMatrix3,CheckMatrix5,CheckMatrix7,CheckMatrix9,CheckMatrix11,CheckMatrix13,CheckMatrix15];
    CheckMatrix = sort(CheckMatrix);
    NumMax = 22;
    SetInd = find(CheckMatrix>=ceil(K / NumMax), 1, 'first');
    CheckIndex = CheckMatrix(SetInd);
elseif Flag==2
    PathNow = pwd;
    Path2 = [PathNow,'/support/HBM2'];
    addpath(Path2);
    CheckMatrix2=[2, 4, 8, 16, 32, 64, 128, 256];
    CheckMatrix3=[3, 6, 12, 24, 48, 96, 192,384];
    CheckMatrix5=[5, 10, 20, 40, 80, 160,320];
    CheckMatrix7=[7, 14, 28, 56, 112, 224];
    CheckMatrix9=[9, 18, 36, 72, 144,288];
    CheckMatrix11=[11, 22, 44, 88, 176,352];
    CheckMatrix13=[13, 26, 52, 104, 208];
    CheckMatrix15=[15, 30, 60, 120, 240];
    CheckMatrix = sort([CheckMatrix2,CheckMatrix3,CheckMatrix5,CheckMatrix7,CheckMatrix9,CheckMatrix11,CheckMatrix13,CheckMatrix15]);
    NumMax = 10;
    
    if(K>640)
        Num=10;
        SetInd = find(CheckMatrix>=ceil(K / Num), 1, 'first');
        CheckIndex = CheckMatrix(SetInd);
    elseif(K>560)
        Num=9;
        SetInd = find(CheckMatrix>=ceil(K / Num), 1, 'first');
        CheckIndex = CheckMatrix(SetInd);
    elseif(K>192)
        Num=8;
        SetInd = find(CheckMatrix>=ceil(K / Num), 1, 'first');
        CheckIndex = CheckMatrix(SetInd);
    else
        Num=6;
        SetInd = find(CheckMatrix>=ceil(K / Num), 1, 'first');
        CheckIndex = CheckMatrix(SetInd);
    end
    
end

% 读取校验矩阵
if ~isempty(find(CheckMatrix2==CheckIndex))
    CheckIndMax=max(CheckMatrix2);
    load('Hbmatrix2.txt');
    Hbmatrix1 = Hbmatrix2;
elseif ~isempty(find(CheckMatrix3==CheckIndex))
    CheckIndMax=max(CheckMatrix3);
    load('Hbmatrix3.txt');
    Hbmatrix1 = Hbmatrix3;
elseif ~isempty(find(CheckMatrix5==CheckIndex))
    CheckIndMax=max(CheckMatrix5);
    load('Hbmatrix5.txt');
    Hbmatrix1 = Hbmatrix5;
elseif ~isempty(find(CheckMatrix7==CheckIndex))
    CheckIndMax=max(CheckMatrix7);
    load('Hbmatrix7.txt');
    Hbmatrix1 = Hbmatrix7;
elseif ~isempty(find(CheckMatrix9==CheckIndex))
    CheckIndMax=max(CheckMatrix9);
    load('Hbmatrix9.txt');
    Hbmatrix1 =Hbmatrix9;
elseif ~isempty(find(CheckMatrix11==CheckIndex))
    CheckIndMax=max(CheckMatrix11);
    load('Hbmatrix11.txt');
    Hbmatrix1 =Hbmatrix11;
    CheckIndMax=max(CheckMatrix11);
elseif ~isempty(find(CheckMatrix13==CheckIndex))
    CheckIndMax=max(CheckMatrix13);
    load('Hbmatrix13.txt');
    Hbmatrix1 = Hbmatrix13;
elseif ~isempty(find(CheckMatrix15==CheckIndex))
    CheckIndMax=max(CheckMatrix15);
    load('Hbmatrix15.txt');
    Hbmatrix1 = Hbmatrix15;
end


% 计算校验矩阵的奇偶校验矩阵
[ RowSize,ColSize ] = size(Hbmatrix1);
HbmatrixBit = [];
for ii = 1:RowSize
    HbmatrixBit0 = [];
    for jj = 1:ColSize
        if Hbmatrix1(ii,jj) > -1
            HbmatrixBit0 = [HbmatrixBit0,circshift(speye(CheckIndex),-1*Hbmatrix1(ii,jj))];
        else
            HbmatrixBit0 = [HbmatrixBit0,sparse(CheckIndex,CheckIndex)];
        end
        
    end
    HbmatrixBit = [HbmatrixBit;HbmatrixBit0];
end
InformationBitLen = (ColSize-RowSize) * CheckIndex;
CodeLen = ColSize * CheckIndex;

% 计算分析LDPC参数
EncodePara = comm.LDPCEncoder(HbmatrixBit);
DecodePara = comm.LDPCDecoder(HbmatrixBit);
DecodePara.IterationTerminationCondition  = 'Parity check satisfied';

% EncodePara = fec.ldpcenc(HbmatrixBit);
% DecodePara = fec.ldpcdec(HbmatrixBit);
% DecodePara.DoParityChecks = 'Yes';


