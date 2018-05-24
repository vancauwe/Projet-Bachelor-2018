function[loadpersec,stamps]=loadProcess(wkv)

tot_aL=0; tot_bL=0; tot_cL=0; tot_dL=0;
tot_aR=0; tot_bR=0; tot_cR=0; tot_dR=0;
tot_elements=0;

 %left
[cellaL, ~]=wkv_get(wkv, 'controller/left_load_cells/a');
[cellbL, ~]=wkv_get(wkv, 'controller/left_load_cells/b');
[cellcL, ~]=wkv_get(wkv, 'controller/left_load_cells/c');
[celldL, ~]=wkv_get(wkv, 'controller/left_load_cells/d');
%right
[cellaR, ~]=wkv_get(wkv, 'controller/right_load_cells/a');
[cellbR, ~]=wkv_get(wkv, 'controller/right_load_cells/b');
[cellcR, ~]=wkv_get(wkv, 'controller/right_load_cells/c');
[celldR, ~]=wkv_get(wkv, 'controller/right_load_cells/d');
%timestamps
[allstamps, ~]=wkv_get(wkv, 'timestamp');

j=1; i=1;
while(j<size(allstamps,2))

    if(isequal(datestr(allstamps(j)),datestr(allstamps(j+1))))
        tot_aL=tot_aL+cellaL(j); tot_bL=tot_bL+cellbL(j); tot_cL=tot_cL+cellcL(j); tot_dL=tot_dL+celldL(j);
        tot_aR=tot_aR+cellaR(j); tot_bR=tot_bR+cellbR(j); tot_cR=tot_cR+cellcR(j); tot_dR=tot_dR+celldR(j);
        tot_elements=tot_elements+1;
        if(isequal(j+1,size(allstamps,2)))
            tot_aL=tot_aL+cellaL(j+1); tot_bL=tot_bL+cellbL(j+1); tot_cL=tot_cL+cellcL(j+1); tot_dL=tot_dL+celldL(j+1);
            tot_aR=tot_aR+cellaR(j+1); tot_bR=tot_bR+cellbR(j+1); tot_cR=tot_cR+cellcR(j+1); tot_dR=tot_dR+celldR(j+1);
            tot_elements=tot_elements+1;
            
            av_aL=tot_aL/tot_elements; av_bL=tot_bL/tot_elements;
            av_cL=tot_cL/tot_elements; av_dL=tot_dL/tot_elements;
        
            av_aR=tot_aR/tot_elements;  av_bR=tot_bR/tot_elements;
            av_cR=tot_cR/tot_elements;  av_dR=tot_dR/tot_elements;
        
            %save the stamp and the averages as a matrix
            stamps(i)=allstamps(j+1); 
            loadpersec(i,1:8)=[av_aL av_bL av_cL av_dL av_aR av_bR av_cR av_dR];
        end
        
        j=j+1;
    else
        %add the last element j
        tot_aL=tot_aL+cellaL(j); tot_bL=tot_bL+cellbL(j); tot_cL=tot_cL+cellcL(j); tot_dL=tot_dL+celldL(j);
        tot_aR=tot_aR+cellaR(j); tot_bR=tot_bR+cellbR(j); tot_cR=tot_cR+cellcR(j); tot_dR=tot_dR+celldR(j);
        tot_elements=tot_elements+1;
        
        av_aL=tot_aL/tot_elements; av_bL=tot_bL/tot_elements;
        av_cL=tot_cL/tot_elements; av_dL=tot_dL/tot_elements;
        
        av_aR=tot_aR/tot_elements;  av_bR=tot_bR/tot_elements;
        av_cR=tot_cR/tot_elements;  av_dR=tot_dR/tot_elements;
        
        %save the stamp and the averages as a matrix
        stamps(i)=allstamps(j); 
        loadpersec(i,1:8)=[av_aL av_bL av_cL av_dL av_aR av_bR av_cR av_dR];
        %update the indexes
        i=i+1;
        j=j+1;
        
    end
end
end