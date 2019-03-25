function [HbmatrixBit,InformationBitLen,CodeLen] = LDPCPCMatrix(CheckIndex)
%% 函数功能：
% 产生校验矩阵H
%% Modify history
% 2018/6/14 created by Sharon Sha 
%% code
% 读取校验矩阵
    CheckMatrix2=[2, 4, 8, 16, 32, 64, 128, 256];
    CheckMatrix3=[3, 6, 12, 24, 48, 96, 192,384];
    CheckMatrix5=[5, 10, 20, 40, 80, 160,320];
    CheckMatrix7=[7, 14, 28, 56, 112, 224];
    CheckMatrix9=[9, 18, 36, 72, 144,288];
    CheckMatrix11=[11, 22, 44, 88, 176,352];
    CheckMatrix13=[13, 26, 52, 104, 208];
    CheckMatrix15=[15, 30, 60, 120, 240];
if ~isempty(find(CheckMatrix2==CheckIndex))
    load('Hbmatrix2.txt');
    Hbmatrix1 = Hbmatrix2;
elseif ~isempty(find(CheckMatrix3==CheckIndex))
    load('Hbmatrix3.txt');
    Hbmatrix1 = Hbmatrix3;
elseif ~isempty(find(CheckMatrix5==CheckIndex))
    load('Hbmatrix5.txt');
    Hbmatrix1 = Hbmatrix5;
elseif ~isempty(find(CheckMatrix7==CheckIndex))
    load('Hbmatrix7.txt');
    Hbmatrix1 = Hbmatrix7;
elseif ~isempty(find(CheckMatrix9==CheckIndex))
    load('Hbmatrix9.txt');
    Hbmatrix1 =Hbmatrix9;
elseif ~isempty(find(CheckMatrix11==CheckIndex))
    load('Hbmatrix11.txt');
    Hbmatrix1 =Hbmatrix11;
    CheckIndMax=max(CheckMatrix11);
elseif ~isempty(find(CheckMatrix13==CheckIndex))
    load('Hbmatrix13.txt');
    Hbmatrix1 = Hbmatrix13;
elseif ~isempty(find(CheckMatrix15==CheckIndex))
    load('Hbmatrix15.txt');
    Hbmatrix1 = Hbmatrix15;
end


% 计算校验矩阵的奇偶校验矩阵
[ RowSize,ColSize ] = size(Hbmatrix1);
HbmatrixBit = [];
for rowindex = 1:RowSize
    HbmatrixBit0 = [];
    for colindex = 1:ColSize
        if Hbmatrix1(rowindex,colindex) > -1
            HbmatrixBit0 = [HbmatrixBit0,circshift(speye(CheckIndex),-1*Hbmatrix1(rowindex,colindex))];
        else
            HbmatrixBit0 = [HbmatrixBit0,sparse(CheckIndex,CheckIndex)];
        end
        
    end
    HbmatrixBit = [HbmatrixBit;HbmatrixBit0];
end
InformationBitLen = (ColSize-RowSize) * CheckIndex;
CodeLen = ColSize * CheckIndex;

end