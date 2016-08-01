%Check and print a list of problematic storms
%that have no drop/increase in Vf / Cp.
%Create kmz file that includes other storms'
%landfall locations.


%{/

clear
dirc{1} = '/East';
dirc{2} = '/West';
%Directories of files to read. Doing this can avoid the necessity to
%put the Matlab script together with the files in the same folder.

ang = {'east','west'};
tic

%}


for i_dirc = 1 : size(dirc,2)
    
    cd( dirc{i_dirc} )
    file_list = ls('fort.22*');
    
    k = kml( ['landfall_' ang{i_dirc}] );

    bad_count = 0;
    
    for i = 1:size(file_list,1)
        fid = fopen(file_list(i,:));
        
        data=textscan(fid,'%22c %f64 %f %f %f64 %f %f64 %f64');
        
        if isempty( find(diff( data{5}) < 0, 1) ) || ...
                isempty( find( diff(data{6}) > 0, 1 ) )
            %save a list of problematic storms 
            bad_count = bad_count + 1;
            bad_list{bad_count} = file_list(i,:);
            % Unknown numbers of bad storm tracks, so did NOT preallocate.
            % Increase a bit running time in this case.
        %{/
        else
            lat = data{3};
            lon = data{4}; 
            ind = find( diff(data{5}) < 0, 1 ) + 1;
            
            k.point(-lon(ind(1))/1000.0,lat(ind(1))/1000.0,100,'name',file_list(i,:),...
            'id',file_list(i,9:end),'description',file_list(i,:),'labelScale',0,...
            'iconScale',0.3);
        %}
        end
        
        fclose(fid);
    end
    

    fid_out = fopen('const_Vf_Pc.txt','w+');
    fprintf( fid_out,'%s \n',bad_list{:} );
    %print a list of the problematic storms into 'const_Vf_Pc.txt'.
    fclose(fid_out);
    clear file_list bad_list
    k.save
end
toc
