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
% 400bit

function [MCSIndex,SE] = nrMCSSelect(Sinr)
MCS_SE=[0.2344	0.377	0.6016	0.877	1.1758	1.4766	1.6953	1.9141	2.1602	2.4063	2.5703	2.7305	3.0293	3.3223	3.6094	3.9023	4.2129	4.5234	4.8164	5.1152	5.332	5.5547	5.8906	6.2266	6.5703	6.9141	7.1602	7.4063];
TBNum = length(Sinr);
MCSIndex = zeros(1,TBNum);
for CWInd = 1:TBNum
    SINR = Sinr(CWInd);
%     if SINR<-4.5
%         MCS_index=1;
%     elseif SINR<-2.1
%         MCS_index=2;
%     elseif SINR<-0.1
%         MCS_index=3;
%     elseif SINR<1.9
%         MCS_index=4;
%     elseif SINR<3.9
%         MCS_index=5;
%     elseif SINR<4.9
%         MCS_index=6;
%     elseif SINR<5.7
%         MCS_index=7;
%     elseif SINR<6.7
%         MCS_index=8;
%     elseif SINR<7.7
%         MCS_index=9;
%     elseif SINR<8.3
%         MCS_index=10;
%     elseif SINR<9.7
%         MCS_index=11;
%     elseif SINR<10.9
%         MCS_index=12;
%     elseif SINR<11.5
%         MCS_index=13;    
%     elseif SINR<12.5
%         MCS_index=14; 
%     elseif SINR<13.3
%         MCS_index=15;
%     elseif SINR<14.3
%         MCS_index=16;
%     elseif SINR<15.3
%         MCS_index=17;
%     elseif SINR<16.3
%         MCS_index=18;
%     elseif SINR<17.3
%         MCS_index=19;
%     elseif SINR<18.3
%         MCS_index=20;    
%     elseif SINR<19.3
%         MCS_index=21;         
%     elseif SINR<20.1
%         MCS_index=22;
%     elseif SINR<20.9
%         MCS_index=23;
%     elseif SINR<22
%         MCS_index=24;
%     elseif SINR<23.3
%         MCS_index=25;
%     elseif SINR<24.3
%         MCS_index=26;
%     elseif SINR<25.1
%         MCS_index=27;                  
%     else
%         MCS_index=28; 
%     end
    if SINR<-4.47
        MCS_index=1;
    elseif SINR<-2.2
        MCS_index=2;
    elseif SINR<0.12
        MCS_index=3;
    elseif SINR<1.98
        MCS_index=4;
    elseif SINR<4.22
        MCS_index=5;
    elseif SINR<4.8
        MCS_index=6;
    elseif SINR<5.88
        MCS_index=7;
    elseif SINR<6.84
        MCS_index=8;
    elseif SINR<7.78
        MCS_index=9;
    elseif SINR<8.42
        MCS_index=10;
    elseif SINR<9.78
        MCS_index=11;
    elseif SINR<10.63
        MCS_index=12;
    elseif SINR<11.49
        MCS_index=13;
    elseif SINR<12.40
        MCS_index=14;
    elseif SINR<13.53
        MCS_index=15;
    elseif SINR<14.25
        MCS_index=16;
    elseif SINR<15.18
        MCS_index=17;
    elseif SINR<16.14
        MCS_index=18;
    elseif SINR<17.34
        MCS_index=19;
    elseif SINR<18.44
        MCS_index=20;
    elseif SINR<19.10
        MCS_index=21;
    elseif SINR<19.91
        MCS_index=22;
    elseif SINR<20.96
        MCS_index=23;
    elseif SINR<22.64
        MCS_index=24;
    elseif SINR<23.66
        MCS_index=25;
    elseif SINR<24.1
        MCS_index=26;
    elseif SINR<25.35
        MCS_index=27;
    else
        MCS_index=28;
    end
    
    MCSIndex(CWInd) =  MCS_index;
    SE(CWInd) = MCS_SE(MCS_index);
end
end


