function [h1, h2] = sc_scattermarker(X, genelist, ...
                                     s, targetg, methodid, sz, showcam)
    % SC_SCATTERMARKER(X,genelist,g,s,methodid)
    %
    % USAGE:
    % s=sc_tsne(X,3);
    % g=["AGER","SFTPC","SCGB3A2","TPPP3"];
    % sc_scattermarker(X,genelist,s,genelist(1));

    import gui.*
    h1 = [];
    h2 = [];
    if nargin < 4
        error('sc_scattermarker(X,genelist,s,g)');
    end
    if isvector(s) || isscalar(s)
        error('S should be a matrix.');
    end
    if nargin < 7
        showcam = true;
    end
    if nargin < 6 || isempty(sz)
        sz = 5;
    end
    if nargin < 5
        methodid = 1;
    end
    if iscell(targetg)
        for k = 1:length(targetg)
            figure;
            sc_scattermarker(X, genelist, s, targetg{k}, methodid, sz);
        end
    elseif isstring(targetg) && ~isStringScalar(targetg)
        for k = 1:length(targetg)
            figure;
            sc_scattermarker(X, genelist, s, targetg(k), methodid, sz);
        end
    elseif isStringScalar(targetg) || ischar(targetg)
        if ismember(targetg, genelist)
            x = s(:, 1);
            y = s(:, 2);
            if min(size(s)) == 2
                z = [];
            else
                z = s(:, 3);
            end
            %        c=log2(1+X(genelist==targetg,:));
            c = X(genelist == targetg, :);
            if issparse(c)
                c = full(c);
            end
            switch methodid
                case 1
                    within_stemscatter(x, y, c);                    
                case 2
                    if isempty(z)
                        scatter(x, y, sz, c, 'filled');
                    else
                        scatter3(x, y, z, sz, c, 'filled');
                    end
                case 3

                    
                case 4
                    subplot(1, 2, 1);
                    sc_scattermarker(X, genelist, s, targetg, 2, sz, false);
                    subplot(1, 2, 2);
                    sc_scattermarker(X, genelist, s, targetg, 1, sz, false);
                    hFig = gcf;
                    hFig.Position(3) = hFig.Position(3) * 2;
                case 5          % ============ 5
                    if size(s, 2) >= 3
                        x = s(:, 1);
                        y = s(:, 2);
                        z = s(:, 3);
                    else
                        x = s(:, 1);
                        y = s(:, 2);
                        z = zeros(size(x));
                    end
                   % explorer2IDX = y;
                   % assignin('base', 'explorer2IDX', explorer2IDX);
                   
                   % c=log2(1+X(genelist==g,:));

                    h1 = subplot(1, 2, 1);
                    scatter3(x, y, z, sz, c, 'filled');
                    
%                     a = colormap('autumn');
%                     a(1, :) = [.8 .8 .8];
%                     if numel(unique(c)) == 1
%                         for kk = 1:size(a, 1)
%                             a(kk, :) = [.8 .8 .8];
%                         end
%                     end
%                     colormap(a);
                    
                    
                    % h1.YDataSource='explorer2IDX';
                    % title(targetg)
                    title(sprintf('%s\n(%s/%s = %.2f%% nonzero)', ...
                                  targetg, ...
                                  num2bankScalar(sum(c > 0)), ...
                                  num2bankScalar(numel(c)), ...
                                  100 * sum(c > 0) ./ numel(c)));

                    %                 title(sprintf('%s\n(%s/%s = %g%% nonzero)',...
                    %                     g,...
                    %                     num2bankScalar(sum(c>0)),...
                    %                     num2bankScalar(numel(c)),...
                    %                     100*sum(c>0)./numel(c)));

                    h2 = subplot(1, 2, 2);
                    stem3(x, y, c, 'marker', 'none', 'color', 'm');
                    hold on;
                    scatter3(x, y, zeros(size(y)), 5, c, 'filled');
                    % h2.YDataSource='explorer2IDX';
                    % hLD = linkdata('on');
                    evalin('base', 'h=findobj(gcf,''type'',''axes'');');
                    evalin('base', 'hlink = linkprop(h,{''CameraPosition'',''CameraUpVector''});');
                    evalin('base', 'rotate3d on');
                    hFig = gcf;
                    hFig.Position(3) = hFig.Position(3) * 2.2;
                    view(h1, 3);
            end
            gui.i_setautumncolor(c);
            
            title(sprintf('%s\n(%s/%s = %.2f%% nonzero)', ...
                               targetg, ...
                               num2bankScalar(sum(c > 0)), ...
                               num2bankScalar(numel(c)), ...
                               100 * sum(c > 0) ./ numel(c)));
            % pt = uipushtool(defaultToolbar);
            % tx.ButtonDownFcn=@dispgname;
            if showcam
                hFig = gcf;
                tb = uitoolbar(hFig);
  %{
                pt5pickcolr = uipushtool(tb, 'Separator', 'off');
                [img, map] = imread(fullfile(fileparts(mfilename('fullpath')), ...
                                             'resources', 'plotpicker-compass.gif'));  % plotpicker-pie
                % map(map(:,1)+map(:,2)+map(:,3)==3) = NaN;  % Convert white pixels => transparent background
                ptImage = ind2rgb(img, map);
                pt5pickcolr.CData = ptImage;
                pt5pickcolr.Tooltip = 'Switch color maps';
                % pt5pickcolr.ClickedCallback = @callback_PickColorMap;
                a=min([numel(unique(c)),256]);
                pt5pickcolr.ClickedCallback = {@callback_PickColorMap, a, true};
  %}
                pt = uipushtool(tb, 'Separator', 'off');
                [img, map] = imread(fullfile(fileparts(mfilename('fullpath')), ...
                                             'resources', 'plottypectl-rlocusplot.gif'));  % plotpicker-pie
                ptImage = ind2rgb(img, map);
                pt.CData = ptImage;
                pt.Tooltip = 'Link subplots';
                pt.ClickedCallback = @gui.i_linksubplots;

                pt = uipushtool(tb, 'Separator', 'on');
                [img, map] = imread(fullfile(fileparts(mfilename('fullpath')), ...
                                             'resources', 'fvtool_fdalinkbutton.gif'));  % plotpicker-pie
                ptImage = ind2rgb(img, map);
                pt.CData = ptImage;
                pt.Tooltip = 'GeneCards';
                pt.ClickedCallback = {@i_genecards,targetg};              
            end
        else
            warning('%s no expression', targetg);
        end
        if showcam
            gui.add_3dcamera(tb, targetg);
        end
    end

    
end

function i_genecards(~,~,g)
web(sprintf('https://www.genecards.org/cgi-bin/carddisp.pl?gene=%s',g));
end

% function callback_linksubplots(~,~)
%     evalin('base', 'h=findobj(gcf,''type'',''axes'');');
%     evalin('base', 'hlink = linkprop(h,{''CameraPosition'',''CameraUpVector''});');
%     evalin('base', 'rotate3d on');        
% end



% function i_setautumncolor(c)
%     a = colormap('autumn');
%     a(1, :) = [.8 .8 .8];
%     if numel(unique(c)) == 1
%         for kk = 1:size(a, 1)
%             a(kk, :) = [.8 .8 .8];
%         end
%     end
%     colormap(a);
% end


function selectcolormapeditor(~, ~)
    % colormapeditor;
end

function [str] = num2bankScalar(num)
    % https://www.mathworks.com/matlabcentral/answers/96131-is-there-a-format-in-matlab-to-display-numbers-such-that-commas-are-automatically-inserted-into-the
    num = floor(num * 100) / 100;
    str = num2str(num);
    k = find(str == '.', 1);
    if isempty(k)
        % str=[str,'.00'];
    end
    % FIN = min(length(str),find(str == '.')-1);
    FIN = length(str);
    for i = FIN - 2:-3:2
        str(i + 1:end + 1) = str(i:end);
        str(i) = ',';
    end
end

function within_stemscatter(x, y, z)
    if nargin < 3
        x = randn(300, 1);
        y = randn(300, 1);
        z = abs(randn(300, 1));
    end
    if isempty(z)
        warndlg('No expression');
        scatter(x, y, '.');
    else
        stem3(x, y, z, 'marker', 'none', 'color', 'm');
        hold on;
        scatter(x, y, 10, z, 'filled');
        hold off;
    end
    % [caz,cel]=view;
    % view([-45,-45,300]);
end
