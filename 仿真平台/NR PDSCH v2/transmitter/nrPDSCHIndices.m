function [pdschIndices] = nrPDSCHIndices(RSMapMatrix)
%% function:
% returns a matrix IND containing Physical Downlink Shared Channel (PDSCH) Resource Element (RE) indices
%% Input:
% RSMapMatrix£º    3-dimensional array (subcarrier-symbol-port).
%                  resource mapping matrix for DMRS,Data and PDCCH 
%% Output£º
% pdschIndices£º   Double column vector
%                  PDSCH RE indices
%% Modify history
% 2018/4/13 created by Liu Chunhua 
% 2018/5/16 modified by Song erhao(editorial changes only)
%% code
% Resource mapping, frequency first
% for all ports, the location of PDSCH RE are the same.
pdschIndices = find(RSMapMatrix(:,:,1)==1);

end