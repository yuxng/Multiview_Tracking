% eliminate part with large tilt
function part2d_new = remove_large_tilt(cad, part2d, tilt_threshold)

part2d_new = part2d;
pnames = cad.pnames;
N = numel(cad.parts);
for i = 1:N
    % if the part is not root part
    if cad.roots(i) == 0
        % get the homography
        H = part2d.homographies{i};
        if isempty(H)
            continue;
        end
        A = H(1:2,1:2);
        % compute the SVD
        [~, S, V] = svd(A);
        % theta is the title angle
        tilt = S(1,1)/S(2,2);
        theta = acosd(1/tilt);
        if theta > tilt_threshold(i)
            part2d_new.(pnames{i}) = [];
            part2d_new.centers(i,:) = [0 0];
            part2d_new.homographies{i} = [];
        end
    end
end