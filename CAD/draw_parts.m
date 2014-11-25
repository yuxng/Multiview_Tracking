function draw_parts(part2d)

pnames = part2d.pnames;
figure;
axis equal;
hold on;

for i = 1:numel(pnames)
    a = part2d.azimuth;
    e = part2d.elevation;
    d = part2d.distance;
    part = part2d.(pnames{i});
    center = part2d.centers(i,:);
    if isempty(part) == 0
        part = part + repmat(center, size(part,1), 1);
        set(gca,'YDir','reverse');
        patch(part(:,1), part(:,2), 'r', 'FaceAlpha', 0.1);
        til = sprintf('azimuth=%d, elevation=%d, distance=%d', a, e, d);
        title(til);
        plot(center(1), center(2), 'o');
    end
end

hold off;