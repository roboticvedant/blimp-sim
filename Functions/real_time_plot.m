function real_time_plot(t, x, varargin)
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Title', 'Real-Time Simulation', @ischar);
    addParameter(p, 'SaveVideo', '', @ischar);
    addParameter(p, 'TimeScale', 1.0, @isnumeric); % Time scaling factor
    addParameter(p, 'GroundLevel', 0, @isnumeric); % Ground level parameter
    addParameter(p, 'FrameSize', 0.5, @isnumeric); % Size of orientation frame
    parse(p, varargin{:});
    plotTitle = p.Results.Title;
    videoFilename = p.Results.SaveVideo;
    timeScale = p.Results.TimeScale;
    groundLevel = p.Results.GroundLevel;
    frameSize = p.Results.FrameSize;

    % Input validation
    if nargin < 2
        error('Function requires at least two input arguments: time vector (t) and state matrix (x).');
    end
    if size(x, 2) < 6
        error('State matrix x must have at least 6 columns for 3D plotting with orientation (positions and angles).');
    end

    % Normalize time to start at 0
    t = t - t(1);
    simulationEndTime = t(end);

    % Print simulation info
    fprintf('Total simulation time: %.2f seconds\n', simulationEndTime);
    fprintf('Number of timesteps: %d\n', length(t));
    fprintf('Average timestep: %.4f seconds\n', mean(diff(t)));

    % Determine axis bounds robustly
    padding_factor = 1.5;
    % Compute ranges and if range is zero then use a default span of 1 unit
    x_min_raw = min(x(:,1)); x_max_raw = max(x(:,1));
    y_min_raw = min(x(:,2)); y_max_raw = max(x(:,2));
    z_min_raw = min(x(:,3)); z_max_raw = max(x(:,3));
    
    x_range = x_max_raw - x_min_raw; if abs(x_range) < eps, x_range = 1; end
    y_range = y_max_raw - y_min_raw; if abs(y_range) < eps, y_range = 1; end
    z_range = z_max_raw - z_min_raw; if abs(z_range) < eps, z_range = 1; end

    x_min = x_min_raw - padding_factor * x_range;
    x_max = x_max_raw + padding_factor * x_range;
    y_min = y_min_raw - padding_factor * y_range;
    y_max = y_max_raw + padding_factor * y_range;
    
    % Ensure limits are strictly increasing
    if x_min >= x_max, x_min = x_min - 1; x_max = x_max + 1; end
    if y_min >= y_max, y_min = y_min - 1; y_max = y_max + 1; end

    % Set axis padding for z based on overall range
    axis_padding = 0.1 * max([x_range, y_range, z_range]);
    z_low = min(z_min_raw, groundLevel) - axis_padding;
    z_high = max(z_max_raw, groundLevel) + axis_padding;

    % Initialize 3D Plot
    figure('Position', [100, 100, 800, 600]);
    h_body = plot3(x(1,1), x(1,2), x(1,3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    hold on;
    grid on;
    plot3(x(:,1), x(:,2), x(:,3), 'b-', 'LineWidth', 1.5); % Full trajectory

    % Initialize orientation frame lines for the moving body
    h_x_axis = quiver3(x(1,1), x(1,2), x(1,3), frameSize, 0, 0, 'r', 'LineWidth', 2, 'MaxHeadSize', 0.3);
    h_y_axis = quiver3(x(1,1), x(1,2), x(1,3), 0, frameSize, 0, 'g', 'LineWidth', 2, 'MaxHeadSize', 0.3);
    h_z_axis = quiver3(x(1,1), x(1,2), x(1,3), 0, 0, frameSize, 'b', 'LineWidth', 2, 'MaxHeadSize', 0.3);
    
    % Add labels for the moving body's frame
    h_x_label = text(x(1,1) + 1.1*frameSize, x(1,2), x(1,3), 'X', 'Color', 'r', 'FontWeight', 'bold');
    h_y_label = text(x(1,1), x(1,2) + 1.1*frameSize, x(1,3), 'Y', 'Color', 'g', 'FontWeight', 'bold');
    h_z_label = text(x(1,1), x(1,2), x(1,3) + 1.1*frameSize, 'Z', 'Color', 'b', 'FontWeight', 'bold');
    
    % Plot inertial reference frame at a fixed origin (e.g., at [0, 0, groundLevel])
    inertial_origin = [0, 0, groundLevel];
    h_inertial_x = quiver3(inertial_origin(1), inertial_origin(2), inertial_origin(3), frameSize, 0, 0, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.3);
    h_inertial_y = quiver3(inertial_origin(1), inertial_origin(2), inertial_origin(3), 0, frameSize, 0, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.3);
    h_inertial_z = quiver3(inertial_origin(1), inertial_origin(2), inertial_origin(3), 0, 0, frameSize, 'k', 'LineWidth', 2, 'MaxHeadSize', 0.3);
    
    % Add inertial frame labels using LaTeX formatting for subscripts
    text(inertial_origin(1) + 1.1*frameSize, inertial_origin(2), inertial_origin(3), '$x_0$', 'Interpreter', 'latex', 'FontWeight', 'bold', 'Color', 'k');
    text(inertial_origin(1), inertial_origin(2) + 1.1*frameSize, inertial_origin(3), '$y_0$', 'Interpreter', 'latex', 'FontWeight', 'bold', 'Color', 'k');
    text(inertial_origin(1), inertial_origin(2), inertial_origin(3) + 1.1*frameSize, '$z_0$', 'Interpreter', 'latex', 'FontWeight', 'bold', 'Color', 'k');
   
    minval = min([x_min, y_min, z_low]);
    maxval = max([x_max, y_max, z_high]);

    % Create the ground plane coordinates
    [X, Y] = meshgrid(linspace(minval, maxval, 20), linspace(minval, maxval, 20));
    Z = ones(size(X)) * groundLevel;
    
    % Plot dark green ground plane
    surf(X, Y, Z, 'FaceColor', [0.1, 0.5, 0.1], 'EdgeColor', [0.05, 0.4, 0.05], ...
         'FaceAlpha', 0.8, 'EdgeAlpha', 0.5);
    
    % Add grid lines on the ground for better depth perception
    grid_spacing = max((x_max - x_min)/10, (y_max - y_min)/10);
    for i = floor(x_min/grid_spacing)*grid_spacing:grid_spacing:ceil(x_max/grid_spacing)*grid_spacing
        plot3([i, i], [y_min, y_max], [groundLevel, groundLevel], 'Color', [0.05, 0.4, 0.05], 'LineWidth', 0.5);
    end
    for i = floor(y_min/grid_spacing)*grid_spacing:grid_spacing:ceil(y_max/grid_spacing)*grid_spacing
        plot3([x_min, x_max], [i, i], [groundLevel, groundLevel], 'Color', [0.05, 0.4, 0.05], 'LineWidth', 0.5);
    end

    % Add time display text
    timeText = text(x_min, y_min, z_high, 'Time: 0.00s', 'FontSize', 12);
    
    % Add ground level indicator text
    groundText = text(x_min, y_max, groundLevel, ...
                      sprintf('Ground Level: %.2f m', groundLevel), ...
                      'FontSize', 10, 'Color', [0.05, 0.4, 0.05], 'FontWeight', 'bold');
    
    % Add orientation text display
    orientationText = text(x_max, y_min, z_high, ...
                           'Roll: 0.00°, Pitch: 0.00°, Yaw: 0.00°', ...
                           'FontSize', 10, 'HorizontalAlignment', 'right');
    
    % Set axis limits

    xlim([minval, maxval]);
    ylim([minval, maxval]);
    zlim([minval, maxval+1]);
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
    title(plotTitle);
    view(45, 30); % Initial view angle

    % Initialize video writer if saving is enabled
    if ~isempty(videoFilename)
        v = VideoWriter(videoFilename, 'MPEG-4');
        v.FrameRate = 30;
        open(v);
    end

    % Real-time synchronization parameters
    t_start = tic;
    i = 1;
    target_fps = 60; % Target frame rate
    target_frame_time = 1/target_fps;
    
    % Main animation loop
    while i < length(t)
        frame_start = tic;
        elapsed_time = toc(t_start) * timeScale;
        
        % Find the appropriate time index
        while i < length(t) && t(i) <= elapsed_time
            i = i + 1;
        end
        if i >= length(t)
            break;
        end
        
        % Compute interpolation factor
        alpha = (elapsed_time - t(i-1)) / (t(i) - t(i-1));
        alpha = max(0, min(1, alpha)); % Clamp between 0 and 1
        
        % Interpolate position and orientation (roll, pitch, yaw)
        pos = (1-alpha) * x(i-1, 1:3) + alpha * x(i, 1:3);
        angles = (1-alpha) * x(i-1, 4:6) + alpha * x(i, 4:6);
        roll = angles(1); pitch = angles(2); yaw = angles(3);
        
        % Construct rotation matrix from roll, pitch, yaw
        R_roll = [1 0 0; 0 cos(roll) -sin(roll); 0 sin(roll) cos(roll)];
        R_pitch = [cos(pitch) 0 sin(pitch); 0 1 0; -sin(pitch) 0 cos(pitch)];
        R_yaw = [cos(yaw) -sin(yaw) 0; sin(yaw) cos(yaw) 0; 0 0 1];
        R = R_yaw * R_pitch * R_roll;
        
        % Calculate body-fixed frame vectors
        x_vector = frameSize * (R * [1; 0; 0]);
        y_vector = frameSize * (R * [0; 1; 0]);
        z_vector = frameSize * (R * [0; 0; 1]);
        
        % Update body position marker
        set(h_body, 'XData', pos(1), 'YData', pos(2), 'ZData', pos(3));
        
        % Update moving body's orientation frame
        set(h_x_axis, 'XData', pos(1), 'YData', pos(2), 'ZData', pos(3), ...
                      'UData', x_vector(1), 'VData', x_vector(2), 'WData', x_vector(3));
        set(h_y_axis, 'XData', pos(1), 'YData', pos(2), 'ZData', pos(3), ...
                      'UData', y_vector(1), 'VData', y_vector(2), 'WData', y_vector(3));
        set(h_z_axis, 'XData', pos(1), 'YData', pos(2), 'ZData', pos(3), ...
                      'UData', z_vector(1), 'VData', z_vector(2), 'WData', z_vector(3));
        
        % Update orientation frame labels
        set(h_x_label, 'Position', pos + 1.1*x_vector');
        set(h_y_label, 'Position', pos + 1.1*y_vector');
        set(h_z_label, 'Position', pos + 1.1*z_vector');
        
        % Update text displays for orientation and time
        set(orientationText, 'String', sprintf('Roll: %.2f°, Pitch: %.2f°, Yaw: %.2f°', ...
                                               rad2deg(roll), rad2deg(pitch), rad2deg(yaw)));
        set(timeText, 'String', sprintf('Time: %.2fs', elapsed_time));
        
        % Capture frame if saving video
        if ~isempty(videoFilename)
            frame = getframe(gcf);
            writeVideo(v, frame);
        end
        
        % Frame rate control
        frame_time = toc(frame_start);
        if frame_time < target_frame_time
            pause(target_frame_time - frame_time);
        end
        drawnow;
    end

    % Close video writer if saving
    if ~isempty(videoFilename)
        close(v);
        fprintf('Video saved as: %s\n', videoFilename);
    end

    % Display final statistics
    actual_duration = toc(t_start);
    fprintf('Actual playback duration: %.2f seconds\n', actual_duration);
    fprintf('Target duration: %.2f seconds\n', simulationEndTime/timeScale);
    fprintf('Real-time simulation completed.\n');
end
