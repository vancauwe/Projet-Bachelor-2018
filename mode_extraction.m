function [dates,modes,colors] = mode_extraction(txt)

index=890;
%timestamps, colors and modenames that correspond to a mode SELECTION
%color_vect={}; txt_date_vect={}; mode_vect={}; 
index_vect=[];
j=1;
while(length(txt)>=index)
    %reach the first timestamp of subwkv
    entry=txt{index};
    entry_decompo=strsplit(entry,' ');
    txt_date=entry_decompo{1,1};
    
    if(~(length(entry_decompo)==1))
        i=3;
        comment=entry_decompo{1,2};
        if(strcmp(comment,'Selected'))

            while (i<=length(entry_decompo))
                comment = [comment  ' ' entry_decompo{1,i}];
                i=i+1;
            end

            comment_decompo=strsplit(comment,': ');
            mode=comment_decompo{1,2};

            switch mode
                case 'fast gait'
                    color='yellow';                
                case 'rough terrain'
                    color='magenta';               
                case 'sofa sitting'
                    color='green';
                case 'slope ascent'
                    color='blue';
                case 'fast stairs ascent'
                    color='red';
                case 'stool sitting'
                    color='cyan';
                otherwise
                    errordlg(['The mode ' mode ' is not specified in the program. Please add the case in the code.'],'New mode not in the program.');
                    return; 
            end
            
            color_vect{1,j}=color;
            txt_date_vect{1,j}= txt_date;
            mode_vect{1,j}= mode;
            %save indexes to start closer
            index_vect(j)=index;
            j=j+1;

        end
    end
    index=index+1;
end
  
j=1; i=1;
%dates, colors, and modes that will appear on the graph because they
%were selected and ENTERED

while(j<=length(index_vect))

    if( (j~=length(index_vect)) && (index_vect(j+1)-index_vect(j))==1)
        j=j+1; 
        %if selected on after the other than not possible that mode j was entered, skip to mode j+1

    else
        start=index_vect(j);
        while(start<=length(txt))
            entry=txt{start};

            entry_decompo=strsplit(entry,' ');
            txt_date=entry_decompo{1,1};

            %only process if the line is relevant hence if it shows a mode
            %being entered through 'Entering'
            if(~(length(entry_decompo)==1))
                comment=entry_decompo{1,2};

                if(strcmp(comment,'Entering'))
                    k=3;
                    %reassemble the second part after date
                    while (k<=length(entry_decompo))
                        comment = [comment  ' ' entry_decompo{1,k}];
                        k=k+1;
                    end

                    wanted=['Entering ' mode_vect{1,j} ' mode.']; 
                    if(strcmp(comment,wanted))
                        dates{1,i}=txt_date;
                        colors{1,i}=color_vect{1,j};
                        modes{1,i}=mode_vect{1,j};
                        i=i+1;
                    end
                end    
            end
            start=start+1;
        end
        j=j+1;
    end
end

if(~(exist('dates', 'var')))
    dates={};
end

if(~(exist('colors', 'var')))
    colors={};
end

if(~(exist('modes', 'var')))
    modes={};
end

end