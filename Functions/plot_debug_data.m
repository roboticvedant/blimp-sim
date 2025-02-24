function plot_debug_data(debug)
    % plot_debug_data - Plots all forces, moments, and aerodynamic parameters from the debug struct.
    %
    % INPUT:
    %   debug - Struct containing simulation debug data.
    %
    % USAGE:
    %   plot_debug_data(debug);
    
    if isempty(debug)
        error("Debug struct is empty. Run the simulation first.");
    end

    % Extract time steps (assuming uniform sampling)
    time_steps = 1:length(debug.v2);

    % ---- PLOT VELOCITY SQUARED (v2) ----
    figure;
    plot(time_steps, debug.v2, 'b', 'LineWidth', 1.5);
    xlabel('Time Step'); ylabel('Velocity Squared (v2)');
    title('Velocity Squared Over Time'); grid on;

    % ---- FUNCTION TO PLOT FORCES AND MOMENTS ----
    function plot_force_moment(data, labels, title_text)
        figure;
        plot(time_steps, data(1,:), 'r', 'LineWidth', 1.2); hold on;
        plot(time_steps, data(2,:), 'b', 'LineWidth', 1.2);
        plot(time_steps, data(3,:), 'g', 'LineWidth', 1.2);
        legend(labels{1}, labels{2}, labels{3});
        xlabel('Time Step'); ylabel(title_text);
        grid on; title(title_text);
    end

    % ---- PLOT FORCES ----
    plot_force_moment(debug.Fb_xu, {'Fb_x', 'Fb_y', 'Fb_z'}, 'Net Forces (Fb_xu)');
    plot_force_moment(debug.Fthruster, {'Fthruster_x', 'Fthruster_y', 'Fthruster_z'}, 'Thruster Forces');
    plot_force_moment(debug.Fgravity, {'Fgravity_x', 'Fgravity_y', 'Fgravity_z'}, 'Gravity Forces');
    plot_force_moment(debug.Fboyant, {'Fboyant_x', 'Fboyant_y', 'Fboyant_z'}, 'Buoyant Forces');
    plot_force_moment(debug.Faero, {'Faero_x', 'Faero_y', 'Faero_z'}, 'Aerodynamic Forces');

    % ---- PLOT MOMENTS ----
    plot_force_moment(debug.Mb_xu, {'Mb_x', 'Mb_y', 'Mb_z'}, 'Net Moments (Mb_xu)');
    plot_force_moment(debug.Mthruster, {'Mthruster_x', 'Mthruster_y', 'Mthruster_z'}, 'Thruster Moments');
    plot_force_moment(debug.Maero, {'Maero_x', 'Maero_y', 'Maero_z'}, 'Aerodynamic Moments');

    % ---- PLOT AERODYNAMIC ANGLES & COEFFICIENTS ----
    figure;
    subplot(3,1,1);
    plot(time_steps, debug.attack_angle, 'r', 'LineWidth', 1.5);
    ylabel('Attack Angle'); grid on;

    subplot(3,1,2);
    plot(time_steps, debug.sideslip_angle, 'b', 'LineWidth', 1.5);
    ylabel('Sideslip Angle'); grid on;

    subplot(3,1,3);
    plot(time_steps, debug.Cd, 'g', 'LineWidth', 1.5);
    xlabel('Time Step'); ylabel('Drag Coefficient (Cd)');
    grid on;
    sgtitle('Aerodynamic Angles and Coefficients');

    % ---- PLOT AERODYNAMIC FORCES & MOMENTS COMPONENTS ----
    figure;
    aero_labels = {'D', 'S', 'L', 'M1', 'M2', 'M3'};
    aero_data = {debug.D, debug.S, debug.L, debug.M1, debug.M2, debug.M3};

    for i = 1:length(aero_data)
        subplot(3,2,i);
        plot(time_steps, aero_data{i}, 'LineWidth', 1.5);
        ylabel(aero_labels{i}); grid on;
    end

    sgtitle('Aerodynamic Forces and Moments Components');
    xlabel('Time Step');

    disp('Debug plotting completed.');
end
