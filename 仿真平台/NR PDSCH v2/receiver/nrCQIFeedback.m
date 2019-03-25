%% Function Description
%  Determine CQI level based on SINR after EESM detection
%% Input
%  Sinr:      double
%             SINR after merging   
%% Output
%  CqiIndex:  row vector(1 or 2 element)
%             CQI index
%% Modify history
% 2017/10/28 created by Liu Chunhua 
% 2018/06/01 modified by Song Erhao(editorial changes only)

function [CqiIndex] = nrCQIFeedback(Sinr)
%CQI_SE=[0.1523,0.2344,0.377,0.6016,0.877,1.1758,1.4766,1.9141,2.4063,2.7305,3.3223,3.9023,4.5234,5.1152,5.5547];
TBNum = length(Sinr);
CqiIndex = zeros(1,TBNum);
for CWInd = 1:TBNum
    SINR = Sinr(CWInd);
    if SINR<-6.21
        CQI_index=1;
    elseif SINR<-4.39
        CQI_index=1;
    elseif SINR<-2.73
        CQI_index=2;
    elseif SINR<-0.76
        CQI_index=3;
    elseif SINR<1.21
        CQI_index=4;
    elseif SINR<3.03
        CQI_index=5;
    elseif SINR<5.30
        CQI_index=6;
    elseif SINR<6.82
        CQI_index=7;
    elseif SINR<8.79
        CQI_index=8;
    elseif SINR<10.61
        CQI_index=9;
    elseif SINR<12.58
        CQI_index=10;
    elseif SINR<14.24
        CQI_index=11;
    elseif SINR<16.06
        CQI_index=12;
    elseif SINR<17.88
        CQI_index=13;
    elseif SINR<20.30
        CQI_index=14;    
    elseif SINR>=20.30
        CQI_index=15;  
    end
    
    CqiIndex(CWInd) =  CQI_index;
end
end


