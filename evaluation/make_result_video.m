function make_result_video

cls = 'TLD';

path_root      = '/home/yuxiang/Projects/Multiview_Tracking/';

switch cls
    case 'YOUTUBE'
        path_img      = [path_root 'dataset/YOUTUBE/%s/img/%05d.%s'];
        % path_gt       = [path_root 'dataset/YOUTUBE/%s/gt/%05d.mat'];        
        data = { 
            struct( 'name', 'FLUFFYJET_1' ,'ext','png') , ...
            struct( 'name', 'FLUFFYJET_2' ,'ext','png') , ...
            struct( 'name', 'FLUFFYJET_3' ,'ext','png') , ...
            struct( 'name', 'FLUFFYJET_4' ,'ext','png') , ...
            struct( 'name', 'FLUFFYJET_5' ,'ext','png') , ...
            struct( 'name', 'FLUFFYJET_6' ,'ext','png') , ...
            struct( 'name', 'drift_1'     ,'ext','jpg') , ...
            struct( 'name', 'BMW_1'       ,'ext','jpg') , ...
            struct( 'name', 'TOYOTA_1'    ,'ext','jpg') , ...
          };   
    case 'KITTI'
        path_img      = [path_root 'dataset/KITTI/multi_car/%s/img/%06d.%s'];
        data = { 
            struct( 'name', 'seq0001_00' ,'ext','png') , ...
            struct( 'name', 'seq0001_01' ,'ext','png') , ...
            struct( 'name', 'seq0001_02' ,'ext','png') , ...
            struct( 'name', 'seq0001_03' ,'ext','png') , ...
            struct( 'name', 'seq0002_00' ,'ext','png') , ...
            struct( 'name', 'seq0002_01' ,'ext','png') , ...
            struct( 'name', 'seq0002_02' ,'ext','png') , ...
            struct( 'name', 'seq0002_03' ,'ext','png') , ...
            struct( 'name', 'seq0002_04' ,'ext','png') , ...
            struct( 'name', 'seq0007_00' ,'ext','png') , ...
            struct( 'name', 'seq0012_00' ,'ext','png') , ...            
            struct( 'name', 'seq0015_00' ,'ext','png') , ... 
            struct( 'name', 'seq0015_01' ,'ext','png') , ...
            struct( 'name', 'seq0015_02' ,'ext','png') , ...
            struct( 'name', 'seq0015_03' ,'ext','png') , ...            
          };
    case 'TLD'
        path_img      = [path_root 'dataset/TLD/%s/img/%05d.%s'];
        data = { 
            struct( 'name', '06_car' ,'ext', 'jpg') , ...           
          };      
end

% load cad model
cad = load('car.mat');
cad = cad.car;
param.cad = cad;
param.category = 'car';

type_result = {'DPMALM'};
postfix='_DPMALM';
% color       = {'r', 'y', 'b'};

path_results  = [path_root 'result/MVT/MVT_%s_%s.txt'];
path_result_video = [path_root 'result/MVT/video/'];
if( ~exist(path_result_video,'dir') )
    mkdir(path_result_video);
end

fontsize_frame = 20;
fontcolor_frame = 'yellow';

for d = 1:numel(data)
    file_video = sprintf([path_result_video data{d}.name postfix '.avi']);

    n_type = numel(type_result);
    result = cell(n_type,1);
    state  = cell(n_type,1);

    n_i = inf;
    for t = 1:n_type
        file_result = sprintf(path_results, data{d}.name, type_result{t});
        result{t} = textread(file_result);
        n_i = min(size(result{t},1),n_i);
    end

    aviobj = VideoWriter(file_video);
    aviobj.FrameRate = 9;
    open(aviobj);
    fig = subplot(1,1,1);
    for i = 1:n_i
        idx_frame = result{1}(i,1);
        file_img = sprintf( path_img, data{d}.name, idx_frame, data{d}.ext );
        img = imread(file_img);
        imshow(img, 'Parent', fig);
        hold on;
        
        % frame number
        text(fontsize_frame, fontsize_frame, ['Frame ' num2str(i)], 'Color', fontcolor_frame, 'FontSize', fontsize_frame);        

        for t=1:n_type
            if( size(result{t},1) >= i )
                % target
                state{t}.rect = result{t}(i,2:5);
                state{t}.viewpoint = viewpoint_from_aed( param, result{t}(i,6:8) );
                state{t}.center = result{t}(i,9:10);            
                state{t}.centers_parts = [result{t}(i,11:22) zeros(1,16)];
                draw_state( state{t} , 'k');
                rectangle('Position',state{t}.rect,'EdgeColor', 'g', 'LineWidth', 4);

                % viewpoint indicator
                [height_img, width_img, ~] = size(img);
                rect_arrow = [width_img*9/10, 0, width_img/10, width_img/10];
                rectangle('Position',rect_arrow, ...
                          'EdgeColor',[1 1 1], 'LineWidth', 4, 'FaceColor','w', 'Curvature',[1,1]);
                a = (-state{t}.viewpoint.aed(1)-90)*2*pi/360;
                arrow = [cos(a) sin(a); -sin(a) cos(a)] * [1 0]';
                arrow = arrow';
                arrow = arrow .* rect_arrow(3:4) / 2;
                center_arrow = [rect_arrow(1)+rect_arrow(3)/2, rect_arrow(2)+rect_arrow(4)/2];
                X = [center_arrow(1), center_arrow(1)+arrow(1)];
                Y = [center_arrow(2), center_arrow(2)+arrow(2)];
                line(X, Y, 'LineWidth', 4, 'Color', 'k');
            end
        end

        % ground truth
%         file_gt = sprintf(path_gt, data{d}.name, idx_frame);
%         object = load(file_gt);        
%         bbox_gt = object.record.objects.bbox;
%         rectangle('Position',bbox_gt,'EdgeColor','w','LineWidth', 2);

        hold off;
        if i == 1
            pause;
        end        
        writeVideo(aviobj, getframe(fig));
    end

    close(aviobj);
    close all;
end