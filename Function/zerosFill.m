function [str] = zerosFill(fig)
    if fig<10
        str=strcat('0',num2str(fig));    
    else 
        str=num2str(fig);  
    end
end

