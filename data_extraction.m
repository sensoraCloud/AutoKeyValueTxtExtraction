%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Main procedure for keys extraction%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%author: Rocco De Rosa

addpath(genpath('edit_distances'));
addpath(genpath('functions'));

%INPUT PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
threshold_distance=1; %min distances considered
max_number_words_solution=10; %max number of word for the solution value
use_stop_words=0; %=1: use stop word list dor stop criteria.
no_errors_lenght_permission=2; %no distance tollerance for words of lenght <= no_errors_lenght_permission
%read keywords
sinonimi=importdata('syns_Claim.xls');%excel of synonimus  prova_sin  syns_Claim
sinonimi=sinonimi.Sheet1;
fileList = getAllFiles('dataset'); %directory with documents to extract
stop_words=importdata('stop_words.txt'); %stop words file list
generate_check_points_debug=1;%=1: generate check points file for debugging
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



stop_words=regexp(stop_words,',','split');
stop_words=stop_words{:,:};
terms=[];

%convert all in lower case
stop_words=lower(stop_words);

atoms_keys=[];
position_keys=[];
atoms_code=[];
atom_code_table_sinonimi=[];
atom_code_table=[];

%split keys into atoms
code_number=1;
keys_name=sinonimi(:,1);
rows=size(sinonimi,1);
cols=size(sinonimi,2);

list_atoms_key=[];

for row=1:rows
    count_cols=1;
    for col=1:cols
        
        if  ~isempty(sinonimi{row,col})
            
            split=regexp(sinonimi{row,col},' ','split');
            num_splits=size(split,2);
            
            %number key
            atom_code_table(code_number,1)=row;
            %lenght key
            atom_code_table(code_number,2)=num_splits;
            
            atom_code_table_sinonimi{code_number,1}=sinonimi{row,col};
            
            count_position=1;
            for s=1:num_splits
                
                position_keys(row,count_cols)=count_position;
                atoms_code(row,count_cols)=code_number;
                count_position=count_position+1;
                atoms_keys{row,count_cols}=split{s};
                count_cols=count_cols+1;
                
                if isempty(list_atoms_key)
                    list_atoms_key=split(s);
                else
                    list_atoms_key(1,end+1)=split(s);
                end
                
            end
            
            code_number=code_number+1;
            
        end
    end
    
end

%delete from stop words element cointained into atom keys
size_stop_words=size(stop_words,2);

delete_list=[];

for s=1:size_stop_words
    
    if ismember(stop_words{s},list_atoms_key)==1
        delete_list=[delete_list s];
    end
    
end

stop_words(delete_list)=[];

delete_list=[];

num_docs=size(fileList,1);

doc_err=0;

%generate preprocess check files
if generate_check_points_debug==1
    
    %atoms key
    name_file= fullfile('check_point','preprocess','atoms_key.csv');
    cell2csv(name_file, atoms_keys, ',' , 2011 );
    
    %atoms code
    name_file= fullfile('check_point','preprocess','atoms_code.csv');
    culumn_names = [];
    [ debug ] = generate_check_file(name_file,atoms_code,culumn_names );
    
    %atome code synonimus
    name_file= fullfile('check_point','preprocess','atoms_synonymous.csv');
    cell2csv(name_file, atom_code_table_sinonimi, ',' , 2011 );
    
    %atome code table
    matrix=[[1:size(atom_code_table,1)]' atom_code_table];
    name_file= fullfile('check_point','preprocess','atom_code_table.csv');
    culumn_names = {'atome code' 'key code' 'lenght'};
    [ debug ] = generate_check_file(name_file,matrix,culumn_names );
    
    %position synonimus
    name_file= fullfile('check_point','preprocess','position_synonimus.csv');
    culumn_names = [];
    [ debug ] = generate_check_file(name_file,position_keys,culumn_names );
    
end

%for all documents in \dataset
for dd=1:num_docs
    
    current_report=1;
    solution_stack  = [];
    reports=[];
    reports{current_report}=[];
    distances=[];
    delete_list=[];
    
    nome_file=fileList{dd};
    
    %read document
    fid = fopen(nome_file);
    
    %unless delimiter
    terms =  textscan(fid, '%s','delimiter',[' '],'MultipleDelimsAsOne',1);
    
    terms=terms{:,:};
    
    terms=lower(terms);
    
    fclose(fid);
    
    
    doc_size=size(terms,1);
    
    %put char '*' in words preceded by the words containing the char ':' at
    %the end
    
    control_double_point=1;
    
    for t=1:(doc_size-1)
        
        if ~isempty(terms{t})
            
            if sum(terms{t}(1,end)==':')>0
                
                %delete ':'
                terms{t}=terms{t}(1,1:end-1);
                %add '*'
                terms{t+1}=['*' terms{t+1}];
                
            end
            
        end
        
    end
    
    rows=size(atoms_keys,1);
    cols=size(atoms_keys,2);
    
    distances=ones(rows,cols).*100;
    
    if generate_check_points_debug==1
        
        %create directory  check for document
        dirName=fullfile('check_point','docs_check',nome_file);
        
        if exist(dirName,'dir') ~= 7
            mkdir(dirName);
        end
        
        %doc atoms
        name_file= fullfile(dirName,'atoms_doc.csv');
        cell2csv(name_file, terms , ',' , 2011 );
        
    end
    
    
    for t=1:doc_size
        
        %create debug check files
        if ((generate_check_points_debug==1) && (t>1))
            
            %distances
            name_file= fullfile(dirName,'distances.csv');
            culumn_names=[];
            culumn_names{1} = ['t=' num2str(t-1)];
            [ debug ] = generate_check_file(name_file,distances,culumn_names );
            
            %solution stack
            name_file= fullfile(dirName,'solution_stack.csv');
            culumn_names=[];
            culumn_names{1} = ['t=' num2str(t-1)];
            [ debug ] = generate_check_file_from_cell(name_file,solution_stack,culumn_names );
            
            
            %final report
            name_file= fullfile(dirName,'final_report.csv');
            generate_check_report_file(t-1,name_file,  reports , nome_file , keys_name );
                        
        end
        
        
        if ~isempty(terms{t})
            
            %     %delete the char ':' , name: become name
            %     terms{t}=strrep(terms{t}, ':', '');
            
            %dec count of valid solution and activate them
            size_stack=size(solution_stack,1);
            
            for s=1:size_stack
                
                %active valid solution
                if  solution_stack{s,4}==1
                    solution_stack{s,5}=1;
                end
                
                %dec count of activated solution
                if  solution_stack{s,5}==1
                    solution_stack{s,3}=solution_stack{s,3}-1;
                end
                
            end
            
            current_atoms_activated=[];
            
            %calculate distances and update solution_stack
            for row=1:rows
                for col=1:cols
                    
                    if  ~isempty(atoms_keys{row,col})
                        
                        distances(row,col)=edit_distance_levenshtein(terms{t},atoms_keys{row,col});
                        
                        %for atoms of lenght<=no_errors_lenght_permission doesn't permit errors!  : != # ,
                        %id != fd
                        if ((size(terms{t},2)<=no_errors_lenght_permission)&&(size(atoms_keys{row,col},2)<=no_errors_lenght_permission))
                            distances(row,col)=distances(row,col)+1;
                        end
                        
                        %control if atoms is near doc term
                        if distances(row,col)<=threshold_distance
                            
                            [ solution_stack, reports , current_report ] = update_solution_stack( solution_stack , atoms_code(row,col) , atom_code_table(atoms_code(row,col),2) , atom_code_table(atoms_code(row,col),1) , position_keys , row , col ,atom_code_table , distances(row,col), reports , current_report ,atom_code_table_sinonimi);
                            
                            current_atoms_activated=[current_atoms_activated atoms_code(row,col)];
                            
                        end
                        
                    end
                end
            end
            
            %delete all not already valid solutions doesn't belong to the current activates codes
            size_stack=size(solution_stack,1);
            
            delete_list=[];
            for i=1:size_stack
                
                if ( (sum(current_atoms_activated==solution_stack{i,1})==0)  &&  (solution_stack{i,5}==0))
                    delete_list=[delete_list;i];
                end
                
            end
            
            solution_stack(delete_list,:)=[];
            
            %write current value into active solution and save finished solution
            if isempty(solution_stack)
                active_sol=[];
            else
                %descend order of solutions by distance
                [f g]=sort(cell2mat(solution_stack(:,7)));
                solution_stack=solution_stack(g(end:-1:1),:);
                
                active_sol=find(cell2mat(solution_stack(:,5))==1);
            end
            
            if ~isempty(active_sol)
                
                delete_list=[];
                
                %delete the following cases:
                %1- two active solutions for the same key (occurs when there
                %are sinomimi with distance <= 1), in that case only one randomly
                
                %2- two active solutions for different keys of which one has
                % distance less than the other, in that case to assume that the
                % minimum distance is correct. may also happen that two solutions
                % refer to different keys are both correct and thus
                % If I keep both (all those minimum distance)
                
                %NOTE: I do not have to disable active keys with different count ..
                % because those cases are already checked in the previous procedures
                % (eg key subset of another, etc. ..) and in a case to come
                % new solution then that would be triggered and the other saved or
                % deleted
                
                %1- control if there are more than one solution activated with the same key
                %and the same lenght (the same lenght because for keys with different lenght the longer one wins)  (es. refence code  -  reference cod), delete
                %duplicate keys (the solution are orderd by distances so the distancer one are deleted)
                
                real_keys=cell2mat(solution_stack(active_sol,2));
                
                %add the lenght info
                real_keys=[real_keys  atom_code_table(cell2mat(solution_stack(active_sol,1)),2)];
                
                new_real_keys=[];
                
                for rk=1:size(real_keys,1)
                    new_real_keys(rk,1)=str2num(regexprep((num2str(real_keys(rk,:))),' ',''));
                end
                
                [e unic_pos d]=unique(new_real_keys);
                
                delete_list=[delete_list; setdiff(active_sol,active_sol(unic_pos))];
                
                active_sol=active_sol(unic_pos);
                
                %2- control if there are more than one solution activated with
                %different keys with the same count (activated togheter) (es. our reference  -  yuor
                %reference  are associated to different keys and for es. the true key is our reference.. for distance approximations can be both activated), in this cases take only the set of keys that have the
                %minimum distance (exist case where more than one different keys is correct  (es.  your reference is associated to: CLAIMNUMBERSYN and YOURREF ))
                
                %same count=same lenght and same time activation..
                counts=cell2mat(solution_stack(active_sol,3));
                
                %find count value with the same counts
                [cum val]=hist(counts.*-1,unique(counts.*-1));
                
                same_count=val(cum>1)*-1;
                
                
                if ~isempty(same_count)
                    
                    %consider the keys with the same count
                    unic_pos =find(counts==same_count);
                    
                    considered_sol=active_sol(unic_pos);
                    
                    distances=cell2mat(solution_stack(considered_sol,7));
                    
                    minimum_dist=min(distances);
                    
                    %take only keys with minimum distances
                    min_dist_pos=find( cell2mat(solution_stack(considered_sol,7)) == minimum_dist );
                    
                    considered_sol_2=considered_sol(min_dist_pos);
                    
                    %consider the solutions with greater lenght (es. Your Contract(key1,key2) Ref(key18):)
                    lenghts=atom_code_table(cell2mat(solution_stack(considered_sol_2,1)),2);
                    
                    max_lenght=max(lenghts);
                    
                    %take only keys with minimum distances and max lenght
                    max_lenght_pos=find( lenghts == max_lenght );
                    
                    %if there are more than one solution take only one (assume that doesn't exist different key can activated simultanly)
                    max_lenght_pos=max_lenght_pos(1);
                    
                    %delete solutions with the same lenght and distances different from
                    %minimum
                    
                    delete_list=[delete_list; setdiff(considered_sol,considered_sol_2(max_lenght_pos))];
                    
                    active_sol=union( setdiff(active_sol,considered_sol) ,intersect(active_sol,considered_sol_2(max_lenght_pos)));
                    
                    %if row array transpose it
                    if size(active_sol,2)>1
                        active_sol=active_sol';
                    end
                    
                end
                
                size_active_sol=size(active_sol,1);
                
                %3- if exixts more than one active solutions grouped for associated key control if old keys is
                %subset of new key or we have founded another solution
                
                if size_active_sol>1
                    
                    count_1=solution_stack{active_sol(1),3};
                    count_2=solution_stack{active_sol(2),3};
                    
                    if count_1<count_2
                        new_sol=active_sol(2);
                        old_sol=active_sol(1);
                    else
                        new_sol=active_sol(1);
                        old_sol=active_sol(2);
                    end
                    
                    lenght_new=atom_code_table(solution_stack{new_sol,1},2);
                    lenght_old=atom_code_table(solution_stack{old_sol,1},2);
                    
                    count_new=solution_stack{new_sol,3};
                    count_old=solution_stack{old_sol,3};
                    
                    %if old key is a subset of new key delete old key else save old key
                    if (lenght_new>=(abs(count_old)+lenght_old-1))
                        %delete old solution
                        [a old_pos]=min(cell2mat(solution_stack(active_sol,3)));
                        delete_list=[delete_list;active_sol(old_pos)];
                        active_sol=setdiff(active_sol,active_sol(old_pos));
                    else
                        %save old solution and delete new key from value of old
                        %solution
                        [a old_pos]=min(cell2mat(solution_stack(active_sol,3)));
                        old_idx=active_sol(old_pos);
                        active_sol=setdiff(active_sol,old_idx);
                        lenght_new_sol=atom_code_table(solution_stack{active_sol,1},2);
                        
                        %!! if lenght new solution == lenght value old
                        %solution we have two contiguos keys. delete
                        %old solution
                        size_value_new_sol=size(solution_stack{old_idx,6},2);
                        
                        if size_value_new_sol==lenght_new_sol
                            
                            delete_list=[delete_list;old_idx];
                            
                        else
                            
                            solution_stack{old_idx,6}=solution_stack{old_idx,6}(1:end-(lenght_new_sol));
                            [ reports , current_report ] = update_reports( reports , atom_code_table(solution_stack{old_idx,1},1) , solution_stack{old_idx,6} , current_report , atom_code_table_sinonimi{solution_stack{old_idx,1},1} );
                            %delete saved solution
                            delete_list=[delete_list;old_idx];
                            
                        end
                        
                    end
                    
                end
                
                %add value to solution
                if isempty(solution_stack{active_sol,6})
                    solution_stack{active_sol,6}=terms(t);
                else
                    solution_stack{active_sol,6}(1,end+1)=terms(t);
                end
                
                
                %stop criterion control
                stop=0;
                
                %word present in stop words list
                if ((sum(strcmp(terms{t},stop_words))>0)&&(use_stop_words==1))
                    stop=1;
                end
                
                %there is a punctuation point in the end of the word
                %                 if sum(terms{t}(1,end)=='.')>0
                %                     stop=1;
                %                 end
                
                
                %                 %there is a ':' in the end of the word (for as is '*' in the start of the word)
                %                 if sum(terms{t}(1,1)=='*')>0
                %                     if control_double_point==0
                %                         stop=1;
                %                         control_double_point=1;
                %                     else
                %                         control_double_point=0;
                %                     end
                %                 end
                
                %max number words solution
                if size(solution_stack{active_sol,6},2)>=max_number_words_solution
                    stop=1;
                end
                
                %end of document
                if t==size(terms,1)
                    stop=1;
                end
                
                if stop==1
                    %save solution into report and control if new section
                    [ reports , current_report ] = update_reports( reports ,  atom_code_table(solution_stack{active_sol,1},1) , solution_stack{active_sol,6} , current_report , atom_code_table_sinonimi{solution_stack{active_sol,1},1} );
                    %delete saved solution
                    delete_list=[delete_list;active_sol];
                end
                
                solution_stack(delete_list,:)=[];
                
            end
            
        else
            
            distances=zeros(size(atoms_code,1),size(atoms_code,2));
            
        end
        
    end
    
    %update or generate report CSV
    generate_report( reports , nome_file , keys_name );
    
end

