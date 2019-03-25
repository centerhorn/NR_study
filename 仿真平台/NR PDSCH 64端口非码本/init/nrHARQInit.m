%% Function Description
%  Initialize HARQ process configurations
%% Input
%  pdschConfig：Structure.
%               Configuration information for PDSCH.
%% Output
%  harqProcesses：Structure array.
%                 Configuration information for a set of HARQ processes.
%% Modify History
%  2018/04/17 created by Liu Chunhua 
%  2018/04/24 modified by Li Yong
%%
function harqProcesses = nrHARQInit(pdschConfig)  %#OK

% Initialize the number of codewords
if pdschConfig.EnableAdaptiveRank == true
    ncw = 1;
else
   % ncw = length(pdschConfig.Modulation);
    ncw = pdschConfig.TBNum;
end
harqProcess.ncw = ncw;

% Initialize the initial RV index
%harqProcess.RVIdx = zeros(1, ncw);               
harqProcess.RVIdx = ones(1,ncw);        %RVIdx应初始化为1

% Initialize the transport block 
harqProcess.data = cell(1, ncw);
harqProcess.modu = 2*ones(1,ncw);
harqProcess.R    = zeros(1,ncw);
harqProcess.TbLength = zeros(1,ncw);

% Initialize soft bits related information
harqProcess.decState(1:ncw) = deal(struct());       % Create an empty structure for each codeword
for cwInd = 1:ncw
    harqProcess.decState(cwInd).CBSBuffers = {};    % Create an cell array for CB soft buffer
    harqProcess.decState(cwInd).CBSCRC = [];        % create a vector for all CB CRC state 
    harqProcess.decState(cwInd).BLKCRC = 0;         % Set the initial TB CRC state
end

% Create HARQ processes as indicated by NHARQProcesses
harqProcesses(1:pdschConfig.NHARQProcesses) = harqProcess;

end