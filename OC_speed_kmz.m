%Divide the hparam.in file that has all storm tracks
%into individual track files into 'hparam_sep' folder.
%Create Google Earth kmz file that includes all storm tracks with 
%landfall locations and Rmax at landfall.
%Output individual track as 'JPMSTORM***', individual
%forward speed as 'speed_JPMSTORM***', lat/lon as 
%'track_JPMSTORM', and landfall angles as 'landfall_angle'.

clear

fid = fopen('hparams.in','r');%open file that has all storm tracks
storm_num = 0;
time_step = 114;%time length of track 
date = nan(time_step,1);
lat = nan(time_step,1);
lon = nan(time_step,1);
Pc = nan(time_step,1);
Rmax = nan(time_step,1);
k = kml('OC_storms');%name of kmz file
a = 6378.1370;%eqautorial radius (km)
e_sq = 0.00669437999014;
dt = 1;%time interval in day


figure
hold on

if ~exist('hparam_sep','dir')
    mkdir('hparam_sep') 
end

fid_ang = fopen('hparam_sep\landfall_angle','w');%creat output file

while 1
    tline = fgetl(fid);
    if tline ~= -1
        if ~isempty( strfind(tline,'STORM') )
            ind_eq = strfind(tline,'=')+1;
            header_tmp = textscan( tline(ind_eq:end),'%d %d %d %d %f %f');
            storm_num = storm_num+1;%count storm number
            
            name = sprintf('%03d', storm_num);
            
            fid_sep = fopen(['hparam_sep\JPMSTORM' name],'w');
            fid_track = fopen(['hparam_sep\track_JPMSTORM' name],'w');
            fid_speed = fopen(['hparam_sep\speed_JPMSTORM' name],'w');
            
            fprintf(fid_sep,'%s \n',tline);
            
            for i=1:time_step
                s_line=fgetl(fid);
                storm=textscan(s_line,'%d %f %f %f %f %f');
                %read track info in each line
                date(i)=storm{1};
                lat(i)=storm{2};
                lon(i)=storm{3};
                Pc(i)=storm{4};
                Rmax(i)=storm{5};
                fprintf(fid_sep,'%s \n',s_line);
                fprintf(fid_track,'%f   %f \n',[lon(i) lat(i)]);
            end
            
            lat_diff = abs(diff(lat));
            lon_diff = abs(diff(lon));
            dist_lat = lat_diff/360 * 2 * pi * a/1.852; %convert from km to nmile
            dist_lon = lon_diff/360 * 2 * pi * a.* cosd(lat(1:end-1))/1.852;
            speed = sqrt(dist_lat.^2 + dist_lon.^2) / dt;
            
            fprintf( fid_speed,'%d \t %f \n',[date(1:end-1) speed]' );
            display( [name ' speed : ' num2str(mean(speed))] )
            plot(speed);
            ylabel('speed (nm/h)')
            xlabel('hour')
            ind = find(diff(Pc)>0,1) + 1;
            ver = diff(lat)/360 * 2 * pi * a;
            hor = diff(lon)/360 * 2 * pi * a.* cosd(lat(1:end-1));
            angle = 180 - atand( ver(ind(1)-1)/hor(ind(1)-1) );
            
            fprintf(fid_ang,'%d \t %f \t %d \n',[storm_num, angle, header_tmp{3}]);
            
            k.point(lon(ind(1)),lat(ind(1)),100,...
                'name',num2str(storm_num),...
            'description',['R=' num2str(Rmax(ind(1)))],'labelScale',0,...
            'iconScale',0.3);%creats landfall locations in kmz
            k.plot3(lon,lat,ones(size(lon))*100.0,'name',num2str(storm_num),...
                'description',tline);%creats tracks in kmz 

            fclose(fid_sep);
            fclose(fid_track);
            fclose(fid_speed);
        end
    else
        break
    end
end

fclose all;
k.save;