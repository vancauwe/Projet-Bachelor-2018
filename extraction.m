function [dates,modes,colors,endMode,left,right,startCadTime,endCadTime, LeftS, RightS] = extraction(txt)


%% Initialisation
index=1; j=1; o=1; l=1; p=1;
%no steps if no walking
left=0; right=0;
%logicals
entered=0;
walking=0;


while(length(txt)>=index)
    %Reach the first timestamp of subwkv
    entry=txt{index};
    entry_decompo=strsplit(entry,' ');
    txt_date=entry_decompo{1,1};
    
    if(~(length(entry_decompo)==1))
        i=3;
        comment=entry_decompo{1,2};
        
        switch comment
            
            case 'Entering'
%% Get the information of Entering the modes            
                entered=1;
                mode=entry_decompo{1,i};
                
                k=4;
                while (k<=(length(entry_decompo)-1))
                    mode = [mode  ' ' entry_decompo{1,k}];
                    k=k+1;
                end
                
                while (i<=length(entry_decompo))
                    comment = [comment  ' ' entry_decompo{1,i}];
                    i=i+1;
                end
                
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
                    case 'fast stairs descent'
                        color= '+r';
                    case 'stool sitting'
                        color='cyan';

                    otherwise
                        errordlg(['The mode ' mode ' is not specified in the program. Please add the case in the code.'],'New mode not in the program.');
                        return; 
                end

                dates{1,j}=txt_date;
                colors{1,j}=color;
                modes{1,j}=mode;
                j=j+1;
            
            
            case 'Starting'
%% For beginning of cadence measurement by "Starting first step"
                
                if(isequal(entry_decompo{1,3},'first'))
                    startCadTime{1,l}=txt_date;
                    l=l+1;
                   
                end
                
            case 'Mode'
%% For end of cadence (if walking) or know if mode entered and then exited
%signals that mode correctly exited

            if(isequal(entry_decompo{1,3},'exited...') && isequal(entered,1))
                endMode{1,p}=txt_date;
                p=p+1;
                if(isequal(walking,1))
                    endCadTime{1,o}= endTime;
                    o=o+1;
                       
                end
            end
                
            case 'Ending'
%% Count steps left and right seperately based on when they end
                
                walking=1;
                
                %each time ending step could be the last so save the txt_date.
                endTime=txt_date; 
               
                while (i<=length(entry_decompo))
                    comment = [comment  ' ' entry_decompo{1,i}];
                    
                    i=i+1;
                end
                
                switch entry_decompo{1,3} 
                    case 'left'
                        left=left+1;
                        LeftS{1,left}=txt_date;
                    case 'right'
                        right=right+1;
                        RightS{1,right}=txt_date;
                end
            
        end
    end
    index=index+1;
    
end



%% If some variables unaffected then intilialize to empty 
if(~(exist('dates', 'var')))
    dates={};
end

if(~(exist('colors', 'var')))
    colors={};
end

if(~(exist('modes', 'var')))
    modes={};
end

if(~(exist('endMode', 'var')))
    endMode={};
end

if(~(exist('startCadTime', 'var')))
    startCadTime= ' ';
end

if(~(exist('endCadTime', 'var')))
    endCadTime= ' ';
end

if(~(exist('LeftS', 'var')))
    LeftS={};
end

if(~(exist('RightS', 'var')))
    RightS={};
end

end