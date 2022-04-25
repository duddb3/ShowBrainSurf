function [LL,LM,RL,RM,S,I] = showbrainsurf(cdata,varargin)

    pth = fileparts(which('showbrainsurf'));
    addpath(genpath(pth));
    if ~exist('cdata','var')
        pickrois = 1;
        atlases = {'Gordon','Destrieux','DK40','HCP_MMP','Schaefer'};
        [sel,ok] = listdlg('ListString',atlases,'SelectionMode','single','PromptString','Which atlas do you want to view?');
        if ~ok
            return
        end
        switch atlases{sel}
            case 'Gordon'
                cdata = 0.5*ones(333,3);
            case 'Destrieux'
                cdata = 0.5*ones(148,3);
            case 'DK40'
                cdata = 0.5*ones(70,3);
            case 'HCP_MMP'
                cdata = 0.5*ones(360,3);
            case 'Schaefer'
                cdata = 0.5*ones(600,3);
        end
    else
        pickrois = 0;
    end
    if size(cdata,2)==1
        if nargin==2
            mn = varargin{1}(1);
            mx = varargin{1}(2);
        else
            mn = min(cdata);
            mx = max(cdata);
        end
        
        if mn>=0
            numcol = min(256,length(unique(cdata)));
            figure('Visible','off')
            cmap = colormap(hot(numcol));
            close(gcf)
        elseif mx<=0
            numcol = min(256,length(unique(cdata)));
            figure('Visible','off')
            cmap = flip(flip(colormap(hot(numcol)),1),2);
            close(gcf)
        else
            numcol = 256;
            if nargin==1
                cb = max(abs(cdata));
                mn = -cb;
                mx = cb;
            end
            cmap = ones(256,3);
            cmap(1:128,1:2) = repmat(linspace(0,1,128)',1,2);
            cmap(129:256,2:3) = repmat(linspace(1,0,128)',1,2);
            cmap = cmap.^0.75;
        end
        inan = isnan(cdata);
        cdata = gray2ind(mat2gray(cdata,[mn mx]),numcol);
        cdata = squeeze(ind2rgb(cdata,cmap));
        cdata(repmat(inan,1,3)) = repmat([.5 .5 .5],sum(inan),1);
        pcb = true;
    else
        pcb = false;
    end

    switch size(cdata,1)
        case 64984 % vertex-level data at 32k/hemisphere (~2mm spacing)
            tdir = fullfile(pth,'templates','templates_surfaces_32k');
            L = gifti(fullfile(tdir,'lh.inflated.freesurfer.gii'));
            R = gifti(fullfile(tdir,'rh.inflated.freesurfer.gii'));
            ldata = cdata(1:length(L.vertices),:);
            rdata = cdata(length(L.vertices)+1:end,:);
        case 327684 % vertex-level data at ~1mm spacing
            tdir = fullfile(pth,'templates','templates_surfaces');
            L = gifti(fullfile(tdir,'lh.inflated.freesurfer.gii'));
            R = gifti(fullfile(tdir,'rh.inflated.freesurfer.gii'));
            ldata = cdata(1:length(L.vertices),:);
            rdata = cdata(length(L.vertices)+1:end,:);
        case 333 % Gordon functional atlas
            tdir = fullfile(pth,'templates','templates_surfaces_32k');
            L = gifti(fullfile(tdir,'lh.inflated.freesurfer.gii'));
            R = gifti(fullfile(tdir,'rh.inflated.freesurfer.gii'));
            gdir = 'C:\Users\duddb3\Documents\GordonAtlas\Parcels\';
            GL = gifti(fullfile(gdir,'Parcels_L.func.gii'));
            GR = gifti(fullfile(gdir,'Parcels_R.func.gii'));
            if pickrois
                GAlabels = readtable(fullfile(gdir,'Parcels.xlsx'));
                [~,o] = sort(GAlabels.Community);
                coms = GAlabels.Community(o);
                ids = cellfun(@num2str,num2cell(GAlabels.ParcelID(o)),'Uni',0);
                rois = cellfun(@(x,y) [x '_ParcelID-' y],coms,ids,'Uni',0);
                [sel,ok] = listdlg('ListString',rois,'PromptString','Which ROI(s) to display?',...
                    'ListSize',[600 600]);
                if ~ok
                    return
                end
                cdata(o(sel),:) = distinguishable_colors(length(sel),[.5 .5 .5]);
            end
            ldata = 0.5.*ones(length(L.vertices),size(cdata,2));
            rdata = 0.5.*ones(length(R.vertices),size(cdata,2));
            for n=1:333
                li = GL.cdata==n;
                ldata(li,:) = repmat(cdata(n,:),sum(li),1);
                ri = GR.cdata==n;
                rdata(ri,:) = repmat(cdata(n,:),sum(ri),1);
            end
        otherwise % atlas-defined data
%             addpath('C:\Users\duddb3\Documents\MATLAB\qcmon-master\assets\matlab\freesurfer\');
            adir = fullfile(pth,'templates','atlases_surfaces');
            tdir = fullfile(pth,'templates','templates_surfaces');
            L = gifti(fullfile(tdir,'lh.inflated.freesurfer.gii'));
            R = gifti(fullfile(tdir,'rh.inflated.freesurfer.gii'));
            switch size(cdata,1)
                case 148 % Destrieux
                    [~,llab,lctab] = read_annotation(fullfile(adir,'lh.aparc_a2009s.freesurfer.annot'),0);
                    [~,rlab,rctab] = read_annotation(fullfile(adir,'rh.aparc_a2009s.freesurfer.annot'),0);
                    idx = [2:42,44:76]; % skip "unknown" and "medial wall"
                case 70 % DK40
                    [~,llab,lctab] = read_annotation(fullfile(adir,'lh.aparc_DK40.freesurfer.annot'),0);
                    [~,rlab,rctab] = read_annotation(fullfile(adir,'rh.aparc_DK40.freesurfer.annot'),0);
                    idx = 2:36; % skip "unknown"
                case 360 % HCP multimodal
                    [~,llab,lctab] = read_annotation(fullfile(adir,'lh.aparc_HCP_MMP1.freesurfer.annot'),0);
                    [~,rlab,rctab] = read_annotation(fullfile(adir,'rh.aparc_HCP_MMP1.freesurfer.annot'),0);
                    idx = 2:181; % skip "???"
                case {100,200,400,600} % Schaefer2018_XXXParcels_17Networks
                    [~,llab,lctab] = read_annotation(fullfile(adir,sprintf('lh.Schaefer2018_%iParcels_17Networks_order.annot',size(cdata,1))),0);
                    [~,rlab,rctab] = read_annotation(fullfile(adir,sprintf('rh.Schaefer2018_%iParcels_17Networks_order.annot',size(cdata,1))),0);
                    idx = 2:length(lctab.struct_names); % skip "???"                    

                otherwise
                    fprintf(2,'Size of cdata not compatible\n')
                    return
            end
            if pickrois
                [sel,ok] = listdlg('ListString',[lctab.struct_names(idx);rctab.struct_names(idx)],'PromptString','Which ROI(s) to display?',...
                    'ListSize',[600 600]);
                if ~ok
                    return
                end
                cdata(sel,:) = distinguishable_colors(length(sel),[.5 .5 .5]);
            end
            ldata = 0.5.*ones(length(llab),size(cdata,2));
            rdata = 0.5.*ones(length(rlab),size(cdata,2));
            for n=1:size(cdata,1)/2
                li = llab==lctab.table(idx(n),5);
                ldata(li,:) = repmat(cdata(n,:),sum(li),1);
            end
            for n=1:size(cdata,1)/2
                ri = rlab==rctab.table(idx(n),5);
                rdata(ri,:) = repmat(cdata(n+length(idx),:),sum(ri),1);
            end
    end

    
    figure,
    set(gcf,'Color','w','Position',[100 100 300 250])
    p1 = patch('Faces',L.faces,'Vertices',L.vertices);
    p1.AmbientStrength = 0.6;
    p1.SpecularStrength = 0.1;
    p1.SpecularExponent = 100;
    p1.FaceLighting = 'gouraud';
    p1.EdgeColor = 'none';
    p1.FaceVertexCData = ldata;
    p1.FaceColor = 'interp';
    
    p2 = patch('Faces',R.faces,'Vertices',R.vertices);
    p2.AmbientStrength = 0.6;
    p2.SpecularStrength = 0.1;
    p2.SpecularExponent = 100;
    p2.FaceLighting = 'gouraud';
    p2.EdgeColor = 'none';
    p2.FaceVertexCData = rdata;
    p2.FaceColor = 'interp';
    p2.Visible = 'off';
    
    axis equal vis3d off
    
    % Left lateral view
    view(-90,0);
    l1 = lightangle(-90,0);
    l1.Color = [255 225 195]./255;
    LL = frame2im(getframe(gcf));
    % Left medial view
    view(90,0);
    l1.Position = [sqrt(2) 0 0];
    LM = frame2im(getframe(gcf));
    
    % Right lateral view
    p2.Visible = 'on';
    p1.Visible = 'off';
    RL = frame2im(getframe(gcf));
    % Right medial view
    view(-90,0);
    l1.Position = [-sqrt(2) 0 0];
    RM = frame2im(getframe(gcf));
    
    % Superior view
    p1.Visible = 'on';
    view(0,90);
    l1.Position = [0 0 sqrt(2)];
    S = frame2im(getframe(gcf));
    % Inferior view
    view(-180,-90);
    l1.Position = [0 0 -sqrt(2)];
    I = frame2im(getframe(gcf));
    
    close(gcf)
    
    figure,imshow([S LL LM; I RL RM]);
    set(gcf,'Color','w')
    if pcb
        colormap(cmap)
        p = colorbar;
        p.Ticks = [0 1];
        p.TickLabels = strsplit(num2str([mn,mx]));
    end
end