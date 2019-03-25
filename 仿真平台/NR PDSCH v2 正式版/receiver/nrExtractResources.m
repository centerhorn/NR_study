%% Function Description
%  get received pdsch symbols sequence and estiminated H based on Resource grid 
%% Input
%  pdschIndices£ºVector. 
%             PDSCH mapping index.
%  rxGrid: array. 
%            the resource grid after ofdm demodulation.
%  estChannelGrid: array. 
%            the corresponding H estiminated for the resource grid.
%% Output
%  pdschRx£ºvector.
%          pdsch symbols.
%  pdschHest£ºvector.
%          pdsch symbols' H estiminated.
%% Modify History
%  2018/04/13 created by Liu Chunhua 
%  2018/04/18 modified by Liu Chunhua 
%%
function [pdschRx, pdschHest] = nrExtractResources(pdschIndices, rxGrid, estChannelGrid)
% get pdsch symbols
pdschLen = length(pdschIndices);
pdschRx = zeros(1,pdschLen);
pdschHest = zeros(1,pdschLen);
for Ind = 1:pdschLen
    pdschRx(Ind) = rxGrid(pdschIndices(Ind));
    pdschHest(Ind) = estChannelGrid(pdschIndices(Ind)); 
end

end