%% Function Description
%  Type I Single Panel Codebook
%% Input
% PortCSIRS:       double
%                  Ports of CSIRS
% RANK:            double
%                  rank
% CODEBOOK_MODE:   double
%                  codebook mode
% ON12:            row vector
%                  ON12
%% Output
% CodeBookTotal:   Matrix
%                  codebook sets
%% Modify History
% 2018/05/29 modified by Song Erhao
function CodeBookTotal=Type1_SinglePanel_Codebook(PortCSIRS,RANK,CODEBOOK_MODE,ON12)

%% CSI-RS端口个数2
if PortCSIRS == 1
   CodeBookTotal = 1; 
elseif PortCSIRS == 2
    switch RANK
        case 1
            CodeBookTotal = 1/sqrt(2)*[ones(1,4);1,1i,-1,-1i];
        case 2
            CodeBookTotal = 1/sqrt(2)*[ones(1,4);1,-1,1i,-1i];
    end
%% CSI-RS端口个数大于2
elseif PortCSIRS > 2
    N1N2Conf = [2 2 4 3 6 4 8 4 6 12 4 8 16;1 2 1 2 1 2 1 3 2 1 4 2 1];    
    O1 = ON12(1);
    O2 = ON12(2);
    N1 = ON12(3);
    N2 = ON12(4);
    for IndTemp = 1:5
        if N1N2Conf(1,IndTemp)==N1 && N1N2Conf(2,IndTemp)==N2
            IndT = IndTemp;
        end
    end    

    if RANK==2
        if N1>N2 && N2>1
            k1k2 = [0 O1 0 2*O1;0 0 O2 0];
        elseif N1==N2
            k1k2 = [0 O1 0 O1;0 0 O2 O2];
        elseif N1==2 && N2==1
            k1k2 = [0 O1;0 0];
        elseif N1>2 && N2==1
            k1k2 = [0 O1 2*O1 3*O1;0 0 0 0];
        end
        k1k2Len = size(k1k2,2);
    elseif (RANK==3 || RANK==4) && PortCSIRS<16
        k1k2Len = [1 3 3 4 4];
        k1k2Total = [O1 0 0 0;0 0 0 0;O1 0 O1 0;0 O2 O2 0;O1 2*O1 3*O1 0; ...
            0 0 0 0;O1 0 O1 2*O1;0 O2 O2 0; O1 2*O1 3*O1 4*O1;0 0 0 0];
        k1k2 = k1k2Total((2*IndT-1):2*IndT,1:k1k2Len(IndT));
        k1k2Len = size(k1k2,2);
    end
    
    CodeBookTotal = [];
    switch RANK
        case 1
            %% 一层CSI上报
            if CODEBOOK_MODE == 1
               i11Len= N1*O1-1;
               i12Len= N2*O2-1;
               i2Len= 3;
               for i11 = 0:i11Len
                   for i12 = 0:i12Len
                       Vlm = V(i11,i12,O1,N1,O2,N2);
                       for i2 = 0:i2Len                           
                           CodeBook = 1/sqrt(PortCSIRS)*[Vlm;Phy(i2)*Vlm];
                           CodeBookTotal = [CodeBookTotal,CodeBook];
                       end
                    end
               end
            end

            if CODEBOOK_MODE == 2 && N2>1
               i11Len= N1*O1/2-1;
               i12Len= N2*O2/2-1;
               i2Len= 15;  
               for i11 = 0:i11Len
                   for i12 = 0:i12Len
                       CBIndex = [2*i11*ones(1,4),(2*i11+1)*ones(1,4),2*i11*ones(1,4),(2*i11+1)*ones(1,4); ...
                               2*i12*ones(1,8),(2*i12+1)*ones(1,8); ...
                               0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3];
                       for i2 = 0:i2Len
                           Vlm = V(CBIndex(1,i2+1),CBIndex(2,i2+1),O1,N1,O2,N2);
                           CodeBook = 1/sqrt(PortCSIRS)*[Vlm;Phy(CBIndex(3,i2+1))*Vlm];
                           CodeBookTotal = [CodeBookTotal,CodeBook];
                       end
                   end
               end
            end

            if CODEBOOK_MODE == 2 && N2==1
               i11Len = N1*O1/2-1; 
               i2Len = 15;   
               for i11 = 0:i11Len
                   CBIndex = [2*i11*ones(1,4),(2*i11+1)*ones(1,4),(2*i11+2)*ones(1,4),(2*i11+3)*ones(1,4); ...
                       zeros(1,16); ...
                       0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3];                   
                   for i2 = 0:i2Len
                       Vlm = V(CBIndex(1,i2+1),CBIndex(2,i2+1),O1,N1,O2,N2);
                       CodeBook = 1/sqrt(PortCSIRS)*[Vlm;Phy(CBIndex(3,i2+1))*Vlm];
                       CodeBookTotal = [CodeBookTotal,CodeBook];
                   end
               end
            end
        case 2
            %% 二层CSI上报
            if CODEBOOK_MODE == 1
               i11Len = N1*O1-1; 
               i12Len = N2*O2-1; 
               i2Len = 1;
               for i13 = 0:(k1k2Len-1)
                   k1 = k1k2(1,i13+1);k2 = k1k2(2,i13+1);
                   for i11 = 0:i11Len 
                       for i12 = 0:i12Len
                           Vlm = V(i11,i12,O1,N1,O2,N2);
                           Vlm2 = V(i11+k1,i12+k2,O1,N1,O2,N2);                           
                           for i2 = 0:i2Len                                                              
                               CodeBook = 1/sqrt(2*PortCSIRS)*[Vlm,Vlm2;Phy(i2)*Vlm,-Phy(i2)*Vlm2];
                               CodeBookTotal = [CodeBookTotal,CodeBook];
                           end
                       end
                   end
               end
            end

            if CODEBOOK_MODE == 2 && N2>1
               i11Len = N1*O1/2-1; 
               i12Len = N2*O2/2-1; 
               i2Len = 7;
               for i13 = 0:(k1k2Len-1)
                   k1 = k1k2(1,i13+1);k2 = k1k2(2,i13+1);
                   for i11 = 0:i11Len 
                       for i12 = 0:i12Len 
                           CBIndex = [2*i11*ones(1,2),(2*i11+1)*ones(1,2),2*i11*ones(1,2),(2*i11+1)*ones(1,2); ...
                               (2*i11+k1)*ones(1,2),(2*i11+k1+1)*ones(1,2),(2*i11+k1)*ones(1,2),(2*i11+k1+1)*ones(1,2); ...
                               2*i12*ones(1,4),(2*i12+1)*ones(1,4); ...
                               (2*i12+k2)*ones(1,4),(2*i12+k2+1)*ones(1,4); ...
                               0,1,0,1,0,1,0,1];                           
                           for i2 = 0:i2Len
                               Vlm = V(CBIndex(1,i2+1),CBIndex(3,i2+1),O1,N1,O2,N2);
                               Vlm2 = V(CBIndex(2,i2+1),CBIndex(4,i2+1),O1,N1,O2,N2);
                               CodeBook = 1/sqrt(2*PortCSIRS)*[Vlm,Vlm2;Phy(CBIndex(5,i2+1))*Vlm,-Phy(CBIndex(5,i2+1))*Vlm2];
                               CodeBookTotal = [CodeBookTotal,CodeBook];
                           end
                       end
                   end
               end
            end

            if CODEBOOK_MODE == 2 && N2==1
               i11Len = N1*O1/2-1; 
               i2Len = 7;
               for i13 = 0:(k1k2Len-1)
                   k1 = k1k2(1,i13+1);
                   for i11 = 0:i11Len  
                       CBIndex = [2*i11*ones(1,2),(2*i11+1)*ones(1,2),(2*i11+2)*ones(1,2),(2*i11+3)*ones(1,2); ...
                           (2*i11+k1)*ones(1,2),(2*i11+k1+1)*ones(1,2),(2*i11+k1+2)*ones(1,2),(2*i11+k1+3)*ones(1,2); ...
                           zeros(1,8); ...
                           zeros(1,8); ...
                           0,1,0,1,0,1,0,1];                       
                       for i2 = 0:i2Len                              
                           Vlm = V(CBIndex(1,i2+1),CBIndex(3,i2+1),O1,N1,O2,N2);
                           Vlm2 = V(CBIndex(2,i2+1),CBIndex(4,i2+1),O1,N1,O2,N2);
                           CodeBook = 1/sqrt(2*PortCSIRS)*[Vlm,Vlm2;Phy(CBIndex(5,i2+1))*Vlm,-Phy(CBIndex(5,i2+1))*Vlm2];
                           CodeBookTotal = [CodeBookTotal,CodeBook];
                       end
                   end
               end             
            end
        case 3
            %% 三层CSI上报
            if CODEBOOK_MODE >= 1 && CODEBOOK_MODE <= 2 && PortCSIRS<16
               i11Len = N1*O1-1; 
               i12Len = N2*O2-1; 
               i2Len = 1;
               for i13 = 0:(k1k2Len-1)
                   k1 = k1k2(1,i13+1);k2 = k1k2(2,i13+1); 
                   for i11 = 0:i11Len 
                       for i12 = 0:i12Len 
                           Vlm = V(i11,i12,O1,N1,O2,N2);
                           Vlm2 = V(i11+k1,i12+k2,O1,N1,O2,N2);                           
                           for i2 = 0:i2Len                                  
                               CodeBook = 1/sqrt(3*PortCSIRS)*[Vlm,Vlm2,Vlm;Phy(i2)*Vlm,Phy(i2)*Vlm2,-Phy(i2)*Vlm];
                               CodeBookTotal = [CodeBookTotal,CodeBook];
                           end
                       end
                   end
               end                
            end

            if CODEBOOK_MODE >= 1 && CODEBOOK_MODE <= 2 && PortCSIRS>=16
               i11Len = N1*O1/2-1; 
               i12Len = N2*O2-1; 
               i13Len = 3; 
               i2Len = 1;
               for i11 = 0:i11Len
                   for i12 = 0:i12Len
                       VQuanlm = VQuan(i11,i12,O1,N1,O2,N2);
                       for i2 = 0:i2Len 
                           PhiN = Phy(i2);
                           for i13 = 0:i13Len                               
                               ThetaP = Theta(i13);                               
                               CodeBook = 1/sqrt(3*PortCSIRS)*[VQuanlm,VQuanlm,VQuanlm;ThetaP*VQuanlm,-ThetaP*VQuanlm,ThetaP*VQuanlm; ...
                                   PhiN*VQuanlm,PhiN*VQuanlm,-PhiN*VQuanlm;PhiN*ThetaP*VQuanlm,-PhiN*ThetaP*VQuanlm,-PhiN*ThetaP*VQuanlm];
                               CodeBookTotal = [CodeBookTotal,CodeBook];
                           end
                       end
                   end
               end                
            end
        case 4
            %% 四层CSI上报
            if CODEBOOK_MODE >= 1 && CODEBOOK_MODE <= 2 && PortCSIRS<16
               i11Len = N1*O1-1; 
               i12Len = N2*O2-1; 
               i2Len = 1;
               for i13 = 0:(k1k2Len-1)
                   k1 = k1k2(1,i13+1);k2 = k1k2(2,i13+1);
                   for i11 = 0:i11Len 
                       for i12 = 0:i12Len 
                           Vlm = V(i11,i12,O1,N1,O2,N2);
                           Vlm2 = V(i11+k1,i12+k2,O1,N1,O2,N2);                           
                           for i2 = 0:i2Len                                                  
                               PhiN = Phy(i2);
                               CodeBook = 1/sqrt(4*PortCSIRS)*[Vlm,Vlm2,Vlm,Vlm2;PhiN*Vlm,PhiN*Vlm2,-PhiN*Vlm,-PhiN*Vlm2];
                               CodeBookTotal = [CodeBookTotal,CodeBook];
                           end
                       end
                   end
               end                  
            end

            if CODEBOOK_MODE >= 1 && CODEBOOK_MODE <= 2 && PortCSIRS>=16
               i11Len = N1*O1/2-1; 
               i12Len = N2*O2-1; 
               i13Len = 3; 
               i2Len = 1;
               for i11 = 0:i11Len
                   for i12 = 0:i12Len
                       VQuanlm = VQuan(i11,i12,O1,N1,O2,N2);
                       for i2 = 0:i2Len 
                           PhiN = Phy(i2);
                           for i13 = 0:i13Len                                              
                               ThetaP = Theta(i13);                               
                               CodeBook = 1/sqrt(4*PortCSIRS)*[VQuanlm,VQuanlm,VQuanlm,VQuanlm;ThetaP*VQuanlm,-ThetaP*VQuanlm,ThetaP*VQuanlm,-ThetaP*VQuanlm; ...
                                   PhiN*VQuanlm,PhiN*VQuanlm,-PhiN*VQuanlm,-PhiN*VQuanlm;PhiN*ThetaP*VQuanlm,-PhiN*ThetaP*VQuanlm,-PhiN*ThetaP*VQuanlm,PhiN*ThetaP*VQuanlm];
                               CodeBookTotal = [CodeBookTotal,CodeBook];
                           end
                       end
                   end
               end
               
            end
        case 5
            %% 五层CSI上报
            i11Len = N1*O1-1;
            i2Len = 1;
            if CODEBOOK_MODE >= 1 && CODEBOOK_MODE <= 2 && N2>1
               i12Len = N2*O2-1;                
               for i12 = 0:i12Len                    
                   for i11 = 0:i11Len
                       CBIndex = [i11,i11+O1,i11+O1,i12,i12,i12+O2];
                       Vlm = V(CBIndex(1),CBIndex(4),O1,N1,O2,N2);
                       Vlm2 = V(CBIndex(2),CBIndex(5),O1,N1,O2,N2);
                       Vlm3 = V(CBIndex(3),CBIndex(6),O1,N1,O2,N2);                       
                       for i2 = 0:i2Len                           
                           PhiN = Phy(i2);
                           CodeBook = 1/sqrt(5*PortCSIRS)*[Vlm,Vlm,Vlm2,Vlm2,Vlm3;PhiN*Vlm,-PhiN*Vlm,Vlm2,-Vlm2,Vlm3];
                           CodeBookTotal = [CodeBookTotal,CodeBook];
                       end
                   end
               end                                    
            elseif CODEBOOK_MODE >= 1 && CODEBOOK_MODE <= 2 && N2==1 && N1>2                
               for i11 = 0:i11Len
                   CBIndex = [i11,i11+O1,i11+2*O1,0,0,0];
                   Vlm = V(CBIndex(1),CBIndex(4),O1,N1,O2,N2);
                   Vlm2 = V(CBIndex(2),CBIndex(5),O1,N1,O2,N2);
                   Vlm3 = V(CBIndex(3),CBIndex(6),O1,N1,O2,N2);                   
                   for i2 = 0:i2Len
                       PhiN = Phy(i2);
                       CodeBook = 1/sqrt(5*PortCSIRS)*[Vlm,Vlm,Vlm2,Vlm2,Vlm3;PhiN*Vlm,-PhiN*Vlm,Vlm2,-Vlm2,Vlm3];
                       CodeBookTotal = [CodeBookTotal,CodeBook];
                   end
               end               
            end             
        case 6
            %% 六层CSI上报
            i11Len = N1*O1-1;
            i2Len = 1;            
            if CODEBOOK_MODE >= 1 && CODEBOOK_MODE <= 2 && N2>1
               i12Len = N2*O2-1; 
               for i12 = 0:i12Len                    
                   for i11 = 0:i11Len
                       CBIndex = [i11,i11+O1,i11+O1,i12,i12,i12+O2];
                       Vlm = V(CBIndex(1),CBIndex(4),O1,N1,O2,N2);
                       Vlm2 = V(CBIndex(2),CBIndex(5),O1,N1,O2,N2);
                       Vlm3 = V(CBIndex(3),CBIndex(6),O1,N1,O2,N2);                       
                       for i2 = 0:i2Len  
                           PhiN = Phy(i2);
                           CodeBook = 1/sqrt(6*PortCSIRS)*[Vlm,Vlm,Vlm2,Vlm2,Vlm3,Vlm3;PhiN*Vlm,-PhiN*Vlm,PhiN*Vlm2,-PhiN*Vlm2,Vlm3,-Vlm3];  
                           CodeBookTotal = [CodeBookTotal,CodeBook];
                       end
                   end
               end
            elseif CODEBOOK_MODE >= 1 && CODEBOOK_MODE <= 2 && N2==1 && N1>2               
               for i11 = 0:i11Len
                   CBIndex = [i11,i11+O1,i11+2*O1,0,0,0];
                   Vlm = V(CBIndex(1),CBIndex(4),O1,N1,O2,N2);
                   Vlm2 = V(CBIndex(2),CBIndex(5),O1,N1,O2,N2);
                   Vlm3 = V(CBIndex(3),CBIndex(6),O1,N1,O2,N2);                   
                   for i2 = 0:i2Len  
                       PhiN = Phy(i2);
                       CodeBook = 1/sqrt(6*PortCSIRS)*[Vlm,Vlm,Vlm2,Vlm2,Vlm3,Vlm3;PhiN*Vlm,-PhiN*Vlm,PhiN*Vlm2,-PhiN*Vlm2,Vlm3,-Vlm3];  
                       CodeBookTotal = [CodeBookTotal,CodeBook];
                   end
               end               
            end 
        case 7
            %% 七层CSI上报
            i2Len = 1;
            if CODEBOOK_MODE >= 1 && CODEBOOK_MODE <= 2
                if N1>=4 && N2==1
                    if N1==4
                        i11Len = N1*O1/2-1;
                    else
                        i11Len = N1*O1-1;
                    end                     
                   for i11 = 0:i11Len      
                       CBIndex = [i11,i11+O1,i11+2*O1,i11+3*O1,0,0,0,0]; 
                       Vlm = V(CBIndex(1),CBIndex(5),O1,N1,O2,N2);
                       Vlm2 = V(CBIndex(2),CBIndex(6),O1,N1,O2,N2);
                       Vlm3 = V(CBIndex(3),CBIndex(7),O1,N1,O2,N2);
                       Vlm4 = V(CBIndex(4),CBIndex(8),O1,N1,O2,N2);                       
                       for i2 = 0:i2Len                           
                           PhiN = Phy(i2);
                           CodeBook = 1/sqrt(7*PortCSIRS)*[Vlm,Vlm,Vlm2,Vlm3,Vlm3,Vlm4,Vlm4;PhiN*Vlm,-PhiN*Vlm,PhiN*Vlm2,Vlm3,-Vlm3,Vlm4,-Vlm4];
                           CodeBookTotal = [CodeBookTotal,CodeBook];                           
                       end
                   end
                elseif N1>=2 && N2>=2
                    i11Len = N1*O1-1;
                    if N1==2 && N2==2                       
                       i12Len = N2*O2-1;  
                    elseif N1>2 && N2==2                       
                       i12Len = N2*O2/2-1;                         
                    elseif N1>2 && N2>2                       
                       i12Len = N2*O2-1;  
                    end
                    for i11 = 0:i11Len
                        for i12 = 0:i12Len
                            CBIndex = [i11,i11+O1,i11,i11+O1,i12,i12,i12+O2,i12+O2];   
                            Vlm = V(CBIndex(1),CBIndex(5),O1,N1,O2,N2);
                            Vlm2 = V(CBIndex(2),CBIndex(6),O1,N1,O2,N2);
                            Vlm3 = V(CBIndex(3),CBIndex(7),O1,N1,O2,N2);
                            Vlm4 = V(CBIndex(4),CBIndex(8),O1,N1,O2,N2);                            
                            for i2 = 0:i2Len
                               PhiN = Phy(i2);
                               CodeBook = 1/sqrt(7*PortCSIRS)*[Vlm,Vlm,Vlm2,Vlm3,Vlm3,Vlm4,Vlm4;PhiN*Vlm,-PhiN*Vlm,PhiN*Vlm2,Vlm3,-Vlm3,Vlm4,-Vlm4];
                               CodeBookTotal = [CodeBookTotal,CodeBook];                                
                            end
                        end
                    end
                end
            end
        case 8
            %% 八层CSI上报
            if CODEBOOK_MODE >= 1 && CODEBOOK_MODE <= 2
                i2Len = 1;
                if N1>=4 && N2==1
                    if N1==4 && N2==1
                       i11Len = N1*O1/2-1;                       
                    else 
                       i11Len = N1*O1-1;                                              
                    end
                    for i11 = 0:i11Len
                        CBIndex = [i11,i11+O1,i11+2*O1,i11+3*O1,0,0,0,0];
                        Vlm = V(CBIndex(1),CBIndex(5),O1,N1,O2,N2);
                        Vlm2 = V(CBIndex(2),CBIndex(6),O1,N1,O2,N2);
                        Vlm3 = V(CBIndex(3),CBIndex(7),O1,N1,O2,N2);
                        Vlm4 = V(CBIndex(4),CBIndex(8),O1,N1,O2,N2);                        
                        for i2 = 0:i2Len
                           PhiN = Phy(i2);
                           CodeBook = 1/sqrt(8*PortCSIRS)*[Vlm,Vlm,Vlm2,Vlm2,Vlm3,Vlm3,Vlm4,Vlm4;PhiN*Vlm,-PhiN*Vlm,PhiN*Vlm2,-PhiN*Vlm2,Vlm3,-Vlm3,Vlm4,-Vlm4];
                           CodeBookTotal = [CodeBookTotal,CodeBook];                            
                        end
                    end
                elseif N1>=2 && N2>=2
                    if N1==2 && N2==2
                        i11Len = N1*O1-1;
                        i12Len = N2*O2-1; 
                    elseif N1>2 && N2==2
                        i11Len = N1*O1-1;
                       i12Len = N2*O2/2-1;  
                    elseif N1>2 && N2>2
                        i11Len = N1*O1-1;
                        i12Len = N2*O2-1;                              
                    end
                    for i11 = 0:i11Len
                        for i12 = 0:i12Len
                            CBIndex = [i11,i11+O1,i11,i11+O1,i12,i12,i12+O2,i12+O2]; 
                            Vlm = V(CBIndex(1),CBIndex(5),O1,N1,O2,N2);
                            Vlm2 = V(CBIndex(2),CBIndex(6),O1,N1,O2,N2);
                            Vlm3 = V(CBIndex(3),CBIndex(7),O1,N1,O2,N2);
                            Vlm4 = V(CBIndex(4),CBIndex(8),O1,N1,O2,N2);                            
                            for i2 = 0:i2Len
                               PhiN = Phy(i2);
                               CodeBook = 1/sqrt(8*PortCSIRS)*[Vlm,Vlm,Vlm2,Vlm2,Vlm3,Vlm3,Vlm4,Vlm4;PhiN*Vlm,-PhiN*Vlm,PhiN*Vlm2,-PhiN*Vlm2,Vlm3,-Vlm3,Vlm4,-Vlm4];
                               CodeBookTotal = [CodeBookTotal,CodeBook];                                
                            end
                        end
                    end
                end
            end
    end
end

end
