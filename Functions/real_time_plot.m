function real_time_plot(t, x, varargin)
    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Title', 'Real-Time Simulation', @ischar);
    addParameter(p, 'SaveVideo', '', @ischar);
    addParameter(p, 'TimeScale', 1.0, @isnumeric);  % Added time scaling factor
    parse(p, varargin{:});

    plotTitle = p.Results.Title;
    videoFilename = p.Results.SaveVideo;
    timeScale = p.Results.TimeScale;

    % Input validation
    if nargin < 2
        error('Function requires at least two input arguments: time vector (t) and state matrix (x).');
    end
    if size(x, 2) < 3
        error('State matrix x must have at least 3 columns for 3D plotting.');
    end

    % Normalize time to start at 0
    t = t - t(1);
    simulationEndTime = t(end);
    
    % Print simulation info
    fprintf('Total simulation time: %.2f seconds\n', simulationEndTime);
    fprintf('Number of timesteps: %d\n', length(t));
    fprintf('Average timestep: %.4f seconds\n', mean(diff(t)));

    % Initialize 3D Plot
    figure('Position', [100, 100, 800, 600]);
    h = plot3(x(1,1), x(1,2), x(1,3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    hold on;
    grid on;
    plot3(x(:,1), x(:,2), x(:,3), 'b-', 'LineWidth', 1.5); % Full trajectory
    
    % Add time display text
    timeText = text(min(x(:,1)), min(x(:,2)), max(x(:,3)), ...
                   'Time: 0.00s', 'FontSize', 12);
    
    % Set axis limits with some padding
    axis_padding = 0.1 * (max(max(abs(x(:,1:3)))) - min(min(abs(x(:,1:3)))));
    xlim([min(x(:,1))-axis_padding, max(x(:,1))+axis_padding]);
    ylim([min(x(:,2))-axis_padding, max(x(:,2))+axis_padding]);
    zlim([min(x(:,3))-axis_padding, max(x(:,3))+axis_padding]);
    
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
    title(plotTitle);
    view(45, 30);  % Set initial view angle

    % Initialize video writer if saving is enabled
    if ~isempty(videoFilename)
        v = VideoWriter(videoFilename, 'MPEG-4');
        v.FrameRate = 30;
        open(v);
    end

    % Real-time synchronization
    t_start = tic;
    i = 1;
    target_fps = 60;  % Target frame rate
    target_frame_time = 1/target_fps;

    % Main animation loop
    while i < length(t)
        frame_start = tic;
        
        % Get elapsed time and scale it
        elapsed_time = toc(t_start) * timeScale;

        % Find the appropriate time index
        while i < length(t) && t(i) <= elapsed_time
            i = i + 1;
        end

        % Ensure we don't exceed array bounds
        if i >= length(t)
            break;
        end

        % Compute interpolation factor
        alpha = (elapsed_time - t(i-1)) / (t(i) - t(i-1));
        alpha = max(0, min(1, alpha));  % Clamp between 0 and 1

        % Interpolate position
        pos = (1-alpha) * x(i-1, 1:3) + alpha * x(i, 1:3);

        % Update visualization
        set(h, 'XData', pos(1), 'YData', pos(2), 'ZData', pos(3));
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