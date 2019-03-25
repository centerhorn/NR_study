%% Function Description              
%  RB bundle deInterleave
%% Input
%  DataSymIn:              2-Dimension array(Rank-DataRENum)
%                          data after MMSE detection
%  RS_MAP_MATRIX:            3-dimensional array (subcarrier-symbol-rank).
%                          resource mapping matrix for DMRS,Data and PDCCH 
%  pdschConfig:            structure
%                          Configuration information for pdsch
%% Output
%  DataSymOut:             2-Dimension array(Rank-DataRENum)
%                          data after deInterleave
%% Modify History
%  2018/1/17 created by Liu Chunhua 
%  2018/05/28 modified by Song Erhao


%% code
function DataSymOut = nrDeInterleaveRBBundle(DataSymIn,RS_MAP_MATRIX,pdschConfig)

DataSymOut = zeros(size(DataSymIn));
RANK = size(DataSymIn,1);
[ReFreNum, ReTimeNum] = size(RS_MAP_MATRIX(:,:,1));                        % ��Դӳ�����
for RankInd = 1:RANK    
    SymOfdmIn = zeros(ReFreNum, ReTimeNum);                         % ϵͳʱƵ��Դ��
    DataSymInd = 1;                                                 % ����ϵͳ����������    
    %% ��Դӳ�䣬��Ƶ����ʱ��
    for TimeInd = 1 : ReTimeNum                                     
        for FreInd = 1 : ReFreNum
            if RS_MAP_MATRIX(FreInd, TimeInd,1) == 1                      %����λ�ö�Ӧ�������ɵ�����
               SymOfdmIn(FreInd, TimeInd) = DataSymIn(RankInd,DataSymInd);
               DataSymInd = DataSymInd + 1;
            end
        end
    end
    
    DeInterLeaveOut = RB_bundle_De_Interleaver(SymOfdmIn,pdschConfig);

    %% ����Դӳ��
    DataSymInd = 1;
    for TimeInd=1:ReTimeNum
        for FreInd=1:ReFreNum
            if RS_MAP_MATRIX(FreInd, TimeInd) == 1                                  % ����ӳ�����ȷ������ʱƵλ��
                DataSymOut(RankInd,DataSymInd) = DeInterLeaveOut(FreInd, TimeInd);        % �������������
                DataSymInd=DataSymInd+1;
            end     
        end
    end            
end