%% Function Description
%  update gnb time
%% Input
%  gnbConfig : structure
%              Configuration Information for gnb
%  pdschConfig: structure
%              Configuration Information for pdsch
%% Output
%  gnbConfig :  structure
%               Configuration Information for gnb
%% Modify History
%  2018/05/24 modified by Song Erhao
%% Code
function gnbConfig = nrGNBTimingUpdate(gnbConfig, pdschConfig)  %#OK

gnbConfig.NSlot = gnbConfig.NSlot + 1;

if gnbConfig.NSlot == pdschConfig.SubcarrierSpacing/15
    gnbConfig.NSlot = 0;
    gnbConfig.NSubframe = gnbConfig.NSubframe + 1;
    if gnbConfig.NSubframe == 10
        gnbConfig.NSubframe = 0;
        gnbConfig.NFrame = gnbConfig.NFrame + 1;
    end
end

end