%Plot hydrographs of hunders of fort.61 files
%for each individual station. Output figures 
%include both WSE curves and 2D contours.



clear
%plot all WSE of fort.61 from hundreds of storms

dirc{1} = './East/Fort61dat/';
dirc{2} = './West/Fort61dat/';
stat_sel = [10 14];
t_sel = [2 2.5];
crit = 0.5;

for i_dirc = 1 : size(dirc,2)
    cd(dirc{i_dirc});
    
    file_list=ls('fort.61.dat_*');
    
    if ~exist('Plots','dir')
        mkdir('Plots')
    end
    
    [sz_t, sz_stat] = size( load( file_list(1,:) ) );

    data_all = zeros( sz_t,sz_stat,size( file_list,1 ) );
    
    fid = fopen( 'Problematic_id.txt','w' );
    
    for i_storm = 1 : size(file_list,1)
        
        data_all(:,:,i_storm) = load( file_list(i_storm,:) );
        
        if i_storm == 1        
            t_end_id = find( data_all(:,1,i_storm)>=t_sel(2), 1 );
        end
        
        if max( data_all(1:t_end_id,stat_sel(i_dirc),i_storm) > crit )
            fprintf(fid,'%s \n',[num2str(i_storm) '    ' file_list(i_storm,:)]);
        end
        
    end
    
    fclose(fid);
%{ /   
    %plot figures of all storms based on station
    for i_stat = 1 : sz_stat-1
        figure
        scrsz = get(0,'ScreenSize');
        set(gcf,'Position',[10 50 scrsz(3)*0.4 scrsz(4)*0.65])
        subplot(2,1,1)
        hold on
        title(['WSE at Station ' num2str(i_stat)])
        for i_storm = 1 : size(file_list,1)
            plot(data_all(:,1,1),data_all(:,i_stat+1,i_storm))          
        end
        ylim([-2 4])
        
        subplot(2,1,2)
        surf(data_all(:,1,1),1:size(file_list,1),...
            reshape(data_all(:,i_stat+1,:),sz_t,size(file_list,1))')
        xlabel('time (day)','fontsize',14)
        ylabel('storm id','fontsize',14)
        colorbar
        shading flat
        view(0,90)
        caxis([-2,4])
        print('-dpng',['Plots/Contour_Stat' num2str(i_stat) '.png'],'-r600');
    end
%}

end



