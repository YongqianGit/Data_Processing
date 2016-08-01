%Plot hydrographs from fort.61.dat files
%for all stations.


clear
close all
scrsz = get(0,'ScreenSize');
lgd_1 = '016';
lgd_2 = '016.notide';
data_1 = load(['fort.61.' lgd_1]);%Load the first fort.61.dat 
data_2 = load(['fort.61.' lgd_2]);%Load the second fort.61.dat 


t_1 = data_1(:,1)-15;
t_2 = data_2(:,1);
stat_num = size(data_1,2)-1;
plot_num = floor(stat_num/5);
stat_cnt = 0;
fid = fopen('stat_list.txt','r');
stat_name = cell(stat_num,1);

fid_15 = fopen('fort.15','r');%Load fort.15 to get station names
interest = 'NUMBER OF ELEVATION RECORD';%Comment line in fort.15 to 
%identify stations
k = kml('stations');


while 1
    tline = fgetl(fid_15);
    if strfind(tline,interest)
        disp(tline);
        NSTAE = textscan(tline(1:strfind(tline,interest)),'%f8');
        NSTAE = cell2mat(NSTAE);
        break
    elseif tline==-1
        error('no stat found in fort.15')
    end
end

stat_interest = {'StLucie-1','StLucie-2'};
stat_find = ['StLucie-1' 'StLucie-2'];

for i = 1 : NSTAE
    tline = fgetl(fid_15);
    stat_tmp = tline( strfind(tline,'!')+1:end );
    stat_tmp( strfind(stat_tmp,'_') ) = '-';
    stat_name{i} = stat_tmp;
    loc = textscan(tline,'%f %f');
    k.point(loc{1},loc{2},10,'description',stat_tmp,...
        'labelscale',0,'iconscale',0.5);
end
fclose(fid_15); 


for i = 1 : plot_num
    
    for j = 1 : 5
        figure(i)
        stat_cnt = stat_cnt + 1;
        subplot(5,1,j)
        hold on
        plot( t_1,data_1(:,stat_cnt+1) )
        plot( t_2,data_2(:,stat_cnt+1),'r--' )
        hd = legend(lgd_1,lgd_2);
        set(hd,'location','eastoutside','fontsize',8)
        xlabel('t (d)','fontsize',12)
        ylabel('water ele (m)','fontsize',12)
        
        ymin = min(max([min(data_2(:,stat_cnt+1))-0.1,-10]),...
            max([min(data_1(:,stat_cnt+1))-0.1,-10]));
        ymax = max(max([max(data_2(:,stat_cnt+1))+0.1,0]),...
            max([max(data_1(:,stat_cnt+1))+0.1,0]));
        
        ylim([ymin ymax]);
        xlim([0 5])
%        xlim([min(min(t_1),min(t_2)) max(max(t_1),max(t_2))+2]);
        title(stat_name{stat_cnt},'fontsize',12)
        %{

        if(~isempty(strfind(stat_find,strtrim(stat_name{stat_cnt}))))
            figure(1000+stat_cnt)
            hold on
            plot(t_1,data_1(:,stat_cnt+1))
            plot(t_2,data_2(:,stat_cnt+1),'r--')
            hd=legend(lgd_1,lgd_2);
            set(hd,'location','eastoutside','fontsize',8)
            xlabel('t (d)','fontsize',12)
            ylabel('water ele (m)','fontsize',12)
            ylim([-2 6]);
            xlim([0,5]);
            title(stat_name{stat_cnt},'fontsize',12)
        end
        %}
    end
    set(gcf,'Position',[1 1 scrsz(3)*0.4 scrsz(4)*0.95]);
    set(gcf,'units',get(gcf,'paperunits'));
    set(gcf,'paperposition',get(gcf,'position'));
end

if stat_cnt < stat_num
    figure
    for i = 1:stat_num-stat_cnt
        subplot(stat_num-stat_cnt,1,i);hold on
        
        plot(t_1,data_1(:,stat_cnt+i+1))
        plot(t_2,data_2(:,stat_cnt+i+1),'r--')
        
        hd = legend(lgd_1,lgd_2);
        set(hd,'location','eastoutside','fontsize',8)
        xlabel('t (d)','fontsize',12)
        ylabel('water ele (m)','fontsize',12)
        
        ymin = min(max([min(data_2(:,stat_cnt+i+1))-0.1,-10]),...
            max([min(data_1(:,stat_cnt+i+1))-0.1,-10]));
        ymax = max(max([max(data_2(:,stat_cnt+i+1))+0.1,0]),...
            max([max(data_1(:,stat_cnt+i+1))+0.1,0]));
        
        ylim([ymin ymax]);
        xlim([0 5])
%        xlim([min(min(t_1),min(t_2)) max(max(t_1),max(t_2))+2]);
        title(stat_name{stat_cnt+i},'fontsize',12)
    end
end
k.save

