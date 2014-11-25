function draw_state( state_cur, color_bbox, samples_centers, samples_centers_parts )
hold on;

color = ['r','y','b','c','w','m'];
n_color = numel(color);

cx = state_cur.center(1);
cy = state_cur.center(2);

for p = state_cur.viewpoint.idx_unoccluded
    if( ~state_cur.viewpoint.parts{p}.is_occluded )
                
        if( p <= n_color )
            color_target = color(p);
            l = 4;
        else
            if( exist('color_bbox','var') )
                color_target = color_bbox;
            else
                color_target = 'y';
            end
            l = 4;
        end
        cx_part = state_cur.centers_parts(p*2-1);
        cy_part = state_cur.centers_parts(p*2);
        
        if( state_cur.viewpoint.parts{p}.is_root )
            shape = bbox_from_parts(state_cur.viewpoint, state_cur.centers_parts);
            x_part = shape(:,1);
            y_part = shape(:,2);
        else
            x_part = state_cur.viewpoint.parts{p}.shape(:,1);
            y_part = state_cur.viewpoint.parts{p}.shape(:,2);
            %plot(x_part+cx+cx_part,y_part+cy+cy_part,color_target,'LineWidth',l);
            patch('Faces', [1 2 3 4 5], 'Vertices', [x_part+cx+cx_part,y_part+cy+cy_part], 'FaceColor', color_target, ...
                'EdgeColor', color_target, 'FaceAlpha', 0.1, 'LineWidth', l);            
        end        
        
        if( ~state_cur.viewpoint.parts{p}.is_root && exist('samples_centers','var') && exist('samples_centers_parts','var'))            
            n_centers = size(samples_centers,1);
            for c=1:n_centers
                plot( samples_centers(c,1)+samples_centers_parts(:,p*2-1)+state_cur.viewpoint.parts{p}.center(1), ...
                      samples_centers(c,2)+samples_centers_parts(:,p*2)  +state_cur.viewpoint.parts{p}.center(2), [color(p) '.'] );
            end            
        end
        
        x_model = cx+state_cur.viewpoint.parts{p}.center(1);
        y_model = cy+state_cur.viewpoint.parts{p}.center(2);
%         x_target = cx+cx_part;
%         y_target = cy+cy_part;
%         line([x_model x_target],[y_model y_target],'Color','w');
%         plot(x_model,  y_model,  'wx');
        if p <= 6
            plot(x_model, y_model, [color_target 'o'], 'MarkerSize', 4, 'MarkerFaceColor', color_target);
        end
        
    end
end            

hold off;
end

function [ xy_bbox ] = bbox_from_parts( viewpoint, centers_parts )

centers_parts = squeeze(centers_parts);

lt = [inf inf];
rb = [0 0];
for p=viewpoint.idx_unoccluded
    if( ~viewpoint.parts{p}.is_root )
        x = centers_parts(p*2-1);
        y = centers_parts(p*2  );
        
        lt(1) = min([viewpoint.parts{p}.shape(:,1)+x;lt(1)]);
        lt(2) = min([viewpoint.parts{p}.shape(:,2)+y;lt(2)]);
        rb(1) = max([viewpoint.parts{p}.shape(:,1)+x;rb(1)]);
        rb(2) = max([viewpoint.parts{p}.shape(:,2)+y;rb(2)]);
    end
end

xy_bbox = [ lt(1) lt(2);
            lt(1) rb(2);
            rb(1) rb(2);
            rb(1) lt(2);
            lt(1) lt(2); ];

end
