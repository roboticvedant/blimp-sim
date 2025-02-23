function real_time_plot(t, x, varargin)
    % real_time_plot - Plots the real-time simulation based on ODE45 timestamps
    % and optionally saves it as an MP4 video.
    %
    % INPUTS:
    %   t - Time vector from ode45 solver
    %   x - State trajectory matrix (Nx3 for 3D visualization)
    %
    % OPTIONAL PARAMETERS (passed as Name-Value pairs):
    %   'Title'       - Custom plot title (default: 'Real-Time Simulation')
    %   'SaveVideo'   - Filename to save MP4 video (default: '', meaning no video)
    %
    % USAGE:
    %   real_time_plot(t, x);
    %   real_time_plot(t, x, 'Title', 'Custom Title', 'SaveVideo', 'output.mp4');

    % Parse optional arguments
    p = inputParser;
    addParameter(p, 'Title', 'Real-Time Simulation', @ischar);
    addParameter(p, 'SaveVideo', '', @ischar);
    parse(p, varargin{:});

    plotTitle = p.Results.Title;
    videoFilename = p.Results.SaveVideo;

    % Check inputs
    if nargin < 2
        error('Function requires at least two input arguments: time vector (t) and state matrix (x).');
    end
    if size(x, 2) < 3
        error('State matrix x must have at least 3 columns for 3D plotting.');
    end

    % Normalize time to start at 0
    t = t - t(1);

    % Initialize 3D Plot
    figure;
    h = plot3(x(1,1), x(1,2), x(1,3), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
    hold on;
    grid on;
    plot3(x(:,1), x(:,2), x(:,3), 'b-'); % Full trajectory
    xlabel('X'); ylabel('Y'); zlabel('Z');
    title(plotTitle);

    % Initialize video writer if saving is enabled
    if ~isempty(videoFilename)
        v = VideoWriter(videoFilename, 'MPEG-4');
        v.FrameRate = 30;
        open(v);
    end

    % Real-time synchronization
    t_start = tic; % Start timer
    i = 1; % Initialize index

    while i < length(t)
        elapsed_time = toc(t_start); % Get elapsed real-world time

        % Find the closest simulation time that is less than or equal to elapsed time
        while i < length(t) && t(i) <= elapsed_time
            i = i + 1;
        end

        % Linear interpolation for smoother movement
        if i > 1 && i <= length(t)
            % Compute interpolated position
            alpha = (elapsed_time - t(i-1)) / (t(i) - t(i-1));
            interpolated_pos = (1 - alpha) * x(i-1, :) + alpha * x(i, :);

            % Update the marker position
            set(h, 'XData', interpolated_pos(1), 'YData', interpolated_pos(2), 'ZData', interpolated_pos(3));
            drawnow;

            % Capture frame if saving video
            if ~isempty(videoFilename)
                frame = getframe(gcf);
                writeVideo(v, frame);
            end
        end
    end

    % Close video writer if saving
    if ~isempty(videoFilename)
        close(v);
        disp(['Video saved as: ', videoFilename]);
    end

    disp('Real-time simulation completed.');
end
