%-----------------------------------------
% Sequence alignment for homology modeling
% (C) F.Steffen, version April 2016
%-----------------------------------------

% note: in linux run dos2unix -n inputfile outputfile for the threading to
% work

function SABOSS
%main = figure('name', 'Sequence alignment', 'Position',[250 300 800 500],...
%    'CloseRequestFcn',@(main, event) my_closereq(main),...
%    'menubar', 'none', 'NumberTitle', 'off');

main = figure('name', 'SABOSS (Sequence Alignment Based On Secondary Structure', 'Position',[250 300 800 600],...
    'menubar', 'none', 'NumberTitle', 'off', 'resize', 'off');


uipanel('Title','Input',...
    'units','normalized',...
    'Position',[0.05 0.67 0.9 0.32]);

uipanel('Title','Processing',...
    'units','normalized',...
    'Position',[0.05 0.36 0.9 0.3]);

uipanel('Title','Output',...
    'units','normalized',...
    'Position',[0.05 0.03 0.9 0.32]);

query_static = uicontrol('style','text',...
    'units','normalized',...
    'position',[0.1 0.82 0.8 0.1],...
    'string','template sequence (FASTA)',...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'max', 2);

subject_static = uicontrol('style','text',...
    'units','normalized',...
    'position',[0.1 0.68 0.8 0.1],...
    'string','target sequence (FASTA)',...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'max', 2);

uicontrol('style','text',...
    'units','normalized',...
    'position',[0.1 0.92 0.8 0.03],...
    'string','TEMPLATE',...
    'fontname', 'FixedWidth',...
    'fontweight', 'bold',...
    'fontsize', 9,...
    'HorizontalAlignment','left');

uicontrol('style','text',...
    'units','normalized',...
    'position',[0.1 0.78 0.8 0.03],...
    'string','TARGET',...
    'fontname', 'FixedWidth',...
    'fontweight', 'bold',...
    'fontsize', 9,...
    'HorizontalAlignment','left');


query = uicontrol('style','edit',...
    'units','normalized',...
    'position',[0.1 0.59 0.72 0.03],...
    'string','template sequence (FASTA)',...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'max', 2);

subject = uicontrol('style','edit',...
    'units','normalized',...
    'position',[0.1 0.54 0.72 0.03],...
    'string','target sequence (FASTA)',...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'max', 2);

uicontrol('style','text',...
    'units','normalized',...
    'position',[0.83 0.585 0.1 0.03],...
    'fontweight', 'bold',...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'string', 'template');

uicontrol('style','text',...
    'units','normalized',...
    'position',[0.83 0.535 0.1 0.03],...
    'fontweight', 'bold',...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'string', 'target');

align1 = uicontrol('style','edit',...
    'units','normalized',...
    'position',[0.1 0.42 0.72 0.03],...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'TooltipString', 'search string / extraction for the template sequence');

align2 = uicontrol('style','edit',...
    'units','normalized',...
    'position',[0.1 0.38 0.72 0.03],...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'TooltipString', 'search string / extraction for the target sequence');

uicontrol('style','text',...
    'units','normalized',...
    'position',[0.83 0.415 0.1 0.03],...
    'fontweight', 'bold',...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'string', 'template');

uicontrol('style','text',...
    'units','normalized',...
    'position',[0.83 0.375 0.1 0.03],...
    'fontweight', 'bold',...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'string', 'target');

alignment = uicontrol('style','text',...
    'units','normalized',...
    'position',[0.1 0.1 0.8 0.21],...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left');


message = uicontrol('style','edit',...
    'units','normalized',...
    'position',[0.5 0.05 0.4 0.11],...
    'HorizontalAlignment','left',...
    'max', 2,...
    'TooltipString', 'message box');

samplename = uicontrol('style','edit',...
    'units','normalized',...
    'position',[0.1 0.11 0.39 0.05],...
    'string','>homology alignment',...
    'fontname', 'FixedWidth',...
    'HorizontalAlignment','left',...
    'TooltipString', 'type in your sequence identifier');

extract = uicontrol('style','pushbutton',... % extract pushbutton
    'units','normalized',...
    'position',[0.1 0.47 0.12 0.05],...
    'string','extract',...
    'Callback', @fn_extract,...
    'TooltipString', 'extract the selected sequence or search string');

align = uicontrol('style','pushbutton',... % align pushbutton
    'units','normalized',...
    'position',[0.235 0.47 0.12 0.05],...
    'string','align',...
    'Callback', @fn_align,...
    'TooltipString', 'align the extracted fragments');

undo_button = uicontrol('style','pushbutton',... % undo pushbutton
    'units','normalized',...
    'position',[0.37 0.47 0.12 0.05],...
    'string','undo',...
    'Callback', @fn_undo,...
    'TooltipString', 'undo the last step');

uicontrol('style','pushbutton',... % save pushbutton
    'units','normalized',...
    'position',[0.1 0.05 0.12 0.05],...
    'string','load',...
    'Callback', @fn_load,...
    'TooltipString', 'convert your sequence');

delete_button = uicontrol('style','pushbutton',... % delete pushbutton
    'units','normalized',...
    'position',[0.235 0.05 0.12 0.05],...
    'string','delete',...
    'Callback', @fn_delete,...
    'TooltipString', 'delete the alignment and restart');

save_button = uicontrol('style','pushbutton',... % save pushbutton
    'units','normalized',...
    'position',[0.37 0.05 0.12 0.05],...
    'string','save',...
    'Callback', @fn_save,...
    'TooltipString', 'save your sequence alignment');


mymenu = uimenu('Label', 'File');
uimenu(mymenu,'Label','Open Project','Callback',@fn_loadProject);
uimenu(mymenu,'Label','Save Project','Callback',@fn_saveProject);


jquery = findjobj(query);
jquery = handle(jquery.getViewport.getView, 'CallbackProperties');
jsubject = findjobj(subject);
jsubject = handle(jsubject.getViewport.getView, 'CallbackProperties');
jquery.setEditorKit(javax.swing.text.html.HTMLEditorKit);
jsubject.setEditorKit(javax.swing.text.html.HTMLEditorKit);

% final
final1 = '';
final2 = '';
setappdata(main, 'final1', final1)
setappdata(main, 'final2', final2)

% seq
seq1 = get(query,'string');
seq2 = get(subject,'string');
setappdata(main, 'seq1', seq1)
setappdata(main, 'seq2', seq2)

% seq_html
seq1_html = sprintf('<font face="courier" font size="3">%s</font>', seq1);
seq2_html = sprintf('<font face="courier" font size="3">%s</font>', seq2);
jquery.setText(seq1_html)
jsubject.setText(seq2_html)

set(extract, 'enable', 'off');
set(delete_button, 'enable', 'off');
set(align, 'enable', 'off');
set(save_button, 'enable', 'off');
set(undo_button, 'enable', 'off');

% intial backup
backup = cell(10^4,3);
backup{1, 1} = '';
backup{1, 2} = '';
backup{1, 3} = seq1;
backup{1, 4} = seq2;
setappdata(main, 'steps', 1)
setappdata(main, 'backup', backup)

original_seq1 = seq1;
original_seq2 = seq2;
setappdata(main, 'original_seq1', original_seq1)
setappdata(main, 'original_seq2', original_seq2)
            
    function fn_extract(~,~)
        set(message, 'string', '');
        
        jquery = findjobj(query);
        jquery = handle(jquery.getViewport.getView, 'CallbackProperties');
        jsubject = findjobj(subject);
        jsubject = handle(jsubject.getViewport.getView, 'CallbackProperties');

        % check for manual user input in align (string search)
        select1 = upper(get(align1, 'string'));
        select2 = upper(get(align2, 'string'));
        
        if isempty(select1)
            select1 = get(jquery,'SelectedText');
            start1 = get(jquery, 'SelectionStart');
            end1 = get(jquery, 'SelectionEnd');
            setappdata(main, 'start1', start1)
            setappdata(main, 'end1', end1)
            
            select2 = get(jsubject,'SelectedText');
            start2 = get(jsubject, 'SelectionStart');
            end2 = get(jsubject, 'SelectionEnd');
            setappdata(main, 'start2', start2)
            setappdata(main, 'end2', end2)
            
            try
                seq1_html = sprintf('<font face="courier" font size="3">%s<font color="red">%s<font color="black">%s</font>', seq1(1:start1(1)-1), select1, seq1(start1(1)+length(select1):end));
                seq2_html = sprintf('<font face="courier" font size="3">%s<font color="red">%s<font color="black">%s</font>', seq2(1:start2(1)-1), select2, seq2(start2(1)+length(select2):end));
                jquery.setText(seq1_html)
                jsubject.setText(seq2_html)
            catch
            end
        else
            seq1 = getappdata(main, 'seq1');
            seq2 = getappdata(main, 'seq2');
            
            start1 = strfind(seq1, select1);
            start2 = strfind(seq2, select2);
            try
                set(jquery, 'SelectionStart', start1(1), 'SelectionEnd', start1(1)+length(select1))
                set(jsubject, 'SelectionStart', start2(1), 'SelectionEnd', start2(1)+length(select2))
                
                
                seq1_html = sprintf('<font face="courier" font size="3">%s<font color="red">%s<font color="black">%s</font>', seq1(1:start1(1)-1), select1, seq1(start1(1)+length(select1):end));
                seq2_html = sprintf('<font face="courier" font size="3">%s<font color="red">%s<font color="black">%s</font>', seq2(1:start2(1)-1), select2, seq2(start2(1)+length(select2):end));
                jquery.setText(seq1_html)
                jsubject.setText(seq2_html)
            
            
            end1 = start1(1)+length(select1);
            end2 = start2(1)+length(select2);
            
            setappdata(main, 'start1', start1)
            setappdata(main, 'end1', end1)
            setappdata(main, 'start2', start2)
            setappdata(main, 'end2', end2)
            catch
                set(message, 'string', 'the desired string cannot be found within the sequence...');
                select1 = [];
                select2 = [];
                set(align, 'enable', 'off')
            end
        end
        
        set(align1, 'string', select1);
        set(align2, 'string', select2);
  
        setappdata(main, 'select1', select1)
        setappdata(main, 'select2', select2)
        
        if ~isempty(select1) && length(select1) == length(select2)
            set(align, 'enable', 'on')
        end
        if length(select1) ~= length(select2)
            set(message, 'string', 'the two selection strings do not have the same length...');
        end
    end


    function fn_align(~,~)
        
        start1 = getappdata(main, 'start1');
        start2 = getappdata(main, 'start2');
        end1 = getappdata(main, 'end1');
        end2 = getappdata(main, 'end2');
        select1 = getappdata(main, 'select1');
        select2 = getappdata(main, 'select2');

        final1 = getappdata(main, 'final1');
        final2 = getappdata(main, 'final2');
        seq1 = getappdata(main, 'seq1');
        seq2 = getappdata(main, 'seq2');
        
%         if ~isempty(select1)
%             if start1 > start2
%                 n = repmat('-', 1, length(seq1(1:start1-1)));
%             else
%                 n = repmat('-', 1, length(seq2(1:start2-1)));
%             end
%         end
        
        if ~isempty(select1)
            n1 = repmat('-', 1, length(seq1(1:start1-1)));
            n2 = repmat('-', 1, length(seq2(1:start2-1)));
        end
        
        
%         if ~isempty(select1) && length(select1) == length(select2)
%             if start1 > start2
%                 final1 = [final1, seq1(1:start1-1), select1];
%                 final2 = [final2, n, select2];
%             else
%                 final2 = [final2, seq2(1:start2-1), select2];
%                 final1 = [final1, n, select1];
%             end
            
        if ~isempty(select1) && length(select1) == length(select2)
            final1 = [final1, seq1(1:start1-1), n2, select1];
            final2 = [final2, n1, seq2(1:start2-1), select2];
        
            
            setappdata(main, 'final1', final1)
            setappdata(main, 'final2', final2)
            
            select = [final1; final2];
            set(alignment, 'string', select);
            set(message, 'string', []);
            
            if ~isempty(select1)
                seq1 = seq1(end1:end);
                seq2 = seq2(end2:end);
            end
            
            setappdata(main, 'seq1', seq1)
            setappdata(main, 'seq2', seq2)
            
            seq1_html = sprintf('<font face="courier" font size="3">%s</font>', seq1);
            seq2_html = sprintf('<font face="courier" font size="3">%s</font>', seq2);
            jquery.setText(seq1_html)
            jsubject.setText(seq2_html)
           
            % backup for undo
            steps = getappdata(main, 'steps');
            steps = steps+1;
            setappdata(main, 'steps', steps)
            backup = getappdata(main, 'backup');
            backup{steps, 1} = final1;
            backup{steps, 2} = final2;
            backup{steps, 3} = seq1;
            backup{steps, 4} = seq2;
            setappdata(main, 'backup', backup)

        
        else 
            set(message, 'string', 'the two selection strings do not have the same length...');
        end
        
        select1 = [];
        setappdata(main, 'select1', select1)
        setappdata(main, 'select2', select2)
        select2 = [];
        set(align1, 'string', select1);
        set(align2, 'string', select2);
        
        set(align, 'enable', 'off')
        set(undo_button, 'enable', 'on')

    end

    function fn_delete(~,~)
        final1 = [];
        final2 = [];
        setappdata(main, 'final1', final1)
        setappdata(main, 'final2', final2)
        select = [final1; final2];
        set(alignment, 'string', select);
        set(align1, 'string', []);
        set(align2, 'string', []);
        set(message, 'string', []);
        seq1 = 'template sequence (FASTA)';
        seq2 = 'target sequence (FASTA)';
        setappdata(main, 'seq1', seq1)
        setappdata(main, 'seq2', seq2)
        seq1_html = sprintf('<font face="courier" font size="3">%s</font>', seq1);
        seq2_html = sprintf('<font face="courier" font size="3">%s</font>', seq2);
        jquery.setText(seq1_html)
        jsubject.setText(seq2_html)
        set(query_static, 'string', seq1)
        set(subject_static, 'string', seq2)
        
        set(extract, 'enable', 'off');
        set(delete_button, 'enable', 'off');
        set(align, 'enable', 'off');
        set(save_button, 'enable', 'off');
    end

    function fn_save(~,~)
        
        % home directory
        if ispc
            home_dir = getenv('USERPROFILE');
        else
            home_dir = getenv('HOME');
        end
        
        headerline = get(samplename, 'string');
        select = get(alignment, 'string');
        select = select';
        
        [savepathname, pathname] = uiputfile(sprintf('%s/Desktop/homology_alignment.txt', home_dir), 'Save As');   
        fid = fopen(sprintf('%s/%s', pathname, savepathname), 'wt');
        try
            fprintf(fid, '%s\n', headerline);
        catch
            return
        end
        try
            fprintf(fid, '%s\n', select(:,1));
            fprintf(fid, '%s\n', select(:,2));
        catch
        end
        fclose(fid);
        set(message, 'string', 'Alignment saved...');
    end

    function fn_load(~,~)
        set(extract, 'enable', 'on');
        set(delete_button, 'enable', 'on');
        set(save_button, 'enable', 'on');
        % open template
        [filename_template, pathname_template] = uigetfile({'*.fasta', 'FASTA-file (*.fasta)'}, 'Multiselect', 'off', 'Please select your template FASTA file');
        if filename_template==0
            return
        end
        cd(pathname_template)
        fid = fopen(filename_template,'r');
        seq1 = textscan(fid,'%s', 'Headerlines', 1);
        seq1 = upper(strjoin(seq1{:}));
        seq1(isspace(seq1)) = [];
        
        % open target
        [filename_target, pathname_target] = uigetfile({'*.fasta', 'FASTA-file (*.fasta)'}, 'Multiselect', 'off', 'Please select your target FASTA file');
        if filename_target==0
            return
        end
        cd(pathname_target)
        fid = fopen(filename_target,'r');
        seq2 = textscan(fid,'%s', 'Headerlines', 1);
        seq2 = upper(strjoin(seq2{:}));
        seq2(isspace(seq2)) = [];
        
        
        seq1 = reshape(seq1 .', 1, []);
        seq2 = reshape(seq2 .', 1, []);
        setappdata(main, 'seq1', seq1)
        setappdata(main, 'seq2', seq2)
        
        set(query_static, 'string', seq1)
        set(subject_static, 'string', seq2)
        setappdata(main, 'original_seq1', seq1)
        setappdata(main, 'original_seq2', seq2)
        
        seq1_html = sprintf('<font face="courier" font size="3">%s</font>', seq1);
        seq2_html = sprintf('<font face="courier" font size="3">%s</font>', seq2);
        jquery.setText(seq1_html)
        jsubject.setText(seq2_html)
    end

    function fn_undo(~,~)
        try
        backup = getappdata(main, 'backup');
        steps = getappdata(main, 'steps');
        final1 = backup{steps-1, 1};
        final2 = backup{steps-1, 2};
        seq1 = backup{steps-1, 3};
        seq2 = backup{steps-1, 4};
        select = [final1; final2];
        set(alignment, 'string', select);
        seq1_html = sprintf('<font face="courier" font size="3">%s</font>', seq1);
        seq2_html = sprintf('<font face="courier" font size="3">%s</font>', seq2);
        jquery.setText(seq1_html)
        jsubject.setText(seq2_html)
        setappdata(main, 'final1', final1)
        setappdata(main, 'final2', final2)
        setappdata(main, 'seq1', seq1)
        setappdata(main, 'seq2', seq2)
        setappdata(main, 'steps', steps-1);
        catch
            set(message, 'string', 'you cannot go further back...');
        end
    end

    function fn_saveProject(~,~)
        % home directory
        if ispc
            home_dir = getenv('USERPROFILE');
        else
            home_dir = getenv('HOME');
        end
        final1 = getappdata(main, 'final1');
        final2 = getappdata(main, 'final2');
        seq1 = getappdata(main, 'seq1');
        seq2 = getappdata(main, 'seq2');
        original_seq1 = getappdata(main, 'original_seq1'); 
        original_seq2 = getappdata(main, 'original_seq2');
        headerline = get(samplename, 'string'); %#ok<NASGU>
        [savepathname, pathname] = uiputfile(sprintf('%s/Desktop/SABOSS_project.mat', home_dir), 'Save SABOSS Project');   
        save(sprintf('%s/%s', pathname, savepathname),'final1','final2','seq1','seq2','original_seq1','original_seq2','headerline');
        set(message, 'string', sprintf('Project "%s" saved',savepathname));
    end

    function fn_loadProject(~,~)
        [openfilename, openpathname] = uigetfile({'*.mat', 'Matlab Data file (*.mat)'}, 'Open SABOSS Project', 'Multiselect', 'off');   
        if openpathname==0
            return
        end
        data = load(sprintf('%s/%s',openpathname,openfilename));
        
        final1 = data.final1;
        final2 = data.final2;
        seq1 = data.seq1;
        seq2 = data.seq2;
        original_seq1 = data.original_seq1;
        original_seq2 = data.original_seq2;
        headerline = data.headerline;
        select = [final1; final2];
        set(alignment, 'string', select);
        seq1_html = sprintf('<font face="courier" font size="3">%s</font>', seq1);
        seq2_html = sprintf('<font face="courier" font size="3">%s</font>', seq2);
        jquery.setText(seq1_html)
        jsubject.setText(seq2_html)
        set(query_static, 'string', original_seq1)
        set(subject_static, 'string', original_seq2)
        set(samplename, 'string', headerline)
        setappdata(main, 'final1', final1)
        setappdata(main, 'final2', final2)
        setappdata(main, 'seq1', seq1)
        setappdata(main, 'seq2', seq2)
        setappdata(main, 'original_seq1', original_seq1)
        setappdata(main, 'original_seq2', original_seq2)
        set(extract, 'enable', 'on');
        set(delete_button, 'enable', 'on');
        set(save_button, 'enable', 'on');
        
        % backup for undo
        steps = getappdata(main, 'steps');
        steps = steps+1;
        setappdata(main, 'steps', steps)
        backup = getappdata(main, 'backup');
        backup{steps, 1} = final1;
        backup{steps, 2} = final2;
        backup{steps, 3} = seq1;
        backup{steps, 4} = seq2;
        setappdata(main, 'backup', backup)
        
        set(message, 'string', sprintf('Project "%s" loaded', openfilename));
    end
% function my_closereq(main)
% selection = questdlg('Quit the sequence alignment?',...
%     'Confirmation',...
%     'Yes','No','Yes');
% switch selection,
%     case 'Yes',
%         delete(main)
%     case 'No'
%         return
% end
% end

end