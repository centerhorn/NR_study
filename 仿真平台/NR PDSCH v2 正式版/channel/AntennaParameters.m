%% BS Antenna configuration
BSAntennaTotalNumber = 192; % 192 or 128 antenna
Column = 8;
Row = BSAntennaTotalNumber / 2 / Column;
BSAntennaLocation = zeros(BSAntennaTotalNumber,3);
BSAntennaPloAngle = [pi/4,-pi/4];
%%%%%%%%Antenna numbering rule%%%%%%
% / (0,0) is 1, / (1,0) is 2, \ (0,0) is 97,
for iAntenna = 1 : BSAntennaTotalNumber
    iSamePol = mod(iAntenna,BSAntennaTotalNumber/2); % 
    if iSamePol == 0
        iSamePol = BSAntennaTotalNumber/2;
    end
    iRow = mod(iSamePol,Row);
    if iRow == 0
        iRow = Row;
    end
    iCol = ceil( iSamePol / Row );
    BSAntennaLocation(iAntenna,:) = [0,(iCol-1)*0.5*wavelength,(iRow - 1)*0.7*wavelength];
end
%% UE Antenna configuration
UEAntennaTotalNumber = 4;
UEAntennaLocation = [0 0 0;0 0.5*wavelength 0;0 0 0;0 0.5*wavelength 0];
UEAntennaPloAngle = [0,pi/2];