%% Function Description
%  Initialize gNB configurations
%% Input
%  void
%% Output
%  gnbConfig£ºStructure.
%             Configuration information for gNB.
%% Modify History
%  2018/04/17 created by Liu Chunhua 
%  2018/04/18 modified by Li Yong (editorial changes only)
%%
function gnbConfig = nrGNBInit()  %#OK

gnbConfig.NCellID = 0;                                                                                                  %%???
gnbConfig.TxAntNum = 2;                                                                                                 
gnbConfig.NFrame = 0;               % frame index. {0,1,...}
gnbConfig.NSubframe = 0;            % subframe index in a frame. {0,1,...9}
gnbConfig.NSlot = 0;                % slot index in a subframe. {0} for 15kHz, {0,1} for 30kHz, ..., {0,1,...15} for 240kHz