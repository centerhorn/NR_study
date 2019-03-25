%% Function Description              
%  RB bundle deInterleave(Reference to TS38.211 section 7.3.1)
%% Input
%  DataSymIn:              2-Dimension array(subcarrier-symbol)
%                          Physical Resource Mapping Matrix for a port after interleaver
%  pdschConfig:            structure
%                          Configuration information for pdsch
%% Output
%  DataSymOut:             2-Dimension array(subcarrier-symbol)
%                          Virtual Resource Mapping Matrix after deInterleave
%% Modify History
%  2018/1/17 created by Liu Chunhua 
%  2018/05/28 modified by Song Erhao

%% code
function DataSymOut = RB_bundle_De_Interleaver(DataSymIn,pdschConfig)
RB_NUM=pdschConfig.NDLRB;
RB_BUNDLE_SIZE=pdschConfig.RbBundleSize;
SUBCARRIER_PER_RB=pdschConfig.SubcarriersPerRB;
InterleavUnit = RB_BUNDLE_SIZE*SUBCARRIER_PER_RB;
RBBundleNum = size(DataSymIn,1)/InterleavUnit;

R = 2;
C = ceil(RB_NUM/RB_BUNDLE_SIZE/R);
for r = 0:(R-1)
    for c = 0:(C-1)
        j = c*R + r;
        F(j+1) = r*C+c+1;
    end
end
DataSymOut = [];
for RBBundleInd = 1:RBBundleNum
    
    DataSymOut(((RBBundleInd-1)*InterleavUnit+1):(RBBundleInd*InterleavUnit),:) = DataSymIn(((F(RBBundleInd)-1)*InterleavUnit+1):(F(RBBundleInd)*InterleavUnit),:);
end

end