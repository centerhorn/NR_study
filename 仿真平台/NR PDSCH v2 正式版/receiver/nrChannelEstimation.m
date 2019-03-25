%% Function Description
%   channel estimation
%% Input
%   PioltH :        cell of RxAntNum (each cell with a 2-Dimension array(RANK-DMRSReNum))
%                   DMRS after demapping
%   Qm          :   double              (need to change!!)
%                   Modulation order
%   R_hh        :   3-Dimensional array ((number of DMRS RE)-(number of DMRS RE)-rank)
%                   pilot Autocorrelation matrix
%   Rdh         :   3-Dimensional array ((number of Data RE)-(number of DMRS RE)-rank)
%               :   Data and DMRS Cross-correlation matrix
%   SnrLinear   :   double
%                   linear SNR
%   RxAntNum    :   double
%               :   number of receive antennas
%% Output
%   HDataMMSE   :    2-Dimensional array (TxAntNum*RxAntNum-DataRENum) 
%                    channel estimation result of Data
%% Modify history
% 2017/6/5 created by Mao Zhendong
% 2017/10/30 modified by Liu Chunhua
% 2018/5/23 modified by Song Erhao
function HDataMMSE = nrChannelEstimation(PilotH,Qm, R_hh, R_dh, SnrLinear,RxAntNum)

RANK = size(R_hh,3);
for RxAntInd=1:RxAntNum
    for RankInd = 1:RANK
        R_dh0_DMRS = R_dh(:,:,RxAntInd);
        R_hh0_DMRS = R_hh(:,:,RxAntInd);
        HDataMMSE((RxAntInd-1)*RANK+RankInd,:) = channel_estimation(PilotH{RxAntInd}(RankInd,:),Qm,R_dh0_DMRS, R_hh0_DMRS, SnrLinear);
    end
end


    function HDataMMSETemp =channel_estimation(PilotSymOut,Qm, R_dh, R_hh, SnrLinear)
        %计算beita
        %计算方法 beita=(星座点的平方的均值)*(星座点倒数的平方的均值)
        %即beita=(sum(abs(constel_diagram).^2)/64)*(sum(abs(1./constel_diagram).^2)/64)
        switch (Qm)
            case {1}
                beita=1;
            case {2}                               % QPSK为2
                beita=1;
            case {4}                               % 16QAM为4
                beita=17/9;
            case {6}                               % 64QAM为6
                beita=2.6854;
            case {8}
                beita=3.4371;
        end
        R_hh_pilot = R_hh / (R_hh+beita/SnrLinear*eye(length(R_hh)));
        R_hh_data = R_dh / (R_hh+1/SnrLinear*eye(length(R_hh)));
        
        
        HLS = PilotSymOut.';                           % LS估计出的DMRS处信道
        HPilotMMSETemp = R_hh_pilot * HLS;             % LMMSE估计出的DMRS处信道
        HDataMMSETemp = (R_hh_data * HPilotMMSETemp).';% LMMSE估计出的数据位置处信道
    end

end
