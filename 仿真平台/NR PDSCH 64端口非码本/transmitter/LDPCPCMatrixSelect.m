function [CheckIndex] = LDPCPCMatrixSelect(K, Flag)
%% 函数功能：
% 校验矩阵参数Z设置

%% Modify history
% 2018/6/14 created by Sharon Sha 
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
end