%% Function Description
%  HARQ scheduling
%% Input
%  harqProcess: Structure.
%               Configuration information for harq
%  pdschConfig: Structure.
%               Configuration information for PDSCH
%% Output
%  harqProcess: Structure.
%               Configuration information for harq after scheduling
%% Modify History
%  2018/05/23 modified by Song Erhao 
%% 



function harqProcess = nrHARQScheduling(harqProcess, pdschConfig)
ncw = harqProcess.ncw;
for cwInd = 1:ncw
    % update RV index
    if harqProcess.decState(cwInd).BLKCRC == 1
        harqProcess.RVIdx(cwInd) = harqProcess.RVIdx(cwInd) + 1;
        if harqProcess.RVIdx(cwInd) > length(pdschConfig.RVSeq)
            harqProcess.RVIdx(cwInd) = 1;    % exceed the maximum retransmissions
        end
    else
        harqProcess.RVIdx(cwInd) = 1;
    end
    % update transport block state
    if harqProcess.RVIdx(cwInd) == 1
        harqProcess.decState(cwInd).CBSBuffers = {};    % Create an cell array for CB soft buffer
        harqProcess.decState(cwInd).CBSCRC = [];        % create a vector for all CB CRC state
        harqProcess.decState(cwInd).BLKCRC = 0;         % Set the initial TB CRC state
    end
end