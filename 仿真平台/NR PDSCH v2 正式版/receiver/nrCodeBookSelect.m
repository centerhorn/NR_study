%% Function Description
%  Codebook selection module, output codebook index
%% Input
%  H   :      2-Dimensional array(RANK-CIRSPortNum)
%  CodebookTotal:  2-Dimensional array
%                  total codebook
%  pdschConfig :   structure
%                  Configuration information for pdsch
%% Output
%  CodebookIndex:   double
%                   codebook index
%% Modify History
%  2018/1/15 created by Liu Chunhua
%  2018/05/31 modified by Song Erhao
%%

function [CodebookIndex]=nrCodeBookSelect(H,CodebookTotal,pdschConfig)
RANK = pdschConfig.Rank;
CODEBOOK_SELECT_PRINCIPLE = pdschConfig.CodebookSelectPrinciple;
CodebookNum = size(CodebookTotal,2)/RANK;
for CodebookInd=1:CodebookNum
    Codebook=CodebookTotal(:,(CodebookInd-1)*RANK+1:CodebookInd*RANK);
    HW=(H*Codebook)'*H*Codebook;
    lSNR(CodebookInd,:)=eig(HW);
    %     CapacityCodebook(CodebookInd) = log2(det(eye(RANK)+SINR*HW));
    %     CapacityCodebook(CodebookInd) = log2(det(eye(RANK)+mean(lSNR(CodebookInd,:))*HW));
    CapacityCodebook(CodebookInd) = log2(det(eye(RANK)+sum(lSNR(CodebookInd,:))*HW));
end
switch CODEBOOK_SELECT_PRINCIPLE
    case 1
        BerCodebook=sum((exp(-lSNR.^2./2)./(1.64.*lSNR+sqrt(0.76.*(lSNR.^2+4*ones(CodebookNum,RANK))))),2);
        CodebookMin=min(BerCodebook);
        Index=find(CodebookMin==BerCodebook);
        CodebookIndex=Index(1);
    case 2
        CodebookMax=max(CapacityCodebook);
        Index=find(CodebookMax==CapacityCodebook);
        CodebookIndex = Index(1);
end
end