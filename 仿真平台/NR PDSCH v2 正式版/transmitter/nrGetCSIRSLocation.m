%% Function Description
%  Get location of CSIRS
%% Input
%  CSIRS_MAP:      3-Dimensional array (subcarrier-symbol-Port).
%                  CSIRS sequence mapping for all Ports.
%% Output
%  CSIRS_LOCATION: 3-Dimensional array (2(FreInd and TimeInd)-(number of CSIRS RE)-Port)
%                  location of CSIRS in the grid
%% Modify History
% 2018/05/29 modified by Song Erhao


function CSIRS_LOCATION = nrGetCSIRSLocation(CSIRS_MAP)
[ReFreNum, ReTimeNum,PortNum] = size(CSIRS_MAP);                        % ◊ ‘¥”≥…‰æÿ’Û
for PortInd = 1:PortNum
    CsirsLocaTemp = [];
    for TimeInd = 1 : ReTimeNum                                     
        for FreInd = 1 : ReFreNum
            if CSIRS_MAP(FreInd, TimeInd,PortInd) ~= 0                                  
               CsirsLocaTemp = [CsirsLocaTemp,[FreInd;TimeInd]];
            end
        end
    end  
    CSIRS_LOCATION(:,:,PortInd) = CsirsLocaTemp;
end
end