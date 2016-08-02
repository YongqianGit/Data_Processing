% Visualization of numerical modeling results, i.e., modeling
% of wave propagation/inundation from offshore to inland.
% Also Creates animation vidoes in format of '.avi' or other
% equivalent video formats
% Collaboration with other researchers on analyzing results

clear

scrsz = get(0,'Screensize');
load time.dat
nt = length(time); % total time steps of simulation
if nt == 0
    nt = 10000;
end

load s.dat

N_levels = s(2);
num_procs = s(3);
% Number of processors in MPI parallel computation

wave_map = zeros(63,3);
wave_map(1,:) = [0 0 .5625];
wave_map(64,:) = [1 1 1];

for i = 2 : 63
    for n = 1 : 3
        wave_map(i,n) = wave_map(1,n) + (i-1) * ...
            ( wave_map(64,n) - wave_map(1,n) ) / 63;
    end
end

colormap(wave_map)  % for blue / water-like surface   %the map for the figures

% Read outputs of parallel computation using MPI
% All outputs in binary format

fid  = zeros(5 * num_procs);
fid2 = zeros(3 * num_procs);
fid3 = zeros(1 * num_procs);

for rank = 0 : num_procs - 1
    
    file_ind = sprintf('%03d', rank);

    eval(['load xloc' file_ind '.dat'])
    eval(['load yloc' file_ind '.dat'])

    filename = ['dpth' file_ind '.dat'];
    fid(5*rank+1) = fopen(filename, 'r');

    filename = ['zeta' file_ind '.dat'];
    fid(5*rank+2) = fopen(filename, 'r');         % open the file

    filename = ['velo' file_ind '.dat'];
    fid(5*rank+3) = fopen(filename, 'r');         % open the file

    filename = ['blvs' file_ind '.dat'];
    fid(5*rank+4) = fopen(filename, 'r');        % open the file

    filename = ['vort' file_ind '.dat'];
    fid(5*rank+5) = fopen(filename, 'r');        % open the file
 
    
%---------------New binary outputs added in 2014
    filename = ['all_friction' file_ind '.dat'];
    fid2(3*rank+1) = fopen(filename, 'r');        % open the file
    
    filename = ['roughnessCoef' file_ind '.dat'];
    fid2(3*rank+2) = fopen(filename, 'r');        % open the file
    
    filename = ['shadow' file_ind '.dat'];
    fid2(3*rank+3) = fopen(filename, 'r');        % open the file
    
    filename = ['all_friction' file_ind '.dat'];
    fid3(rank+1) = fopen(filename, 'r');   
    
%----------------------------------------------

end



% plot initial depth and determine glocal axis limits

for rank=0:num_procs-1
    ind = ['00' num2str(rank)];
    file_ind = ind(length(ind)-2:length(ind));
 
    eval(['x=xloc' file_ind ';'])
    eval(['y=yloc' file_ind ';'])

    nx = length(x);
    ny = length(y);

    ho = zeros(nx,ny);

    dum = fread(fid(5*rank+1),1,'int32');
    ho(:,:) = fread(fid(5*rank+1),[nx,ny],'single');
    dum = fread(fid(5*rank+1),1,'int32');

    figure(100)
    hold on
    surf(x,y,transpose(-ho(:,:)))
    view(0,90)
    shading flat
    % Check initial bathymetry

    %-----------------% Check shadow and roughness condition in the domain
        dum=fread(fid2(3*rank+2),1,'int32');
        roughnessCoef=fread(fid2(3*rank+2),[nx,ny],'single');
        dum=fread(fid2(3*rank+2),1,'int32');
        
        dum=fread(fid2(3*rank+3),1,'int32');
        shadow=fread(fid2(3*rank+3),[nx,ny],'int32');
        dum=fread(fid2(3*rank+3),1,'int32');
         
        figure(111)
        hold on
        surf(x,y,transpose(shadow));
        title('shadow')
        shading flat
        
        figure(222)
        hold on
        surf(x,y,transpose(roughnessCoef));
        title('kssv')
        shading flat
    %---------------------------------------------------------------------
        
end
% These binary outputs are only saved once at the beginning of modeling, 
% while the others in the following are saved every time step, i.e., up 
% to hundreds of times during the whole simulation



%%

% Plot various surfaces


%-----------------------------------------------------
% Set up the movie.
writerObj = VideoWriter('animation.avi'); % Name it.
writerObj.FrameRate = 3; % How many frames per second.
writerObj.Quality = 90; %video quality
open(writerObj); 
%-----------------------------------------------------

figure(555);
colormap(wave_map) 
set(gcf,'Position',[1 scrsz(4) scrsz(3) scrsz(4)*0.85]);

water_shift = max( max( abs(ho) ) )/100;
% For better presentation goal, NOT physical

for n = 1 : nt
    clf
    [n,nt]
    for rank = 0 : num_procs-1
        ind = ['00' num2str(rank)];
        file_ind = ind(length(ind)-2:length(ind));

        eval(['x=xloc' file_ind ';'])
        eval(['y=yloc' file_ind ';'])

        nx = length(x);
        ny = length(y);

        zeta = zeros(nx,ny,N_levels);
        
        bl_hor_wall = zeros(nx,ny);
        t_break = zeros(nx,ny);
        h = zeros(nx,ny);
        u = zeros(nx,ny,N_levels);
        v = zeros(nx,ny,N_levels);
        vort = zeros(nx,ny,N_levels);
        us = zeros(nx,ny,N_levels);
        vs = zeros(nx,ny,N_levels);
        
        all_friction = zeros(nx,ny);
      
        
        dum = fread(fid3(rank+1),1,'int32');
        all_friction = fread(fid3(rank+1),[nx,ny],'single');
        dum = fread(fid3(rank+1),1,'int32');
      
 
        for s=1:N_levels
%             dum = fread(fid(5*rank+3),1,'int32');
%             u(:,:,s) = fread(fid(5*rank+3),[nx,ny],'single');   % read x-velocity array, at z_alpha
%             v(:,:,s) = fread(fid(5*rank+3),[nx,ny],'single');   % read y-velocity array, at z_alpha
%             dum = fread(fid(5*rank+3),1,'int32');
% 
            dum = fread(fid(5*rank+2),1,'int32');
            zeta(:,:,s) = fread(fid(5*rank+2),[nx,ny],'single');   % read free surface array
            dum = fread(fid(5*rank+2),1,'int32');
% 
%             dum = fread(fid(5*rank+5),1,'int32');
%             vort(:,:,s) = fread(fid(5*rank+5),[nx,ny],'single');   % read surface vorticity array
%             us(:,:,s) = fread(fid(5*rank+5),[nx,ny],'single');   % read x-velocity array, at zeta
%             vs(:,:,s) = fread(fid(5*rank+5),[nx,ny],'single');   % read y-velocity array, at zeta
%             dum = fread(fid(5*rank+5),1,'int32');
        end


        dum = fread(fid(5*rank+4),1,'int32');
        bl_hor_wall = fread(fid(5*rank+4),[nx,ny],'int32');  % location of wet=0 and dry=99 cells
        t_break = fread(fid(5*rank+4),[nx,ny],'single');  % breaking locations
        h = fread(fid(5*rank+4),[nx,ny],'single');  % water depth, only different from h0 for landslide
        dum = fread(fid(5*rank+4),1,'int32');

        

        fake_ele = zeros(size(all_friction));
        fake_ele( all_friction>0.003 ) = all_friction( all_friction>0.003 );
        
        
        hold on;
        surf( x,y,transpose( zeta(:,:,1).*(1-bl_hor_wall/99) - (bl_hor_wall/99).* h ) );
        
        surf( x,y,transpose(-h)+fake_ele'+water_shift,'CData',zeros(ny,nx,3)+.4,...
            'EdgeAlpha',1,'BackFaceLighting','reverselit' )
  

    end
    
    shading flat
    axis equal
    xlabel('x (m)','fontsize',20)
    ylabel('y (m)','fontsize',20)
    set(gca, 'fontsize',16)
    title(sprintf('Free Surface Elevation, Time (sec) = %f ', time(n) ),...
        'fontsize', 20)
    view(20,150)

    caxis([-.01 .15])

    light
    
    drawnow    
    frame = getframe(gcf);
    writeVideo(writerObj, frame);
    
    
end

close(writerObj); % Saves the movie.
fclose all;


