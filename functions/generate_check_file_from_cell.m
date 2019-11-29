function [ debug ] = generate_check_file_from_cell(name_file,cell_matrix,culumn_names )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if (exist(name_file,'file')==0)
    
    fid = fopen(name_file,'w');
    
    %make title
    for j=1:length(culumn_names)
        fprintf(fid,'%s',[culumn_names{j} ',']);
    end
    
    if ~isempty(culumn_names)
        fprintf(fid,'\n');
    end
    
else
    
    fid = fopen(name_file,'a');
    
    %make title
    for j=1:length(culumn_names)
        fprintf(fid,'%s',[culumn_names{j} ',']);
    end
    
    if ~isempty(culumn_names)
        fprintf(fid,'\n');
    end
    
end

num_rows=size(cell_matrix,1);
num_cols=size(cell_matrix,2);

for r=1:num_rows
    
    str_value=[];
    
    for c=1:num_cols
        
        
        if isnumeric(cell_matrix{r,c})
            
            if c==1
                
                str_value=num2str(cell_matrix{r,c});
                
            else
                
                str_value=[str_value ',' num2str(cell_matrix{r,c})];
                
            end
            
        else
            
            value=cell_matrix{r,c};
            str_value_tmp=[];
            
            for v=1:size(value,2)
                if v==1                    
                    str_value_tmp=strrep(value{v}, ',', '.');
                else
                    str_value_tmp=[str_value_tmp ' ' strrep(value{v}, ',', '.')];                   
                end
            end
            
            str_value=[str_value ',' str_value_tmp];
            
        end        
        
    end
    
    fprintf(fid,'%s',str_value);
    fprintf(fid,'\n');
    
end

fclose(fid);

debug=1;

end

